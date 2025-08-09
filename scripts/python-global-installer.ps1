# Global Python Install - Windows 11
# Run as Administrator: powershell -ExecutionPolicy Bypass -File .\python-global-installer.ps1

#Requires -RunAsAdministrator

param(
    [string]$PythonVersion = '3.12'
)

$ErrorActionPreference = 'Stop'

Write-Host "`nGlobal Python Installer" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

# Install uv
Write-Host "`n[1/3] Installing uv..." -ForegroundColor Yellow
powershell -c "irm https://astral.sh/uv/install.ps1 | iex" *>$null

# Update PATH
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$env:Path += ";$HOME\.local\bin"

# Install Python
Write-Host "[2/3] Installing Python $PythonVersion..." -ForegroundColor Yellow
uv python install $PythonVersion *>$null
uv python pin --global $PythonVersion *>$null

# Install packages globally
Write-Host "[3/3] Installing packages..." -ForegroundColor Yellow
$packages = 'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl'

foreach ($pkg in $packages) {
    uv pip install --system $pkg *>$null
}

# Install Jupyter as tool
uv tool install jupyter *>$null

# Install Playwright browsers
uv run --system python -m playwright install chromium *>$null

Write-Host "`n✓ Complete!" -ForegroundColor Green
Write-Host "`nVerify installation:" -ForegroundColor Gray
Write-Host "  python --version" -ForegroundColor Gray
Write-Host "  uv pip list" -ForegroundColor Gray
Write-Host "`nCreate a project:" -ForegroundColor Gray
Write-Host "  mkdir myproject" -ForegroundColor Gray
Write-Host "  cd myproject" -ForegroundColor Gray
Write-Host "  uv init" -ForegroundColor Gray
