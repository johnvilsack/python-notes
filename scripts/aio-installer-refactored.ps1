# Bootstrap python-notes project - Windows 11
# Run: powershell -ExecutionPolicy Bypass -c "irm URL | iex"

param(
    [string]$ProjectPath = "$HOME\Documents\python-notes"
)

$ErrorActionPreference = 'Stop'

Write-Host "`nPython + AI Bootstrap" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

# Install uv
Write-Host "`n[1/5] Installing uv..." -ForegroundColor Yellow
powershell -c "irm https://astral.sh/uv/install.ps1 | iex" *>$null

# Update PATH for this session
$env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')
$env:Path += ";$HOME\.local\bin"

# Create project
Write-Host "[2/5] Creating project..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
Set-Location $ProjectPath

# Initialize and install packages
uv init *>$null
Write-Host "[3/5] Installing Python + packages..." -ForegroundColor Yellow
$packages = 'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl','notebook','ipykernel'
uv add $packages *>$null
uv run python -m playwright install chromium *>$null

# Download examples
Write-Host "[4/5] Getting examples..." -ForegroundColor Yellow
$repo = "https://raw.githubusercontent.com/johnvilsack/python-notes/main/downloads"

# Get examples.py
try {
    Invoke-WebRequest -Uri "$repo/examples.py" -OutFile .\examples.py -UseBasicParsing
} catch {
    @'
print("Hello from python-notes!")
print("Check the repo for full examples.py")
'@ | Set-Content .\examples.py
}

# Get sample data
New-Item -ItemType Directory -Force -Path .\example-data | Out-Null
try {
    Invoke-WebRequest -Uri "$repo/example-employees.csv" -OutFile .\example-data\example-employees.csv -UseBasicParsing
} catch {
    @'
name,email,department,salary,start_date
Alice Johnson,alice@company.com,Engineering,95000,2021-03-15
Bob Smith,bob@company.com,Sales,65000,2022-01-10
'@ | Set-Content .\example-data\example-employees.csv
}

# Create notebook
@'
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": ["# Quick Start\n", "Run cells with Shift+Enter"]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {},
      "outputs": [],
      "source": ["import pandas as pd\n", "df = pd.read_csv('example-data/example-employees.csv')\n", "df.head()"]
    }
  ],
  "metadata": {
    "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
'@ | Set-Content notebook.ipynb

# Install tools if missing
Write-Host "[5/5] Checking tools..." -ForegroundColor Yellow
$tools = @(
    @{id='Git.Git'; name='Git'},
    @{id='Microsoft.VisualStudioCode'; name='VSCode'},
    @{id='GitHub.GitHubDesktop'; name='GitHub Desktop'}
)

foreach ($tool in $tools) {
    if (-not (winget list --id $tool.id --exact 2>$null | Select-String $tool.id)) {
        Write-Host "  Installing $($tool.name)..." -ForegroundColor Gray
        winget install --id $tool.id -e --silent --accept-source-agreements --accept-package-agreements *>$null
    }
}

# Setup VSCode
$codePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
if (Test-Path $codePath) {
    $env:Path += ";$codePath"
    
    # Install extensions
    code --install-extension ms-python.python --force *>$null
    code --install-extension ms-toolsai.jupyter --force *>$null
    
    # Create workspace
    New-Item -ItemType Directory -Force -Path .\.vscode | Out-Null
    @{
        "python.defaultInterpreterPath" = ".\.venv\Scripts\python.exe"
    } | ConvertTo-Json | Set-Content .\.vscode\settings.json
    
    # Open everything
    code . .\main.py .\examples.py .\notebook.ipynb *>$null
}

Write-Host "`n✓ Complete!" -ForegroundColor Green
Write-Host "  Location: $ProjectPath" -ForegroundColor Gray
Write-Host "  Run code: uv run examples.py" -ForegroundColor Gray
Write-Host "  VSCode opened with all files ready" -ForegroundColor Gray
