# Bootstrap "python-notes" on Windows 11 using uv + VS Code
# Best for -WhatIf:  powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -File .\python-notes-bootstrap.ps1 [-WhatIf]
# One-liner run:     powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1 | iex"
# One-liner + -WhatIf: powershell -ExecutionPolicy Bypass -c "$s=irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1; iex $s; Start-PythonNotesBootstrap -WhatIf"

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
  param([Parameter(Mandatory)][string]$PathToAdd)
  if (Test-Path -LiteralPath $PathToAdd) {
    $env:Path = ((($env:Path -split ';') + $PathToAdd) | Where-Object { $_ } | Select-Object -Unique) -join ';'
  }
}

function Set-UserPathPersistent {
  param([Parameter(Mandatory)][string]$PathToAdd)
  if (-not (Test-Path -LiteralPath $PathToAdd)) { return }
  $userPath = [Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ }
  if ($userPath -notcontains $PathToAdd) {
    [Environment]::SetEnvironmentVariable('Path', ($userPath + $PathToAdd) -join ';', 'User')
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
  if (Get-Command $ExeName -ErrorAction SilentlyContinue) { return "present" }
  if (-not (Test-Winget)) { return "missing (winget not available)" }
  if ($PSCmdlet.ShouldProcess($FriendlyName, "Install via winget")) {
    winget install --id $WingetId -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
  }
  if (Get-Command $ExeName -ErrorAction SilentlyContinue) { "installed" } else { "install failed" }
}

function Start-PythonNotesBootstrap {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
  param(
    [string]$ProjectPath = "$HOME\Documents\python-notes",
    [switch]$SkipVSCodeOpen
  )

  Write-Host "`nPython Notes Bootstrap" -ForegroundColor Cyan
  Write-Host "======================" -ForegroundColor Cyan

  # [1/6] uv install + PATH
  try {
    if ($PSCmdlet.ShouldProcess("uv", "Install/refresh")) {
      powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex" *>$null
    }
    # Rebuild PATH from registry then add ~/.local/bin (required for this shell + persist for future shells)
    $machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
    $userPath    = [Environment]::GetEnvironmentVariable('Path','User')
    if ($machinePath -or $userPath) { $env:Path = @($machinePath,$userPath) -join ';' }
    $UserBin = Join-Path $HOME '.local\bin'
    Add-PathSession $UserBin
    Set-UserPathPersistent $UserBin
    $UvExe = Join-Path $UserBin 'uv.exe'
    if (Test-Path $UvExe) { Set-Alias uv $UvExe -Scope Local -Force }
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw "uv not on PATH after install." }
    Write-StepResult "[1/6] uv" $true "ready: $(uv --version)"
  } catch { Write-StepResult "[1/6] uv" $false $_.Exception.Message }

  # [2/6] Project create + uv init + main.py
  try {
    if ($PSCmdlet.ShouldProcess($ProjectPath, "Create directory")) {
      New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
    }
    Set-Location $ProjectPath
    if ($PSCmdlet.ShouldProcess("$ProjectPath", "uv init")) { uv init *>$null }
    if (-not (Test-Path .\main.py)) {
      if ($PSCmdlet.ShouldProcess("main.py", "Create")) {
@"
print("Hello, python-notes!")
"@ | Set-Content -NoNewline -Encoding UTF8 .\main.py
      }
    }
    Write-StepResult "[2/6] Project" $true "initialized"
  } catch { Write-StepResult "[2/6] Project" $false $_.Exception.Message }

  # [3/6] Packages + venv + Playwright (all browsers)
  try {
    $pkgs = 'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl','notebook','ipykernel'
    if ($PSCmdlet.ShouldProcess("pyproject", "uv add ($($pkgs -join ', '))")) { uv add $pkgs *>$null }
    if ($PSCmdlet.ShouldProcess(".venv", "uv sync")) { uv sync *>$null }
    if ($PSCmdlet.ShouldProcess("Playwright browsers", "Install")) { uv run python -m playwright install *>$null }
    Write-StepResult "[3/6] Env" $true ".venv ready"
  } catch { Write-StepResult "[3/6] Env" $false $_.Exception.Message }

  # [4/6] Examples + data + notebook (proper here-strings)
  try {
    $repo = "https://raw.githubusercontent.com/johnvilsack/python-notes/main/downloads"
    if ($PSCmdlet.ShouldProcess("examples.py", "Download")) {
      try { Invoke-WebRequest -Uri "$repo/examples.py" -OutFile .\examples.py -UseBasicParsing }
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
    if ($PSCmdlet.ShouldProcess("example-employees.csv", "Download")) {
      try { Invoke-WebRequest -Uri "$repo/example-employees.csv" -OutFile .\example-data\example-employees.csv -UseBasicParsing }
      catch {
@"
name,email,department,salary,start_date
Alice Johnson,alice@company.com,Engineering,95000,2021-03-15
Bob Smith,bob@company.com,Sales,65000,2022-01-10
Carol Williams,carol@company.com,Engineering,88000,2020-06-01
"@ | Set-Content -Encoding UTF8 .\example-data\example-employees.csv
      }
    }
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

  # [5/6] Tools via winget only if missing; add VS Code bin to PATH (session + persist)
  try {
    $gitStatus = Install-ToolIfMissing -ExeName 'git.exe' -WingetId 'Git.Git' -FriendlyName 'Git'
    $vscStatus = Install-ToolIfMissing -ExeName 'code.cmd' -WingetId 'Microsoft.VisualStudioCode' -FriendlyName 'Visual Studio Code'
    $ghdStatus = Install-ToolIfMissing -ExeName 'github' -WingetId 'GitHub.GitHubDesktop' -FriendlyName 'GitHub Desktop'

    $CodeBin = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'
    Add-PathSession $CodeBin
    Set-UserPathPersistent $CodeBin

    if (Get-Command code -ErrorAction SilentlyContinue) {
      if ($PSCmdlet.ShouldProcess("VS Code", "Install Python & Jupyter extensions")) {
        code --install-extension ms-python.python --force *>$null
        code --install-extension ms-toolsai.jupyter --force *>$null
      }
    }
    Write-StepResult "[5/6] Tools" $true "git:$gitStatus; vscode:$vscStatus; gh-desktop:$ghdStatus"
  } catch { Write-StepResult "[5/6] Tools" $false $_.Exception.Message }

  # [6/6] VS Code config + open
  try {
    if ($PSCmdlet.ShouldProcess(".vscode", "Ensure directory")) {
      New-Item -ItemType Directory -Force -Path .\.vscode | Out-Null
    }
    $venvPy = ".\.venv\Scripts\python.exe"
    @{
      "python.defaultInterpreterPath" = $venvPy
      "terminal.integrated.cwd"       = "\${workspaceFolder}"
    } | ConvertTo-Json | Set-Content -Encoding UTF8 .\.vscode\settings.json

    $ws = @{
      "folders" = @(@{"path"="."});
      "settings" = @{ "python.defaultInterpreterPath" = $venvPy; "terminal.integrated.cwd" = "\${workspaceFolder}" }
    } | ConvertTo-Json -Depth 5
    $wsPath = Join-Path (Get-Location) "python-notes.code-workspace"
    $ws | Set-Content -Encoding UTF8 $wsPath

    if (-not $SkipVSCodeOpen -and (Get-Command code -ErrorAction SilentlyContinue)) {
      if ($PSCmdlet.ShouldProcess("VS Code", "Open workspace & files")) {
        code $wsPath .\main.py .\examples.py .\notebook.ipynb *>$null
      }
    } elseif (-not (Get-Command code -ErrorAction SilentlyContinue)) {
      Write-Warning "VS Code installed but 'code' CLI not yet on PATH in this shell; open a new terminal or run: `"`$env:Path += ';$CodeBin'`""
    }
    Write-StepResult "[6/6] VS Code" $true "workspace ready"
  } catch { Write-StepResult "[6/6] VS Code" $false $_.Exception.Message }

  Write-Host "`n✓ Complete (as far as possible)" -ForegroundColor Green
  $Results | Format-Table -AutoSize
  Write-Host "Location: $ProjectPath"
  Write-Host "Try: uv run examples.py"
}

# Auto-run when executed as a file; when piped via | iex, user can call Start-PythonNotesBootstrap [-WhatIf]
if ($MyInvocation.InvocationName -ne '.') {
  Start-PythonNotesBootstrap -ProjectPath $ProjectPath -SkipVSCodeOpen:$SkipVSCodeOpen
}
