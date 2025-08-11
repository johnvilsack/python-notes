# Bootstrap "python-notes" on Windows 11 using uv + VS Code
# Example run (PS 7+): pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "iwr -UseBasicParsing 'https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1' | iex; Start-PythonNotesBootstrap -Verbose"
# Example dry-run + log:  pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "iwr -UseBasicParsing 'https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1' | iex; Start-PythonNotesBootstrap -WhatIf -Verbose -LogFile '$env:USERPROFILE\github\python-notes-bootstrap.log'"

#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
param(
  [string]$ProjectPath = (Join-Path $env:USERPROFILE 'github\python-notes'),
  [switch]$SkipVSCodeOpen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------- helpers ----------
$Results = [System.Collections.Generic.List[object]]::new()

function Write-StepResult {
  param([string]$Name,[bool]$Ok,[string]$Note)
  $Results.Add([pscustomobject]@{ Step=$Name; Success=$Ok; Note=$Note })
  if ($Ok) { Write-Host "$Name => SUCCESS : $Note" -ForegroundColor Green }
  else     { Write-Host "$Name => FAIL    : $Note" -ForegroundColor Red }
}

function Add-PathSession {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$PathToAdd)
  if (Test-Path -LiteralPath $PathToAdd) {
    $current = $env:Path -split ';'
    if ($current -notcontains $PathToAdd) {
      $env:Path = @($PathToAdd) + $current -join ';'
    }
  }
}

function Set-UserPathPersistent {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param([Parameter(Mandatory)][string]$PathToAdd)
  if (-not (Test-Path -LiteralPath $PathToAdd)) { return }
  $userPath = [Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ }
  if ($userPath -notcontains $PathToAdd) {
    if ($PSCmdlet.ShouldProcess("User PATH","Add '$PathToAdd'")) {
      [Environment]::SetEnvironmentVariable('Path', ($userPath + $PathToAdd) -join ';', 'User')
    }
  }
}

function Test-Winget { Get-Command winget -ErrorAction SilentlyContinue }

function Install-ToolIfMissing {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory)][string]$ExeName,
    [Parameter(Mandatory)][string]$WingetId,
    [string]$FriendlyName = $WingetId
  )
  if (Get-Command $ExeName -ErrorAction SilentlyContinue) { return "present" }
  if (-not (Test-Winget)) { return "missing (winget unavailable)" }
  if ($PSCmdlet.ShouldProcess($FriendlyName, "Install via winget")) {
    winget install --id $WingetId -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
    Start-Sleep -Seconds 3
    if (-not (Get-Command $ExeName -ErrorAction SilentlyContinue)) {
      winget install --id $WingetId -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
      Start-Sleep -Seconds 2
    }
  }
  if (Get-Command $ExeName -ErrorAction SilentlyContinue) { "installed" } else { "install failed" }
}

function Invoke-Step {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Title,
    [Parameter(Mandatory)][int]$Index,
    [Parameter(Mandatory)][int]$Total,
    [Parameter(Mandatory)][scriptblock]$Action
  )
  Write-Host "[$Index/$Total] $Title" -ForegroundColor Cyan
  $pct = [int](($Index / $Total) * 100)
  Write-Progress -Activity "python-notes bootstrap" -Status $Title -PercentComplete $pct -Id 1
  & $Action
}

