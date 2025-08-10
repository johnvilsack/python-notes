<#
Reverse-Uno (Full Cleanup) — Windows PowerShell 5.1+ compatible

Checklist (this script will):
  [ ] Stop VS Code
  [ ] Remove project:           %USERPROFILE%\github\python-notes
  [ ] Remove project venv:      %USERPROFILE%\github\python-notes\.venv (covered by folder remove)
  [ ] Uninstall via winget:     Visual Studio Code, Git, GitHub Desktop
  [ ] Remove VS Code install dir (if left): %LOCALAPPDATA%\Programs\Microsoft VS Code
  [ ] Uninstall uv (per Astral docs): cache clean, remove uv python/tool dirs, delete ~/.local/bin\uv*.exe
  [ ] Remove Playwright browsers: %USERPROFILE%\AppData\Local\ms-playwright
  [ ] Purge VS Code user data:   %APPDATA%\Code\User (settings, keybindings, globalStorage, workspaceStorage, Backups)
  [ ] Purge VS Code caches:      %APPDATA%\Code\Cache, %APPDATA%\Code\CachedData, %APPDATA%\Code\Backups
  [ ] Purge VS Code extensions:  %USERPROFILE%\.vscode\extensions
  [ ] Prune PATH entries:        VS Code bin, ~/.local/bin (when safe)
  [ ] Rebuild current session PATH from registry (Machine + User)
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Paths mirroring bootstrap and VS Code defaults ---
$ProjectPath         = Join-Path $env:USERPROFILE 'github\python-notes'
$CodeBin             = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'           # code.cmd lives here
$VSCodeInstallDir    = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code'               # default install dir
$UserLocalBin        = Join-Path $HOME '.local\bin'                                           # uv shims
$MsPlaywrightDir     = Join-Path $env:USERPROFILE 'AppData\Local\ms-playwright'               # Playwright browsers
$VSCodeUserDir       = Join-Path $env:APPDATA 'Code\User'                                     # settings.json, globalStorage, workspaceStorage, Backups
$VSCodeCacheDir      = Join-Path $env:APPDATA 'Code\Cache'
$VSCodeCachedDataDir = Join-Path $env:APPDATA 'Code\CachedData'
$VSCodeBackupsDir    = Join-Path $env:APPDATA 'Code\Backups'
$VSCodeExtensionsDir = Join-Path $env:USERPROFILE '.vscode\extensions'

# winget IDs used by bootstrap
$Winget = @{
  Git            = 'Git.Git'
  VSCode         = 'Microsoft.VisualStudioCode'
  GitHubDesktop  = 'GitHub.GitHubDesktop'
}

# --- Results table ---
$Results = [System.Collections.Generic.List[object]]::new()
function Add-Result {
  param([string]$Step,[bool]$Ok,[string]$Note)
  $Results.Add([pscustomobject]@{ Step=$Step; Success=$Ok; Note=$Note })
  if ($Ok) { Write-Host "[✓] $Step — $Note" -ForegroundColor Green }
  else     { Write-Host "[x] $Step — $Note" -ForegroundColor Red   }
}

# --- Utilities ---
function Rebuild-SessionPathFromRegistry {
  [CmdletBinding()]
  param()
  try {
    $m = [Environment]::GetEnvironmentVariable('Path','Machine')
    $u = [Environment]::GetEnvironmentVariable('Path','User')
    $env:Path = @($m,$u) -join ';'
    Add-Result "Rebuild session PATH" $true "ok"
  } catch { Add-Result "Rebuild session PATH" $false $_.Exception.Message }
}

function Remove-UserPathEntry {
  [CmdletBinding(SupportsShouldProcess = $true)]
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
  } catch { Add-Result "Remove User PATH entry" $false $_.Exception.Message }
}

function Remove-Tree {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param([Parameter(Mandatory)][string]$Path)
  try {
    if (Test-Path -LiteralPath $Path) {
      if ($PSCmdlet.ShouldProcess($Path,"Remove directory tree")) {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
      }
      Add-Result "Remove directory" $true $Path
    } else {
      Add-Result "Remove directory" $true "$Path (not found)"
    }
  } catch { Add-Result "Remove directory" $false "$Path :: $($_.Exception.Message)" }
}

# --- Steps ---
function Stop-VSCode {
  [CmdletBinding(SupportsShouldProcess = $true)]
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

function Remove-Project {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param()
  Remove-Tree -Path $ProjectPath
}

function Uninstall-WithWinget {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory)][string]$Id,
    [Parameter(Mandatory)][string]$FriendlyName,
    [Parameter(Mandatory)][string]$ExeProbe
  )
  try {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
      Add-Result "Uninstall $FriendlyName" $false "winget not available"
      return
    }
    if ($PSCmdlet.ShouldProcess($FriendlyName,"winget uninstall")) {
      winget uninstall --id $Id -e --silent --source winget | Out-Null
    }
    # refresh session PATH so Get-Command re-check is meaningful
    Rebuild-SessionPathFromRegistry | Out-Null
    $still = (Get-Command $ExeProbe -ErrorAction SilentlyContinue)
    $ok = ($null -eq $still)
    Add-Result "Uninstall $FriendlyName" $ok ($(if ($ok) { "removed" } else { "command still resolves (new shell may be required)" }))
  } catch { Add-Result "Uninstall $FriendlyName" $false $_.Exception.Message }
}

