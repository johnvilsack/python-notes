<#
Reverse-Uno (Bootstrap Cleanup) — Windows PowerShell 5.1+ compatible

Checklist (what this script will undo):
  [ ] Stop VS Code if running
  [ ] Remove project folder:  %USERPROFILE%\github\python-notes
  [ ] Uninstall VS Code (winget)
  [ ] Uninstall Git (winget)
  [ ] Uninstall GitHub Desktop (winget)
  [ ] Uninstall uv (per Astral docs: clean data, remove dirs, remove binaries)
  [ ] Remove Playwright browser cache: %USERPROFILE%\AppData\Local\ms-playwright
  [ ] Remove PATH entries added by bootstrap (VS Code bin, ~/.local/bin if safe)
  [ ] Rebuild current session PATH from Machine+User registry so this shell sees changes
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---- Paths and constants (mirror the bootstrap) ----
$ProjectPath     = Join-Path $env:USERPROFILE 'github\python-notes'
$CodeBin         = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'
$UserLocalBin    = Join-Path $HOME '.local\bin'
$MsPlaywrightDir = Join-Path $env:USERPROFILE 'AppData\Local\ms-playwright'

# Winget package IDs used by the bootstrap
$Winget = @{
  Git   = 'Git.Git'
  VSCode = 'Microsoft.VisualStudioCode'
  GitHubDesktop = 'GitHub.GitHubDesktop'
}

# ---- Result accumulator for end-of-run summary ----
$Results = [System.Collections.Generic.List[object]]::new()
function Add-Result {
  param([string]$Step,[bool]$Ok,[string]$Note)
  $Results.Add([pscustomobject]@{ Step=$Step; Success=$Ok; Note=$Note })
  if ($Ok) { Write-Host "[✓] $Step — $Note" -ForegroundColor Green }
  else     { Write-Host "[x] $Step — $Note" -ForegroundColor Red   }
}

# ---- Utility: rebuild PATH for THIS process from registry (Machine + User) ----
function Restore-SessionPathFromRegistry {
  [CmdletBinding()]
  param()
  Write-Host " → Rebuilding current session PATH from registry" -ForegroundColor Cyan
  try {
    $m = [Environment]::GetEnvironmentVariable('Path','Machine')
    $u = [Environment]::GetEnvironmentVariable('Path','User')
    $env:Path = @($m,$u) -join ';'
    Add-Result "Rebuild session PATH" $true "ok"
  } catch {
    Add-Result "Rebuild session PATH" $false $_.Exception.Message
  }
}

# ---- Utility: remove one entry from USER PATH (registry) ----
function Remove-UserPathEntry {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param([Parameter(Mandatory)][string]$Entry)
  try {
    $current = [Environment]::GetEnvironmentVariable('Path','User').Split(';') | Where-Object { $_ }
    if ($current -contains $Entry) {
      if ($PSCmdlet.ShouldProcess("User PATH","Remove '$Entry'")) {
        $new = $current | Where-Object { $_ -ne $Entry }
        [Environment]::SetEnvironmentVariable('Path', ($new -join ';'), 'User')
      }
      Add-Result "Remove User PATH entry" $true "'$Entry'"
    } else {
      Add-Result "Remove User PATH entry" $true "'$Entry' not present"
    }
  } catch {
    Add-Result "Remove User PATH entry" $false $_.Exception.Message
  }
}

# ---- Step: Stop VS Code if running ----
function Stop-VSCodeIfRunning {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param()
  try {
    $procs = Get-Process -Name 'Code' -ErrorAction SilentlyContinue
    if ($null -ne $procs) {
      if ($PSCmdlet.ShouldProcess("VS Code process","Stop")) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
      }
      Add-Result "Stop VS Code" $true "stopped"
    } else {
      Add-Result "Stop VS Code" $true "not running"
    }
  } catch { Add-Result "Stop VS Code" $false $_.Exception.Message }
}

# ---- Step: Remove project folder ----
function Remove-ProjectFolder {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param()
  try {
    if (Test-Path -LiteralPath $ProjectPath) {
      if ($PSCmdlet.ShouldProcess($ProjectPath,"Remove project directory")) {
        Remove-Item -LiteralPath $ProjectPath -Recurse -Force
      }
      Add-Result "Remove project folder" $true $ProjectPath
    } else {
      Add-Result "Remove project folder" $true "not found"
    }
  } catch { Add-Result "Remove project folder" $false $_.Exception.Message }
}

# ---- Step: Uninstall via winget (Git, VS Code, GitHub Desktop) ----
function Uninstall-WithWinget {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory)][string]$Id,
    [Parameter(Mandatory)][string]$FriendlyName,
    [Parameter(Mandatory)][string]$ExeNameToProbe  # e.g., git.exe / code.cmd / github
  )
  try {
    $hadCmd = (Get-Command $ExeNameToProbe -ErrorAction SilentlyContinue) -ne $null
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
      Add-Result "Uninstall $FriendlyName" $false "winget not available"
      return
    }
    if ($PSCmdlet.ShouldProcess($FriendlyName,"winget uninstall")) {
      winget uninstall --id $Id -e --silent --source winget | Out-Null
    }
    # Refresh PATH for this session so Get-Command re-check is accurate
    Restore-SessionPathFromRegistry | Out-Null
    $stillThere = (Get-Command $ExeNameToProbe -ErrorAction SilentlyContinue) -ne $null
    if (-not $stillThere) {
      Add-Result "Uninstall $FriendlyName" $true "removed"
    } else {
      # Sometimes uninstallers keep a stub until you open a new shell. Mark status.
      Add-Result "Uninstall $FriendlyName" ($hadCmd -eq $false) "installer state ambiguous (command still resolves); open a new shell to validate"
    }
  } catch { Add-Result "Uninstall $FriendlyName" $false $_.Exception.Message }
}

