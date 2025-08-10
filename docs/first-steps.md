# Installing Python (Windows 11)

## Installation

1. **Open PowerShell as Administrator**
   - Right-click Start button
   - Click "Terminal (Admin)" 
   - Click "Yes" when asked

2. **Install uv Python Manager**
   - Copy and paste this command:<br>

   ```powershell
   powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

   - Wait for "uv installed successfully"
   - Close and reopen Terminal to enable uv
   - Type "```uv```" - You should 

## Initialize Your First Project
Make sure you are in Powershell. If you are not or unsure, type "```powershell```"

Type these commands in:
1. ```cd $env:USERPROFILE```: Change to your C:\Users\YOURUSERNAME directory
2. ```mkdir github\python-notes```: Creates the github directory to store all your projects and a directory for this project called "```python-notes```"
3. ```cd github\python-notes```: Moves you into the directory you just created
   


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
