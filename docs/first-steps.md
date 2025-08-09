# Installing Python (Windows 11)

## Installation

1. **Open PowerShell as Administrator**
   - Right-click Start button
   - Click "Terminal (Admin)" 
   - Click "Yes" when asked

2. **Install uv Python Manager**
   - Copy and paste this command:

   ```powershell
   powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

   - Wait for "uv installed successfully"
   - Close and reopen Terminal to enable uv

## Initialize Your First Project

```powershell
# Create your project folder
cd Documents
mkdir MyPythonWork
cd MyPythonWork

# Bootstrap project
uv init

# Test it - uv installs Python automatically!
uv run main.py
```

You should see: `Hello from hello-python!`

> Why uv? Each project gets its own Python and packages. No conflicts. [Learn more](about-uv.md).

## Note

You can run the install without admin privileges, but there may be issues with the `uv tool` command later.

---
**Next: [Install VSCode Editor →](editors.md)**
---
**[← Back to Checklist](../getting-started.md)**
**[← Back to Home](../README.md)**
