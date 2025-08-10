param(
  [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Gather initial state
$ProjectPath = Join-Path $env:USERPROFILE 'github\python-notes'
$CodeBin = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'

# Check what existed before
$Existed = @{
  Git = (Get-Command git.exe -ErrorAction SilentlyContinue) -ne $null
  VSCode = (Get-Command code.cmd -ErrorAction SilentlyContinue) -ne $null
  GitHubDesktop = (Get-Command github -ErrorAction SilentlyContinue) -ne $null
  UV = (Get-Command uv.exe -ErrorAction SilentlyContinue) -ne $null
}

# PATH snapshots
$OriginalUserPath = ([Environment]::GetEnvironmentVariable('Path','User').Split(';') | Where-Object { $_ })
$OriginalSessionPath = $env:Path.Split(';') | Where-Object { $_ }

function Revert-Environment {
  Write-Verbose "Restoring session PATH"
  $env:Path = ($OriginalSessionPath -join ';')

  Write-Verbose "Restoring user PATH"
  [Environment]::SetEnvironmentVariable('Path', ($OriginalUserPath -join ';'), 'User')
}

function Uninstall-ViaWinget($id, $friendly) {
  if ($PSCmdlet.ShouldProcess($friendly, "Uninstall via winget")) {
    winget uninstall --id $id -e --silent *>$null
  }
}

function Revert-Changes {
  Revert-Environment

  if (-not $Existed.Git) {
    Uninstall-ViaWinget -id 'Git.Git' -friendly 'Git'
  }
  if (-not $Existed.VSCode) {
    Uninstall-ViaWinget -id 'Microsoft.VisualStudioCode' -friendly 'Visual Studio Code'
  }
  if (-not $Existed.GitHubDesktop) {
    Uninstall-ViaWinget -id 'GitHub.GitHubDesktop' -friendly 'GitHub Desktop'
  }

  if (-not $Existed.UV) {
    Uninstall-ViaWinget -id 'astral.uv' -friendly 'uv' # adjust ID if needed
  }

  if (Test-Path $ProjectPath) {
    Write-Verbose "Removing project folder"
    Remove-Item -LiteralPath $ProjectPath -Recurse -Force -WhatIf:$WhatIf
  }

  # Remove VS Code CLI path if we added it
  if ($OriginalUserPath -notcontains $CodeBin -and (Test-Path $CodeBin)) {
    Write-Verbose "Removing VS Code CLI path from user PATH"
    $new = $OriginalUserPath | Where-Object { $_ -ne $CodeBin }
    [Environment]::SetEnvironmentVariable('Path', ($new -join ';'), 'User')
  }

  return
}

Revert-Changes
