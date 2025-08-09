# Windows 11 bootstrap for a "python-notes" project using uv + VS Code
# - Installs uv and refreshes PATH for *this* session
# - Creates ~/Documents/python-notes, inits with uv, installs Python + deps
# - Installs Playwright browsers
# - Ensures Git, VS Code, GitHub Desktop (winget)
# - Installs VS Code Python + Jupyter extensions
# - Writes a sample notebook + VS Code workspace bound to the project's venv
# - Opens the workspace with main.py + notebook.ipynb
# Run:  powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -File .\bootstrap-python-notes.ps1
# Or one-liner (replace RAW_URL):  irm RAW_URL | iex

#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
param(
  [string]$ProjectName = 'python-notes',
  [string]$DocumentsDir = [Environment]::GetFolderPath('MyDocuments'),
  [switch]$SkipVSCodeOpen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Quiet($ScriptBlock) {
  & $ScriptBlock *>$null
}

function Add-ToPathCurrentSession {
  param([Parameter(Mandatory)][string]$Dir)
  if (-not (Test-Path -LiteralPath $Dir)) { return }
  $segments = $env:Path -split ';' | Where-Object { $_ }
  if ($segments -notcontains $Dir) {
    $env:Path = ($segments + $Dir) -join ';'
  }
}

function Add-ToUserPathPersist {
  param([Parameter(Mandatory)][string]$Dir)
  if (-not (Test-Path -LiteralPath $Dir)) { return }
  $userPath = [Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ }
  if ($userPath -notcontains $Dir) {
    $new = ($userPath + $Dir) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $new, 'User')
  }
}

function Ensure-WinGet {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required. Install 'App Installer' from Microsoft Store, then re-run."
  }
}

function Ensure-Package {
  param(
    [Parameter(Mandatory)][string]$Id,
    [string]$NameForLog = $Id
  )
  Ensure-WinGet
  $installed = (winget list --id $Id --exact 2>$null) -join "`n"
  if ($installed -match [regex]::Escape($Id)) { return }

  Write-Host "Installing $NameForLog via winget..." -ForegroundColor Cyan
  winget install --id $Id -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
}

function Ensure-UV {
  # Install uv
  Write-Host "Installing uv..." -ForegroundColor Cyan
  powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"

  # Refresh PATH from registry (if installer wrote to it)
  $machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
  $userPath    = [Environment]::GetEnvironmentVariable('Path','User')
  if ($machinePath -or $userPath) { $env:Path = @($machinePath,$userPath) -join ';' }

  # Ensure user bin path for this session + persist
  $userBin = Join-Path $HOME '.local\bin'
  Add-ToPathCurrentSession -Dir $userBin
  Add-ToUserPathPersist   -Dir $userBin

  # Prefer absolute uv.exe if present
  $script:UvExe = Join-Path $userBin 'uv.exe'
  if (Test-Path $UvExe) { Set-Alias -Name uv -Value $UvExe -Scope Local -Force }

  # Sanity
  if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw "uv is not available on PATH after install."
  }
  Write-Host "uv ready: $(uv --version)" -ForegroundColor Green
}

function Ensure-GitVSCode-GHDesktop {
  Ensure-Package -Id 'Git.Git'                -NameForLog 'Git'
  Ensure-Package -Id 'Microsoft.VisualStudioCode' -NameForLog 'Visual Studio Code'
  Ensure-Package -Id 'GitHub.GitHubDesktop'   -NameForLog 'GitHub Desktop'

  # Add VS Code 'code' to PATH for this session + persist (Windows default install path)
  $codeBin = Join-Path $HOME 'AppData\Local\Programs\Microsoft VS Code\bin'
  Add-ToPathCurrentSession -Dir $codeBin
  Add-ToUserPathPersist   -Dir $codeBin
}