function Start-PythonNotesBootstrap {
  [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
  param(
    [string]$ProjectPath = (Join-Path $env:USERPROFILE 'github\python-notes'),
    [switch]$SkipVSCodeOpen,
    [string]$LogFile
  )

  if ($PSBoundParameters.ContainsKey('LogFile')) {
    try { Start-Transcript -Path $LogFile -Append | Out-Null } catch {}
  }

  Write-Host "`nPython Notes Bootstrap" -ForegroundColor Cyan
  Write-Host "======================" -ForegroundColor Cyan

  $total = 6; $i = 0

  # [1/6] uv installer + PATH
  Invoke-Step -Title "[1/6] uv" -Index (++$i) -Total $total -Action {
    try {
      if ($PSCmdlet.ShouldProcess("uv", "Install/refresh")) {
        powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -c "iwr -UseBasicParsing https://astral.sh/uv/install.ps1 | iex" 2>$null
      }
      $UserBin = Join-Path $HOME '.local\bin'
      Add-PathSession $UserBin
      Set-UserPathPersistent $UserBin
      if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw "uv not on PATH" }
      Write-StepResult "[1/6] uv" $true "ready: $(uv --version)"
    } catch { Write-StepResult "[1/6] uv" $false $_.Exception.Message }
  }

  # [2/6] Project + env (uv-managed Python - latest version)
  Invoke-Step -Title "[2/6] Project + env" -Index (++$i) -Total $total -Action {
    try {
      if ($PSCmdlet.ShouldProcess($ProjectPath, "Create directory")) {
        New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
      }
      Set-Location $ProjectPath
      
      # Use --python 3 to get latest Python 3.x that uv supports
      if ($PSCmdlet.ShouldProcess("$ProjectPath", "uv init with latest Python")) {
        uv init --python ">=3.12"
        Read-Host "Initted"
      }

      # uv sync will now download/use the uv-managed Python
      if ($PSCmdlet.ShouldProcess("$ProjectPath", "uv sync (create venv & install deps)")) {
        uv sync
        Read-Host "Synced"
      }

      # Verify the interpreter is the project venv, not global
      if (-not (Test-Path .\.venv\Scripts\python.exe)) { 
        throw ".venv interpreter missing after uv sync" 
      }
      
      # Get actual Python version for reporting
      $pyVersion = & .\.venv\Scripts\python.exe --version 2>&1
      
      if (-not (Test-Path .\main.py)) {
        if ($PSCmdlet.ShouldProcess("main.py", "Create")) {
          'print("Hello, python-notes!")' | Set-Content -NoNewline -Encoding UTF8 .\main.py
        }
      }
      Write-StepResult "[2/6] Project + env" $true ".venv ready (uv-managed $pyVersion)"
    } catch { Write-StepResult "[2/6] Project + env" $false $_.Exception.Message }
  }

  # [3/6] Env (packages + browsers)
  Invoke-Step -Title "[3/6] Env (packages + browsers)" -Index (++$i) -Total $total -Action {
    try {
      $pkgs = 'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl','notebook','ipykernel'
      if ($PSCmdlet.ShouldProcess(".venv", "uv add packages")) { 
        uv add $pkgs | Out-Null 
      }
      if ($PSCmdlet.ShouldProcess("Playwright browsers", "Install")) { 
        uv run python -m playwright install | Out-Null 
      }
      Write-StepResult "[3/6] Env" $true "packages + browsers ready"
    } catch { Write-StepResult "[3/6] Env" $false $_.Exception.Message }
  }

  # [4/6] Content (examples, data, notebook)
  Invoke-Step -Title "[4/6] Content" -Index (++$i) -Total $total -Action {
    try {
      $repo = "https://raw.githubusercontent.com/johnvilsack/python-notes/main/downloads"
      if ($PSCmdlet.ShouldProcess("examples.py", "Download or fallback")) {
        try { 
          Invoke-WebRequest -Uri "$repo/examples.py" -OutFile .\examples.py -UseBasicParsing -ErrorAction Stop 
        }
        catch { 
          @"
# Examples file (fallback)
print("Run examples to see what each package can do!")
"@ | Set-Content -Encoding UTF8 .\examples.py 
        }
      }
      if ($PSCmdlet.ShouldProcess("example-data", "Ensure directory")) {
        New-Item -ItemType Directory -Force -Path .\example-data | Out-Null
      }
      if ($PSCmdlet.ShouldProcess("example-employees.csv", "Download or fallback")) {
        try { 
          Invoke-WebRequest -Uri "$repo/example-employees.csv" -OutFile .\example-data\example-employees.csv -UseBasicParsing -ErrorAction Stop 
        }
        catch { 
          @"
name,email,department,salary,start_date
Alice Johnson,alice@company.com,Engineering,95000,2021-03-15
Bob Smith,bob@company.com,Sales,65000,2022-01-10
Carol Williams,carol@company.com,Engineering,88000,2020-06-01
"@ | Set-Content -Encoding UTF8 .\example-data\example-employees.csv 
        }
      }
      if ($PSCmdlet.ShouldProcess("notebook.ipynb", "Write")) {
        @"
{
  "cells": [
    {"cell_type":"markdown","metadata":{},"source":["# Python Notes — Quick Start","","Run cells with Shift+Enter"]},
    {"cell_type":"code","execution_count":null,"metadata":{},"outputs":[],
     "source":["import sys, pandas as pd, pydantic","print('Python:', sys.version)","print('pandas:', pd.__version__)","print('pydantic:', pydantic.__version__)"]},
    {"cell_type":"code","execution_count":null,"metadata":{},"outputs":[],
     "source":["df = pd.read_csv('example-data/example-employees.csv')","df.head()"]}
  ],
  "metadata": { "kernelspec": {"display_name":"Python 3","language":"python","name":"python3"} },
  "nbformat": 4, "nbformat_minor": 5
}
"@ | Set-Content -Encoding UTF8 .\notebook.ipynb
      }
      Write-StepResult "[4/6] Content" $true "examples + data + notebook"
    } catch { Write-StepResult "[4/6] Content" $false $_.Exception.Message }
  }

  # [5/6] Tools via winget
  Invoke-Step -Title "[5/6] Tools" -Index (++$i) -Total $total -Action {
    try {
      $gitStatus = Install-ToolIfMissing -ExeName 'git.exe'  -WingetId 'Git.Git'                    -FriendlyName 'Git'
      $vscStatus = Install-ToolIfMissing -ExeName 'code.cmd' -WingetId 'Microsoft.VisualStudioCode' -FriendlyName 'Visual Studio Code'
      $ghdStatus = Install-ToolIfMissing -ExeName 'github'   -WingetId 'GitHub.GitHubDesktop'       -FriendlyName 'GitHub Desktop'

      $CodeBin = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'
      Add-PathSession $CodeBin
      Set-UserPathPersistent $CodeBin

      if (Get-Command code -ErrorAction SilentlyContinue) {
        if ($PSCmdlet.ShouldProcess("VS Code", "Install Python & Jupyter extensions")) {
          $codeCmd = (Get-Command code -ErrorAction SilentlyContinue).Source
          & $codeCmd --install-extension ms-python.python  --force | Out-Null
          & $codeCmd --install-extension ms-toolsai.jupyter --force | Out-Null
        }
      }

      Write-StepResult "[5/6] Tools" $true "git:$gitStatus; vscode:$vscStatus; gh-desktop:$ghdStatus"
    } catch { Write-StepResult "[5/6] Tools" $false $_.Exception.Message }
  }

  # [6/6] VS Code configuration
  Invoke-Step -Title "[6/6] VS Code" -Index (++$i) -Total $total -Action {
    try {
      if ($PSCmdlet.ShouldProcess(".vscode", "Ensure directory")) {
        New-Item -ItemType Directory -Force -Path .\.vscode | Out-Null
      }
      $venvPy = ".\\.venv\\Scripts\\python.exe"
      $CodeBin = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'
      $termPathPatch = if (Test-Path -LiteralPath $CodeBin) { "$CodeBin;`$\{env:PATH}" } else { "`$\{env:PATH}" }

      if ($PSCmdlet.ShouldProcess(".vscode\\settings.json", "Write")) {
        @{
          "python.defaultInterpreterPath"                 = $venvPy
          "python.terminal.activateEnvironment"           = $true
          "terminal.integrated.cwd"                       = '${workspaceFolder}'
          "terminal.integrated.enablePersistentSessions"  = $true
          "task.allowAutomaticTasks"                      = "on"
          "terminal.integrated.env.windows"               = @{ "PATH" = $termPathPatch }
          "terminal.integrated.defaultProfile.windows"    = "PowerShell"
          "terminal.explorerKind"                         = "integrated"
        } | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 .\.vscode\settings.json
      }

      if ($PSCmdlet.ShouldProcess(".vscode\\tasks.json", "Write auto-open terminal task")) {
        @"
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Open Terminal (on folder open)",
      "type": "shell",
      "options": { "shell": { "executable": "powershell.exe", "args": ["-NoLogo","-NoProfile","-NoExit","-Command"] } },
      "command": "Write-Host 'Terminal ready';",
      "runOptions": { "runOn": "folderOpen" },
      "presentation": { "reveal": "always", "panel": "shared", "focus": true }
    }
  ]
}
"@ | Set-Content -Encoding UTF8 .\.vscode\tasks.json
      }

      $ws = @{
        "folders"  = @(@{"path"="."});
        "settings" = @{
          "python.defaultInterpreterPath"                 = $venvPy
          "python.terminal.activateEnvironment"           = $true
          "terminal.integrated.cwd"                       = '${workspaceFolder}'
          "terminal.integrated.enablePersistentSessions"  = $true
          "task.allowAutomaticTasks"                      = "on"
          "terminal.integrated.env.windows"               = @{ "PATH" = $termPathPatch }
          "terminal.integrated.defaultProfile.windows"    = "PowerShell"
          "terminal.explorerKind"                         = "integrated"
        }
      } | ConvertTo-Json -Depth 5

      $wsPath = Join-Path (Get-Location) "python-notes.code-workspace"
      if ($PSCmdlet.ShouldProcess($wsPath, "Write workspace file")) {
        $ws | Set-Content -Encoding UTF8 $wsPath
      }

      if (-not $SkipVSCodeOpen -and (Get-Command code -ErrorAction SilentlyContinue)) {
        if ($PSCmdlet.ShouldProcess("VS Code", "Open workspace & files")) {
          $codeCmd = (Get-Command code).Source
          & $codeCmd $wsPath .\main.py .\examples.py .\notebook.ipynb | Out-Null
        }
      } elseif (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Warning "VS Code installed but 'code' CLI not yet visible in THIS shell; new terminals will see it, or run: `$env:Path += ';$CodeBin'"
      }

      Write-StepResult "[6/6] VS Code" $true "workspace ready (terminal auto-opens; PATH patched in panel)"
    } catch { Write-StepResult "[6/6] VS Code" $false $_.Exception.Message }
  }

  Write-Progress -Activity "python-notes bootstrap" -Completed -Id 1
  Write-Host ""
  $Results | Format-Table -AutoSize

  # Reminder about PATH
  Write-Host "Note: Your original terminal won't inherit new PATH values. If 'code' isn't recognized there, close and reopen that terminal." -ForegroundColor DarkYellow

  if ($PSBoundParameters.ContainsKey('LogFile')) {
    try { Stop-Transcript | Out-Null } catch {}
  }
}

if ($MyInvocation.InvocationName -ne '.') {
  Start-PythonNotesBootstrap -ProjectPath $ProjectPath -SkipVSCodeOpen:$SkipVSCodeOpen
}