function Uninstall-UV {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param()
  try {
    $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
    if ($null -ne $uvCmd) {
      # 1) Clean data & remove managed dirs
      if ($PSCmdlet.ShouldProcess("uv cache/data","Clean/remove")) {
        try { uv cache clean | Out-Null } catch {}
        try { $p = (uv python dir) 2>$null; if ($p) { Remove-Tree -Path $p } } catch {}
        try { $t = (uv tool dir)   2>$null; if ($t) { Remove-Tree -Path $t } } catch {}
      }
    }
    # 2) Remove shims
    $uvExe  = Join-Path $UserLocalBin 'uv.exe'
    $uvxExe = Join-Path $UserLocalBin 'uvx.exe'
    if (Test-Path -LiteralPath $uvExe)  { if ($PSCmdlet.ShouldProcess($uvExe, "Remove"))  { Remove-Item -LiteralPath $uvExe  -Force -ErrorAction SilentlyContinue } }
    if (Test-Path -LiteralPath $uvxExe) { if ($PSCmdlet.ShouldProcess($uvxExe,"Remove"))  { Remove-Item -LiteralPath $uvxExe -Force -ErrorAction SilentlyContinue } }

    # 3) Optionally prune ~/.local/bin from PATH if empty after removals
    $safeDrop = $false
    if (Test-Path -LiteralPath $UserLocalBin) {
      $items = Get-ChildItem -LiteralPath $UserLocalBin -Force -ErrorAction SilentlyContinue
      if ($null -eq $items -or $items.Count -eq 0) { $safeDrop = $true }
    }
    if ($safeDrop) { Remove-UserPathEntry -Entry $UserLocalBin } else { Add-Result "Prune ~/.local/bin" $true "kept (not empty)" }

    # Verify disappearance in current shell
    Rebuild-SessionPathFromRegistry | Out-Null
    $gone = (Get-Command uv -ErrorAction SilentlyContinue)
    Add-Result "Uninstall uv" ($null -eq $gone) ($(if ($null -eq $gone) { "removed" } else { "new shell may be needed" }))
  } catch { Add-Result "Uninstall uv" $false $_.Exception.Message }
}

function Purge-VSCode-UserData-And-Caches {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param()
  # User-level data (settings, keybindings, globalStorage, workspaceStorage, Backups)
  Remove-Tree -Path $VSCodeUserDir
  # Caches
  Remove-Tree -Path $VSCodeCacheDir
  Remove-Tree -Path $VSCodeCachedDataDir
  Remove-Tree -Path $VSCodeBackupsDir
  # Extensions
  Remove-Tree -Path $VSCodeExtensionsDir
}

function Prune-VSCode-Path-And-Leftovers {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param()
  # Remove code bin path if VS Code is gone or bin dir missing
  $codeCmd = Get-Command code -ErrorAction SilentlyContinue
  $binExists = Test-Path -LiteralPath $CodeBin
  if (($null -eq $codeCmd) -or (-not $binExists)) {
    Remove-UserPathEntry -Entry $CodeBin
  } else {
    Add-Result "Remove VS Code bin PATH" $true "kept (VS Code still present)"
  }
  # Remove leftover install dir if any
  Remove-Tree -Path $VSCodeInstallDir
}

# --- EXECUTION ---
Write-Host "=== Reverse-Uno FULL Cleanup — Starting ===" -ForegroundColor Yellow
Write-Host "Dry run: $WhatIf" -ForegroundColor DarkGray

Stop-VSCode
Remove-Project

# Uninstall apps (winget)
Uninstall-WithWinget -Id $Winget.VSCode        -FriendlyName 'Visual Studio Code' -ExeProbe 'code.cmd'
Uninstall-WithWinget -Id $Winget.Git           -FriendlyName 'Git'                -ExeProbe 'git.exe'
Uninstall-WithWinget -Id $Winget.GitHubDesktop -FriendlyName 'GitHub Desktop'     -ExeProbe 'github'

# Remove VS Code leftovers & PATH entries
Prune-VSCode-Path-And-Leftovers

# Uninstall uv exactly per docs
Uninstall-UV

# Remove Playwright browsers cache
Remove-Tree -Path $MsPlaywrightDir

# Purge VS Code user data + caches + extensions
Purge-VSCode-UserData-And-Caches

# Rebuild current session PATH so this shell aligns with registry PATH
Rebuild-SessionPathFromRegistry

Write-Host "=== Reverse-Uno FULL Cleanup — Complete ===`n" -ForegroundColor Yellow
$Results | Format-Table -AutoSize