function New-PythonNotesProject {
  param([Parameter(Mandatory)][string]$Root)

  $proj = Join-Path $Root $ProjectName
  New-Item -ItemType Directory -Force -Path $proj | Out-Null
  Set-Location -Path $proj

  # Initialize uv project
  Write-Host "uv init in $proj ..." -ForegroundColor Cyan
  uv init | Out-Null

  # Ensure a main.py exists for convenience
  if (-not (Test-Path '.\main.py')) {
@'
print("Hello, python-notes!")
'@ | Set-Content -NoNewline -Encoding UTF8 .\main.py
  }

  # Install latest Python + create venv and add deps
  # Strategy: uv add creates/updates pyproject and uv sync creates .venv with a suitable Python.
  $packages = @(
    'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl',
    'notebook','ipykernel'
  )
  Write-Host "Adding packages with uv: $($packages -join ', ')" -ForegroundColor Cyan
  uv add @($packages) | Out-Null

  Write-Host "Syncing environment (.venv)..." -ForegroundColor Cyan
  uv sync | Out-Null

  # Install Playwright browsers inside the project env
  Write-Host "Installing Playwright browsers..." -ForegroundColor Cyan
  uv run python -m playwright install | Out-Null

  # Create a sample notebook
  $nb = @{
    "cells" = @(
      @{
        "cell_type"="markdown";"metadata"=@{};"source"=@("# Python Notes - Getting Started", "", "Run each cell with Shift+Enter")
      },
      @{
        "cell_type"="code";"execution_count"=$null;"metadata"=@{};
        "outputs"=@();
        "source"=@(
"# Check our packages are installed",
"import sys",
"import pandas as pd",
"import pydantic",
"from bs4 import BeautifulSoup",
"import requests",
"import openpyxl",
"",
"print('Python:', sys.version)",
"print('pandas:', pd.__version__)",
"print('pydantic:', pydantic.__version__)",
"print('All packages ready!')"
        )
      },
      @{
        "cell_type"="markdown";"metadata"=@{};"source"=@("## Quick Example - Load the sample data")
      },
      @{
        "cell_type"="code";"execution_count"=$null;"metadata"=@{};
        "outputs"=@();
        "source"=@(
"# Load employee data",
"df = pd.read_csv('example-data/example-employees.csv')",
"df.head()  # Show first 5 rows"
        )
      },
      @{
        "cell_type"="code";"execution_count"=$null;"metadata"=@{};
        "outputs"=@();
        "source"=@(
"# Find high earners",
"high_earners = df[df['salary'] > 90000]",
"print(f'Found {len(high_earners)} employees making over `$90k:')",
"high_earners[['name', 'department', 'salary']]"
        )
      }
    );
    "metadata"=@{
      "kernelspec"=@{"display_name"="Python (uv)";"language"="python";"name"="python3"};
      "language_info"=@{"name"="python";"pygments_lexer"="ipython3"}
    };
    "nbformat"=4;"nbformat_minor"=5
  } | ConvertTo-Json -Depth 6

  $nb | Set-Content -Encoding UTF8 .\notebook.ipynb
  
  # Download examples.py and sample data from repo
  Write-Host "Downloading example files..." -ForegroundColor Cyan
  
  # Create data folder
  New-Item -ItemType Directory -Force -Path .\example-data | Out-Null
  
  # Download files from GitHub repo
  $repoBase = "https://raw.githubusercontent.com/johnvilsack/python-notes/main/downloads"
  
  try {
    # Get examples.py
    $examplesUrl = "$repoBase/examples.py"
    Invoke-WebRequest -Uri $examplesUrl -OutFile .\examples.py -UseBasicParsing
    Write-Host "  ✓ Downloaded examples.py" -ForegroundColor Green
  } catch {
    Write-Warning "Could not download examples.py from repo"
    # Create minimal fallback
    @'
# Examples file
print("Run examples to see what each package can do!")
print("Check the python-notes repo for the full examples.py")
'@ | Set-Content -Encoding UTF8 .\examples.py
  }
  
  try {
    # Get employees.csv
    $csvUrl = "$repoBase/example-employees.csv"
    Invoke-WebRequest -Uri $csvUrl -OutFile .\example-data\example-employees.csv -UseBasicParsing
    Write-Host "  ✓ Downloaded sample data (example-employees.csv)" -ForegroundColor Green
  } catch {
    Write-Warning "Could not download example-employees.csv from repo"
    # Create minimal fallback CSV
    @'
name,email,department,salary,start_date
Alice Johnson,alice@company.com,Engineering,95000,2021-03-15
Bob Smith,bob@company.com,Sales,65000,2022-01-10
Carol Williams,carol@company.com,Engineering,88000,2020-06-01
'@ | Set-Content -Encoding UTF8 .\example-data\example-employees.csv
  }

  # VS Code settings + workspace
  New-Item -ItemType Directory -Force -Path .\.vscode | Out-Null
  $venvPy = ".\.venv\Scripts\python.exe"
  $settings = @{
    "python.defaultInterpreterPath" = $venvPy
    "terminal.integrated.cwd"       = "\${workspaceFolder}"
    # Be explicit about notebook kernel discovery
    "jupyter.kernels.excludePythonEnvironments" = $false
  } | ConvertTo-Json -Depth 5
  $settings | Set-Content -Encoding UTF8 .\.vscode\settings.json

  # Tasks: open a terminal at startup (runOn: folderOpen)
  $tasks = @{
    "version"="2.0.0";
    "tasks"=@(@{
      "label"="Open Terminal";
      "type"="shell";
      "command"="echo Ready";
      "runOptions"=@{"runOn"="folderOpen"};
      "problemMatcher"=@()
    })
  } | ConvertTo-Json -Depth 6
  $tasks | Set-Content -Encoding UTF8 .\.vscode\tasks.json

  # Workspace file
  $ws = @{
    "folders" = @(@{"path"="."});
    "settings" = @{
      "python.defaultInterpreterPath" = $venvPy
      "terminal.integrated.cwd"       = "\${workspaceFolder}"
    }
  } | ConvertTo-Json -Depth 6
  $wsPath = Join-Path (Get-Location) "$ProjectName.code-workspace"
  $ws     | Set-Content -Encoding UTF8 $wsPath

  # VS Code extensions (Python + Jupyter)
  if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan
    Invoke-Quiet { code --install-extension ms-python.python --force }
    Invoke-Quiet { code --install-extension ms-toolsai.jupyter --force }
  } else {
    Write-Warning "VS Code CLI 'code' not found on PATH for this session; extensions will install on next run."
  }

  # Open VS Code into the workspace + files
  if (-not $SkipVSCodeOpen) {
    if (Get-Command code -ErrorAction SilentlyContinue) {
      Write-Host "Opening VS Code workspace..." -ForegroundColor Cyan
      Invoke-Quiet { code $wsPath .\main.py .\examples.py .\notebook.ipynb }
    } else {
      Write-Warning "VS Code is installed but 'code' is not on PATH for this session. Re-open terminal or run: `"`$env:Path += ';`$HOME\AppData\Local\Programs\Microsoft VS Code\bin'`" and re-run 'code'."
    }
  }

  Write-Host "Done. Project: $proj" -ForegroundColor Green
}

try {
  Ensure-UV
  Ensure-GitVSCode-GHDesktop
  New-PythonNotesProject -Root $DocumentsDir
} catch {
  Write-Error $_.Exception.Message
  exit 1
}
