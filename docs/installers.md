# Installers

Skip setup. Start coding.

## All-in-One Bootstrap

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1 | iex"
```

**Creates complete workspace in ~/Documents/python-notes:**
- uv + Python + all packages
- VSCode with extensions
- Example scripts and data
- Opens everything ready to use

## Global Python Install

Only if you need Python everywhere (requires Administrator):

```powershell
# Run as Administrator
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-global-installer.ps1 | iex"
```

**Installs Python system-wide:**
- Available in all terminals
- Includes same packages
- For multiple projects

## Which One?

**Bootstrap** = Following this tutorial  
**Global** = Multiple Python projects

## Addendum
To run a test version of the AIO, run:

```powershell
powershell -ExecutionPolicy Bypass -c "$s=irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1; iex $s; Start-PythonNotesBootstrap -WhatIf"
```
