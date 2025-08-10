# Bootstrap "python-notes" on Windows 11 using uv + VS Code (verbose/progress/log-enabled)
# Best for -WhatIf:  powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -File .\python-notes-bootstrap.ps1 [-WhatIf]
# One-liner run:     powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1 | iex"
# One-liner + -WhatIf: powershell -ExecutionPolicy Bypass -c "$s=irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1; iex $s; Start-PythonNotesBootstrap -WhatIf -Verbose"

#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
param(
  [string]$ProjectPath = "$HOME\Documents\python-notes",
  [switch]$SkipVSCodeOpen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------- helpers (approved verbs; no PSSA violations) ----------
$Results = [System.Collections.Generic.List[object]]::new()

function Write-StepResult([string]$Name,[bool]$Ok,[string]$Note) {
  $Results.Add([pscustomobject]@{ Step=$Name; Success=$Ok; Note=$Note })
}

function Add-PathSession {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$PathToAdd)
  Write-Verbose "Add-PathSession: Ensuring '$PathToAdd' is in current \$env:Path"
  if (Test-Path -LiteralPath $PathToAdd) {
    $env:Path = ((($env:Path -split ';') + $PathToAdd) | Where-Object { $_ } | Select-Object -Unique) -join ';'
  } else {
    Write-Verbose "Add-PathSession: Path does not exist, skipping"
  }
}

function Set-UserPathPersistent {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$PathToAdd)
  Write-Verbose "Set-UserPathPersistent: Adding '$PathToAdd' to User PATH (registry) if missing"
  if (-not (Test-Path -LiteralPath $PathToAdd)) { Write-Verbose "Set-UserPathPersistent: Path missing, skip"; return }
  $userPath = [Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ }
  if ($userPath -notcontains $PathToAdd) {
    [Environment]::SetEnvironmentVariable('Path', ($userPath + $PathToAdd) -join ';', 'User')
    Write-Verbose "Set-UserPathPersistent: Added"
  } else {
    Write-Verbose "Set-UserPathPersistent: Already present"
  }
}

function Test-Winget { Get-Command winget -ErrorAction SilentlyContinue }

function Install-ToolIfMissing {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][string]$ExeName,
    [Parameter(Mandatory)][string]$WingetId,
    [string]$FriendlyName = $WingetId
  )
  Write-Verbose "Install-ToolIfMissing: Checking '$ExeName' ($FriendlyName)"
  if (Get-Command $ExeName -ErrorAction SilentlyContinue) { Write-Verbose "Install-ToolIfMissing: Present"; return "present" }
  if (-not (Test-Winget)) { Write-Verbose "Install-ToolIfMissing: winget unavailable"; return "missing (winget not available)" }
  if ($PSCmdlet.ShouldProcess($FriendlyName, "Install via winget")) {
    Write-Verbose "Install-ToolIfMissing: winget install --id $WingetId"
    winget install --id $WingetId -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
  }
  if (Get-Command $ExeName -ErrorAction SilentlyContinue) { Write-Verbose "Install-ToolIfMissing: Installed"; "installed" } else { Write-Verbose "Install-ToolIfMissing: Install failed"; "install failed" }
}

function Invoke-Step {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Title,
    [Parameter(Mandatory)][int]$Index,
    [Parameter(Mandatory)][int]$Total,
    [Parameter(Mandatory)][scriptblock]$Action
  )
  $pct = [int](($Index / $Total) * 100)
  Write-Progress -Activity "python-notes bootstrap" -Status $Title -PercentComplete $pct -Id 1
  Write-Verbose "----- $Title -----"
  & $Action
}

