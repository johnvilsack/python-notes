# Bootstrap "python-notes" on Windows 11 using uv + VS Code
# Example run (install): powershell -ExecutionPolicy Bypass -c "irm 'https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1' | iex"
# Example run (dry run + log): powershell -ExecutionPolicy Bypass -c "irm 'https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1' | iex; Start-PythonNotesBootstrap -WhatIf -Verbose -LogFile \"$env:USERPROFILE\git\python-notes-bootstrap.log\""

#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
param(
  [string]$ProjectPath = (Join-Path $env:USERPROFILE 'github\python-notes'),
  [switch]$SkipVSCodeOpen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Results = [System.Collections.Generic.List[object]]::new()
function Write-StepResult([string]$Name,[bool]$Ok,[string]$Note){
    $Results.Add([pscustomobject]@{ Step=$Name; Success=$Ok; Note=$Note })
    Write-Host "$Name => $($Ok ? 'SUCCESS' : 'FAIL') : $Note" -ForegroundColor ($Ok ? 'Green' : 'Red')
}

function Add-PathSession {
    [CmdletBinding()]
    param([string]$PathToAdd)
    if (Test-Path -LiteralPath $PathToAdd) {
        $env:Path = ((($env:Path -split ';') + $PathToAdd) | Where-Object { $_ } | Select-Object -Unique) -join ';'
    }
}

function Set-UserPathPersistent {
    [CmdletBinding()]
    param([string]$PathToAdd)
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
        [string]$ExeName,
        [string]$WingetId,
        [string]$FriendlyName = $WingetId
    )
    if (Get-Command $ExeName -ErrorAction SilentlyContinue) { return "present" }
    if (-not (Test-Winget)) { return "missing (winget unavailable)" }
    if ($PSCmdlet.ShouldProcess($FriendlyName, "Install via winget")) {
        winget install --id $WingetId -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
        Start-Sleep -Seconds 3
    }
    if (Get-Command $ExeName -ErrorAction SilentlyContinue) { return "installed" } else { return "install failed" }
}

function Invoke-Step {
    [CmdletBinding()]
    param([string]$Title,[int]$Index,[int]$Total,[scriptblock]$Action)
    Write-Host "[$Index/$Total] $Title" -ForegroundColor Cyan
    Write-Progress -Activity "python-notes bootstrap" -Status $Title -PercentComplete ([int](($Index/$Total)*100)) -Id 1
    & $Action
}