# ---- Step: Uninstall uv exactly as documented ----
function Uninstall-UV {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param()
  try {
    $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
    if ($null -ne $uvCmd) {
      # 1) Clean data
      if ($PSCmdlet.ShouldProcess("uv cache/data","Clean")) {
        try { uv cache clean | Out-Null } catch {}
        try {
          $pyDir = (uv python dir) 2>$null
          if ($pyDir) { Remove-Item -LiteralPath $pyDir -Recurse -Force -ErrorAction SilentlyContinue }
        } catch {}
        try {
          $toolDir = (uv tool dir) 2>$null
          if ($toolDir) { Remove-Item -LiteralPath $toolDir -Recurse -Force -ErrorAction SilentlyContinue }
        } catch {}
      }
    }

    # 2) Remove binaries in ~/.local/bin
    $uvExe  = Join-Path $UserLocalBin 'uv.exe'
    $uvxExe = Join-Path $UserLocalBin 'uvx.exe'
    if (Test-Path -LiteralPath $uvExe) {
      if ($PSCmdlet.ShouldProcess($uvExe,"Remove")) { Remove-Item -LiteralPath $uvExe -Force }
    }
    if (Test-Path -LiteralPath $uvxExe) {
      if ($PSCmdlet.ShouldProcess($uvxExe,"Remove")) { Remove-Item -LiteralPath $uvxExe -Force }
    }

    # Optional: if ~/.local/bin is now empty OR contains only benign leftovers, remove from User PATH
    $safeToDropLocalBin = $false
    if (Test-Path -LiteralPath $UserLocalBin) {
      $children = Get-ChildItem -LiteralPath $UserLocalBin -Force -ErrorAction SilentlyContinue
      if ($null -eq $children -or $children.Count -eq 0) { $safeToDropLocalBin = $true }
    }
    if ($safeToDropLocalBin) {
      Remove-UserPathEntry -Entry $UserLocalBin
    } else {
      Add-Result "Prune ~/.local/bin from PATH" $true "left in PATH (not empty)"
    }

    # Verify
    Restore-SessionPathFromRegistry | Out-Null
    $gone = (Get-Command uv -ErrorAction SilentlyContinue) -eq $null
    Add-Result "Uninstall uv" $gone ($(if ($gone) { "removed" } else { "may require new shell to disappear from PATH" }))
  } catch { Add-Result "Uninstall uv" $false $_.Exception.Message }
}

# ---- Step: Remove Playwright browsers cache ----
function Remove-PlaywrightCache {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param()
  try {
    if (Test-Path -LiteralPath $MsPlaywrightDir) {
      if ($PSCmdlet.ShouldProcess($MsPlaywrightDir,"Remove Playwright browsers cache")) {
        Remove-Item -LiteralPath $MsPlaywrightDir -Recurse -Force
      }
      Add-Result "Remove Playwright browsers" $true $MsPlaywrightDir
    } else {
      Add-Result "Remove Playwright browsers" $true "no cache found"
    }
  } catch { Add-Result "Remove Playwright browsers" $false $_.Exception.Message }
}

# ---- Step: Remove VS Code bin path from User PATH (after VS Code uninstall) ----
function Prune-VSCodePath {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param()
  try {
    # Only remove if VS Code is gone or bin dir no longer exists
    $vscodeGone = (Get-Command code -ErrorAction SilentlyContinue) -eq $null
    $binExists  = Test-Path -LiteralPath $CodeBin
    if ($vscodeGone -or (-not $binExists)) {
      Remove-UserPathEntry -Entry $CodeBin
    } else {
      Add-Result "Remove VS Code bin PATH" $true "kept (VS Code still present)"
    }
  } catch { Add-Result "Remove VS Code bin PATH" $false $_.Exception.Message }
}

# ------------------- EXECUTION -------------------
Write-Host "=== Reverse-Uno Cleanup — Starting ===" -ForegroundColor Yellow
Write-Host "Dry run: $WhatIf" -ForegroundColor DarkGray

# 1) Stop VS Code
Stop-VSCodeIfRunning

# 2) Remove project folder
Remove-ProjectFolder

# 3) Uninstall apps (winget)
Uninstall-WithWinget -Id $Winget.VSCode        -FriendlyName 'Visual Studio Code' -ExeNameToProbe 'code.cmd'
Uninstall-WithWinget -Id $Winget.Git           -FriendlyName 'Git'                -ExeNameToProbe 'git.exe'
Uninstall-WithWinget -Id $Winget.GitHubDesktop -FriendlyName 'GitHub Desktop'     -ExeNameToProbe 'github'

# 4) Uninstall uv properly
Uninstall-UV

# 5) Remove Playwright browsers cache
Remove-PlaywrightCache

# 6) Prune User PATH entries added by bootstrap
Prune-VSCodePath
# ~/.local/bin handled inside Uninstall-UV (only removed if directory is empty)

# 7) Rebuild current session PATH so this shell sees the registry changes
Restore-SessionPathFromRegistry

Write-Host "=== Reverse-Uno Cleanup — Complete ===`n" -ForegroundColor Yellow

# Final checklist summary
$Results | Format-Table -AutoSize