function Start-PythonNotesBootstrap {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
  param(
    [string]$ProjectPath = "$HOME\Documents\python-notes",
    [switch]$SkipVSCodeOpen,
    [string]$LogFile
  )

  if ($PSBoundParameters.ContainsKey('LogFile')) {
    Write-Verbose "Starting transcript: $LogFile"
    try { Start-Transcript -Path $LogFile -Append | Out-Null } catch { Write-Verbose "Transcript failed: $($_.Exception.Message)" }
  }

  Write-Host "`nPython Notes Bootstrap" -ForegroundColor Cyan
  Write-Host "======================" -ForegroundColor Cyan

  $total = 6
  $i = 0

  # [1/6] uv install + PATH
  Invoke-Step -Title "[1/6] uv" -Index (++$i) -Total $total -Action {
    try {
      if ($PSCmdlet.ShouldProcess("uv", "Install/refresh")) {
        Write-Verbose "Downloading and running uv installer"
        powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex" *>$null
      }
      Write-Verbose "Rebuilding PATH from registry (Machine + User)"
      $machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
      $userPath    = [Environment]::GetEnvironmentVariable('Path','User')
      if ($machinePath -or $userPath) { $env:Path = @($machinePath,$userPath) -join ';' }
      $UserBin = Join-Path $HOME '.local\bin'
      Add-PathSession $UserBin
      Set-UserPathPersistent $UserBin
      $UvExe = Join-Path $UserBin 'uv.exe'
      if (Test-Path $UvExe) { Set-Alias uv $UvExe -Scope Local -Force }
      if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw "uv not on PATH after install." }
      Write-Verbose ("uv version: " + (uv --version))
      Write-StepResult "[1/6] uv" $true "ready: $(uv --version)"
    } catch { Write-StepResult "[1/6] uv" $false $_.Exception.Message }
  }

  # [2/6] Project create + uv init + main.py
  Invoke-Step -Title "[2/6] Project" -Index (++$i) -Total $total -Action {
    try {
      if ($PSCmdlet.ShouldProcess($ProjectPath, "Create directory")) {
        Write-Verbose "Ensuring directory: $ProjectPath"
        New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
      }
      Set-Location $ProjectPath
      if ($PSCmdlet.ShouldProcess("$ProjectPath", "uv init")) {
        Write-Verbose "Running 'uv init' in $ProjectPath"
        uv init *>$null
      }
      if (-not (Test-Path .\main.py)) {
        if ($PSCmdlet.ShouldProcess("main.py", "Create")) {
          Write-Verbose "Creating main.py"
@"
print("Hello, python-notes!")
"@ | Set-Content -NoNewline -Encoding UTF8 .\main.py
        }
      } else {
        Write-Verbose "main.py already exists; leaving untouched"
      }
      Write-StepResult "[2/6] Project" $true "initialized"
    } catch { Write-StepResult "[2/6] Project" $false $_.Exception.Message }
  }

  # [3/6] Packages + venv + Playwright (all browsers)
  Invoke-Step -Title "[3/6] Env" -Index (++$i) -Total $total -Action {
    try {
      $pkgs = 'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl','notebook','ipykernel'
      if ($PSCmdlet.ShouldProcess("pyproject", "uv add ($($pkgs -join ', '))")) {
        Write-Verbose "uv add $($pkgs -join ', ')"
        uv add $pkgs *>$null
      }
      if ($PSCmdlet.ShouldProcess(".venv", "uv sync")) {
        Write-Verbose "uv sync (materialize lock + create venv)"
        uv sync *>$null
      }
      if ($PSCmdlet.ShouldProcess("Playwright browsers", "Install")) {
        Write-Verbose "Installing Playwright browsers via 'uv run python -m playwright install'"
        uv run python -m playwright install *>$null
      }
      Write-StepResult "[3/6] Env" $true ".venv ready"
    } catch { Write-StepResult "[3/6] Env" $false $_.Exception.Message }
  }

  # [4/6] Examples + data + notebook
  Invoke-Step -Title "[4/6] Content" -Index (++$i) -Total $total -Action {
    try {
      $repo = "https://raw.githubusercontent.com/johnvilsack/python-notes/main/downloads"
      if ($PSCmdlet.ShouldProcess("examples.py", "Download")) {
        Write-Verbose "Downloading examples.py"
        try { Invoke-WebRequest -Uri "$repo/examples.py" -OutFile .\examples.py -UseBasicParsing -ErrorAction Stop }
        catch {
          Write-Verbose "Download failed; writing fallback examples.py"
@"
# Examples file (fallback)
print("Run examples to see what each package can do!")
"@ | Set-Content -Encoding UTF8 .\examples.py
        }
      }
      if ($PSCmdlet.ShouldProcess("example-data", "Ensure directory")) {
        Write-Verbose "Ensuring .\example-data"
        New-Item -ItemType Directory -Force -Path .\example-data | Out-Null
      }
      if ($PSCmdlet.ShouldProcess("example-employees.csv", "Download")) {
        Write-Verbose "Downloading example-employees.csv"
        try { Invoke-WebRequest -Uri "$repo/example-employees.csv" -OutFile .\example-data\example-employees.csv -UseBasicParsing -ErrorAction Stop }
        catch {
          Write-Verbose "Download failed; writing fallback CSV"
@"
name,email,department,salary,start_date
Alice Johnson,alice@company.com,Engineering,95000,2021-03-15
Bob Smith,bob@company.com,Sales,65000,2022-01-10
Carol Williams,carol@company.com,Engineering,88000,2020-06-01
"@ | Set-Content -Encoding UTF8 .\example-data\example-employees.csv
        }
      }
      Write-Verbose "Writing notebook.ipynb"
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
      Write-StepResult "[4/6] Content" $true "examples + data + notebook"
    } catch { Write-StepResult "[4/6] Content" $false $_.Exception.Message }
  }

  # [5/6] Tools via winget; ensure code CLI on PATH; install extensions
  Invoke-Step -Title "[5/6] Tools" -Index (++$i) -Total $total -Action {
    try {
      $gitStatus = Install-ToolIfMissing -ExeName 'git.exe' -WingetId 'Git.Git' -FriendlyName 'Git' -Verbose:$VerbosePreference
      $vscStatus = Install-ToolIfMissing -ExeName 'code.cmd' -WingetId 'Microsoft.VisualStudioCode' -FriendlyName 'Visual Studio Code' -Verbose:$VerbosePreference
      $ghdStatus = Install-ToolIfMissing -ExeName 'github' -WingetId 'GitHub.GitHubDesktop' -FriendlyName 'GitHub Desktop' -Verbose:$VerbosePreference

      $CodeBin = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'
      Add-PathSession $CodeBin
      Set-UserPathPersistent $CodeBin

      if (Get-Command code -ErrorAction SilentlyContinue) {
        if ($PSCmdlet.ShouldProcess("VS Code", "Install Python & Jupyter extensions")) {
          Write-Verbose "Installing VS Code extensions: ms-python.python, ms-toolsai.jupyter"
          code --install-extension ms-python.python --force *>$null
          code --install-extension ms-toolsai.jupyter --force *>$null
        }
      } else {
        Write-Verbose "code CLI not available yet in this shell"
      }
      Write-StepResult "[5/6] Tools" $true "git:$gitStatus; vscode:$vscStatus; gh-desktop:$ghdStatus"
    } catch { Write-StepResult "[5/6] Tools" $false $_.Exception.Message }
  }

  # [6/6] VS Code config + open
  Invoke-Step -Title "[6/6] VS Code" -Index (++$i) -Total $total -Action {
    try {
      if ($PSCmdlet.ShouldProcess(".vscode", "Ensure directory")) {
        Write-Verbose "Ensuring .vscode directory"
        New-Item -ItemType Directory -Force -Path .\.vscode | Out-Null
      }
      $venvPy = ".\.venv\Scripts\python.exe"
      Write-Verbose "Writing .vscode\settings.json with interpreter $venvPy"
      @{
        "python.defaultInterpreterPath" = $venvPy
        "terminal.integrated.cwd"       = "\${workspaceFolder}"
      } | ConvertTo-Json | Set-Content -Encoding UTF8 .\.vscode\settings.json

      $ws = @{
        "folders" = @(@{"path"="."});
        "settings" = @{ "python.defaultInterpreterPath" = $venvPy; "terminal.integrated.cwd" = "\${workspaceFolder}" }
      } | ConvertTo-Json -Depth 5
      $wsPath = Join-Path (Get-Location) "python-notes.code-workspace"
      Write-Verbose "Writing workspace: $wsPath"
      $ws | Set-Content -Encoding UTF8 $wsPath

      if (-not $SkipVSCodeOpen -and (Get-Command code -ErrorAction SilentlyContinue)) {
        if ($PSCmdlet.ShouldProcess("VS Code", "Open workspace & files")) {
          Write-Verbose "Opening VS Code with workspace and starter files"
          code $wsPath .\main.py .\examples.py .\notebook.ipynb *>$null
        }
      } elseif (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Warning "VS Code installed but 'code' CLI not yet on PATH in this shell; open a new terminal or run: `"`$env:Path += ';$CodeBin'`""
      }
      Write-StepResult "[6/6] VS Code" $true "workspace ready"
    } catch { Write-StepResult "[6/6] VS Code" $false $_.Exception.Message }
  }

  Write-Progress -Activity "python-notes bootstrap" -Completed -Id 1
  Write-Host "`n✓ Complete (as far as possible)" -ForegroundColor Green
  $Results | Format-Table -AutoSize
  Write-Host "Location: $ProjectPath"
  Write-Host "Try: uv run examples.py"

  if ($PSBoundParameters.ContainsKey('LogFile')) {
    try { Stop-Transcript | Out-Null } catch {}
  }
}

# Auto-run when executed as a file; when piped via | iex, user can call Start-PythonNotesBootstrap [-WhatIf] [-Verbose] [-LogFile <path>]
if ($MyInvocation.InvocationName -ne '.') {
  Start-PythonNotesBootstrap -ProjectPath $ProjectPath -SkipVSCodeOpen:$SkipVSCodeOpen
}