function Start-PythonNotesBootstrap {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param(
        [string]$ProjectPath = (Join-Path $env:USERPROFILE 'github\python-notes'),
        [switch]$SkipVSCodeOpen,
        [string]$LogFile
    )

    if ($PSBoundParameters.ContainsKey('LogFile')) {
        try { Start-Transcript -Path $LogFile -Append | Out-Null } catch {}
    }

    $total = 6; $i = 0

    Invoke-Step "[1/6] Install uv" (++$i) $total {
        try {
            if ($PSCmdlet.ShouldProcess("uv","Install")) {
                powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex" 2>$null
            }
            $UserBin = Join-Path $HOME '.local\bin'
            Add-PathSession $UserBin
            Set-UserPathPersistent $UserBin
            if (-not (Get-Command uv -ErrorAction SilentlyContinue)) { throw "uv not on PATH" }
            Write-StepResult "[1/6] uv" $true "ready: $(uv --version)"
        } catch { Write-StepResult "[1/6] uv" $false $_.Exception.Message }
    }

    Invoke-Step "[2/6] Create project + venv" (++$i) $total {
        try {
            if ($PSCmdlet.ShouldProcess($ProjectPath, "Create directory")) {
                New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
            }
            Set-Location $ProjectPath
            if ($PSCmdlet.ShouldProcess("$ProjectPath", "uv init")) { uv init | Out-Null }
            if ($PSCmdlet.ShouldProcess("$ProjectPath", "Create venv + install Python")) {
                uv python install --python latest | Out-Null
                uv venv .venv | Out-Null
            }
            if (-not (Test-Path .\.venv\Scripts\python.exe)) { throw "Venv interpreter missing" }
            Write-StepResult "[2/6] Project" $true ".venv ready"
        } catch { Write-StepResult "[2/6] Project" $false $_.Exception.Message }
    }

    Invoke-Step "[3/6] Install packages" (++$i) $total {
        try {
            $pkgs = 'pandas','pydantic','beautifulsoup4','playwright','requests','openpyxl','notebook','ipykernel'
            if ($PSCmdlet.ShouldProcess(".venv", "uv add")) {
                uv add $pkgs | Out-Null
                uv run python -m playwright install | Out-Null
            }
            Write-StepResult "[3/6] Env" $true "packages ready"
        } catch { Write-StepResult "[3/6] Env" $false $_.Exception.Message }
    }

    Invoke-Step "[4/6] Download examples/data" (++$i) $total {
        try {
            $repo = "https://raw.githubusercontent.com/johnvilsack/python-notes/main/downloads"
            if ($PSCmdlet.ShouldProcess("examples.py","Download")) {
                Invoke-WebRequest -Uri "$repo/examples.py" -OutFile .\examples.py -UseBasicParsing -ErrorAction SilentlyContinue
            }
            New-Item -ItemType Directory -Force -Path .\example-data | Out-Null
            if ($PSCmdlet.ShouldProcess("example-employees.csv","Download")) {
                Invoke-WebRequest -Uri "$repo/example-employees.csv" -OutFile .\example-data\example-employees.csv -UseBasicParsing -ErrorAction SilentlyContinue
            }
            Write-StepResult "[4/6] Content" $true "examples ready"
        } catch { Write-StepResult "[4/6] Content" $false $_.Exception.Message }
    }

    Invoke-Step "[5/6] Install tools" (++$i) $total {
        try {
            $gitStatus = Install-ToolIfMissing 'git.exe' 'Git.Git'
            $vscStatus = Install-ToolIfMissing 'code.cmd' 'Microsoft.VisualStudioCode'
            $ghdStatus = Install-ToolIfMissing 'github' 'GitHub.GitHubDesktop'

            $CodeBin = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'
            Add-PathSession $CodeBin
            Set-UserPathPersistent $CodeBin

            if (Get-Command code -ErrorAction SilentlyContinue) {
                if ($PSCmdlet.ShouldProcess("VS Code", "Install Python & Jupyter extensions")) {
                    code --install-extension ms-python.python --force | Out-Null
                    code --install-extension ms-toolsai.jupyter --force | Out-Null
                }
            }
            Write-StepResult "[5/6] Tools" $true "git:$gitStatus; vscode:$vscStatus; gh-desktop:$ghdStatus"
        } catch { Write-StepResult "[5/6] Tools" $false $_.Exception.Message }
    }

    Invoke-Step "[6/6] VS Code config" (++$i) $total {
        try {
            New-Item -ItemType Directory -Force -Path .\.vscode | Out-Null
            $venvPy = ".\\.venv\\Scripts\\python.exe"
            @{
                "python.defaultInterpreterPath" = $venvPy
                "python.terminal.activateEnvironment" = $true
                "terminal.integrated.cwd" = "`$\{workspaceFolder}"
            } | ConvertTo-Json | Set-Content -Encoding UTF8 .\.vscode\settings.json

            $ws = @{
                "folders"  = @(@{"path"="."});
                "settings" = @{
                    "python.defaultInterpreterPath" = $venvPy
                    "python.terminal.activateEnvironment" = $true
                    "terminal.integrated.cwd" = "`$\{workspaceFolder}"
                }
            } | ConvertTo-Json -Depth 5
            $wsPath = Join-Path (Get-Location) "python-notes.code-workspace"
            $ws | Set-Content -Encoding UTF8 $wsPath

            if (-not $SkipVSCodeOpen -and (Get-Command code -ErrorAction SilentlyContinue)) {
                if ($PSCmdlet.ShouldProcess("VS Code","Open workspace & files")) {
                    code $wsPath .\main.py .\examples.py .\notebook.ipynb | Out-Null
                }
            }
            Write-StepResult "[6/6] VS Code" $true "workspace ready"
        } catch { Write-StepResult "[6/6] VS Code" $false $_.Exception.Message }
    }

    Write-Progress -Activity "python-notes bootstrap" -Completed -Id 1
    $Results | Format-Table -AutoSize
    if ($PSBoundParameters.ContainsKey('LogFile')) { try { Stop-Transcript | Out-Null } catch {} }
}

if ($MyInvocation.InvocationName -ne '.') {
    Start-PythonNotesBootstrap -ProjectPath $ProjectPath -SkipVSCodeOpen:$SkipVSCodeOpen
}
