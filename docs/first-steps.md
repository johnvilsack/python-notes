# Installing Python (Windows 11)

## Installation

1. **Open PowerShell as Administrator**
   - Right-click Start button
   - Click "Terminal (Admin)" 
   - Click "Yes" when asked

> [!NOTE]
> Windows Terminal is the preferred terminal app. If you don't have it, you can install it from the Microsoft Store. When in the app, you will want to use "PowerShell" as it is the modern, more useful command line.

2. **Install uv Python Manager**
   - Copy and paste this command:<br>

   ```powershell
   powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

   - Wait for "uv installed successfully"
   - Close and reopen Terminal to enable uv

## Initialize Your First Project

```powershell
# Create your project folder
(Make sure you are in Powershell. If you are not or unsure, type "powershell")
cd $env:USERPROFILE     # This moves you to your C:\Users\YOURUSERNAME directory
mkdir python-notes
cd python-notes

# Bootstrap project
uv init

# Test it - uv installs Python automatically!
uv run main.py
```

You should see: `Hello from hello-python!`

> [!NOTE]
> Why uv? Each project gets its own Python and packages. No conflicts. [Learn more](about-uv.md).

<br>

> [!TIP]
> You can run the install without admin privileges, but there may be issues with the `uv tool` command later.

<br>

---

<br>

## **Next: [Install VSCode Editor →](editors.md)**
