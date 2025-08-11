# Installers

Skip setup. Start coding.

## All-in-One Bootstrap

1. Right-click the Start button
2. Select 'Terminal'
3. Copy the code below
4. Paste it into the Terminal
5. Hit Enter

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1 | iex"
```

**Creates complete workspace in C:\Users\YOURUSERNAME\github\python-notes:**
- uv + Python + all packages
- VSCode with extensions
- Example scripts and data
- Opens everything ready-to-use

<br>

---

<br>

## Uninstaller
Uninstall everything installed by the All-in-One Bootstrap

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-bootstrap-uninstaller.ps1 | iex"
```

## EXTRA: Python Install

If you need Python everywhere on your computer (requires Administrator):

```powershell
# Run as Administrator
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-global-installer.ps1 | iex"
```

<br>

---

<br>

**[← Back to Home](../README.md)**
