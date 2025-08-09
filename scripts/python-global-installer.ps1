# Windows 11 Global Python Installation Script
# Installs Python globally via uv and common data science packages
# Run: powershell -ExecutionPolicy Bypass -File .\python-global-installer.ps1

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$PythonVersion = '3.12',  # Default to stable 3.12
    [switch]$SkipPackages,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Check admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "This script requires Administrator privileges. Run PowerShell as Administrator."
}

function Test-InternetConnection {
    try {
        $null = Invoke-WebRequest -Uri 'https://astral.sh' -Method Head -TimeoutSec 5 -UseBasicParsing
        return $true
    } catch {
        return $false
    }
}

function Ensure-UV {
    # Check if uv already exists
    if ((Get-Command uv -ErrorAction SilentlyContinue) -and -not $Force) {
        Write-Host "uv is already installed: $(uv --version)" -ForegroundColor Green
        return
    }

    Write-Host "Installing uv package manager..." -ForegroundColor Cyan
    
    # Download and install uv
    try {
        $installScript = Invoke-WebRequest -Uri 'https://astral.sh/uv/install.ps1' -UseBasicParsing
        Invoke-Expression $installScript.Content
    } catch {
        throw "Failed to install uv: $_"
    }

    # Update PATH for current session
    $uvPath = Join-Path $env:LOCALAPPDATA 'uv\bin'
    if (Test-Path $uvPath) {
        $env:Path = "$uvPath;$env:Path"
    }

    # Verify installation
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "uv installation completed but command not found. Try restarting PowerShell."
    }

    Write-Host "uv installed successfully: $(uv --version)" -ForegroundColor Green
}

function Install-GlobalPython {
    param([string]$Version)

    Write-Host "Installing Python $Version globally..." -ForegroundColor Cyan
    
    # Install Python using uv
    $pythonList = uv python list 2>$null | Out-String
    if ($pythonList -match "cpython-$Version") {
        if (-not $Force) {
            Write-Host "Python $Version is already available" -ForegroundColor Yellow
            return
        }
    }

    try {
        uv python install $Version
        Write-Host "Python $Version installed successfully" -ForegroundColor Green
    } catch {
        throw "Failed to install Python $Version: $_"
    }

    # Make it the default global Python
    Write-Host "Setting Python $Version as global default..." -ForegroundColor Cyan
    uv python pin $Version --system
}

function Install-GlobalPackages {
    Write-Host "`nInstalling global Python packages..." -ForegroundColor Cyan
    
    $packages = @(
        'pandas',           # Data manipulation
        'numpy',            # Numerical computing
        'pydantic',         # Data validation
        'beautifulsoup4',   # Web scraping
        'playwright',       # Browser automation
        'requests',         # HTTP library
        'openpyxl',         # Excel files
        'notebook',         # Jupyter notebooks
        'ipykernel',        # Jupyter kernel
        'matplotlib',       # Plotting
        'seaborn',          # Statistical plots
        'scipy',            # Scientific computing
        'scikit-learn',     # Machine learning
        'pillow',           # Image processing
        'python-dotenv',    # Environment variables
        'rich',             # Terminal formatting
        'typer',            # CLI apps
        'httpx',            # Modern HTTP client
        'polars',           # Fast dataframes
        'xlsxwriter'        # Excel writer
    )

    Write-Host "Packages to install: $($packages -join ', ')" -ForegroundColor Gray

    # Install packages globally using uv tool
    foreach ($package in $packages) {
        Write-Host "  Installing $package..." -NoNewline
        try {
            # Install as a global tool where applicable
            if ($package -in @('notebook', 'ipykernel')) {
                uv tool install $package --force 2>&1 | Out-Null
            } else {
                # For libraries, we'll use pip via uv
                uv pip install --system $package 2>&1 | Out-Null
            }
            Write-Host " ✓" -ForegroundColor Green
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Warning "Failed to install $package: $_"
        }
    }

    # Special handling for Playwright browsers
    Write-Host "`nInstalling Playwright browsers..." -ForegroundColor Cyan
    try {
        $pythonCmd = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' } else { 'python3' }
        & $pythonCmd -m playwright install
        Write-Host "Playwright browsers installed successfully" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to install Playwright browsers: $_"
        Write-Host "You can install them later with: python -m playwright install" -ForegroundColor Yellow
    }
}

function Add-PythonToSystemPath {
    Write-Host "`nConfiguring system PATH..." -ForegroundColor Cyan
    
    # Get Python location from uv
    $pythonInfo = uv python list --only-installed 2>$null | Out-String
    if ($pythonInfo -match "cpython-$PythonVersion.*?(?<path>[^\s]+)") {
        $pythonDir = Split-Path $Matches.path -Parent
        
        # Add to system PATH if not already there
        $currentPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        if ($currentPath -notlike "*$pythonDir*") {
            [Environment]::SetEnvironmentVariable('Path', "$pythonDir;$currentPath", 'Machine')
            Write-Host "Added Python to system PATH" -ForegroundColor Green
        }
    }
}

function Install-UsefulTools {
    Write-Host "`nInstalling additional Python tools..." -ForegroundColor Cyan
    
    $tools = @(
        @{name='ruff'; desc='Fast Python linter'},
        @{name='black'; desc='Code formatter'},
        @{name='mypy'; desc='Static type checker'},
        @{name='poetry'; desc='Dependency management'},
        @{name='pipx'; desc='Install Python applications'},
        @{name='pre-commit'; desc='Git hook framework'}
    )

    foreach ($tool in $tools) {
        Write-Host "  Installing $($tool.name) ($($tool.desc))..." -NoNewline
        try {
            uv tool install $tool.name --force 2>&1 | Out-Null
            Write-Host " ✓" -ForegroundColor Green
        } catch {
            Write-Host " ✗" -ForegroundColor Red
        }
    }
}

function Show-PostInstallInfo {
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host "Global Python Installation Complete!" -ForegroundColor Green
    Write-Host "="*60 -ForegroundColor Cyan
    
    Write-Host "`nInstalled Components:" -ForegroundColor Yellow
    Write-Host "  • Python $PythonVersion (global)"
    Write-Host "  • uv package manager"
    if (-not $SkipPackages) {
        Write-Host "  • Data science packages (pandas, numpy, etc.)"
        Write-Host "  • Development tools (ruff, black, mypy, etc.)"
    }
    
    Write-Host "`nVerify Installation:" -ForegroundColor Yellow
    Write-Host "  python --version"
    Write-Host "  uv --version"
    Write-Host "  python -c `"import pandas; print('pandas', pandas.__version__)`""
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart your terminal to ensure PATH updates"
    Write-Host "  2. Run 'uv' to see available commands"
    Write-Host "  3. Use 'uv pip install' to add more packages"
    Write-Host "  4. Use 'uv tool install' for Python applications"
    
    Write-Host "`nTip: Create virtual environments with:" -ForegroundColor Cyan
    Write-Host "  uv venv"
    Write-Host "  .\.venv\Scripts\Activate.ps1"
}

# Main execution
try {
    Write-Host "Global Python Installer for Windows 11" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    
    # Pre-flight checks
    if (-not (Test-InternetConnection)) {
        throw "No internet connection detected. This script requires internet access."
    }
    
    # Core installation steps
    Ensure-UV
    Install-GlobalPython -Version $PythonVersion
    
    if (-not $SkipPackages) {
        Install-GlobalPackages
        Install-UsefulTools
    }
    
    Add-PythonToSystemPath
    Show-PostInstallInfo
    
} catch {
    Write-Error "Installation failed: $_"
    exit 1
}