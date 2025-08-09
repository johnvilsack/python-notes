# Installing Python (Windows 11)

Time: 10 minutes

## Step 1: Install uv

uv manages Python for you. One tool, no confusion.

1. **Open PowerShell as Administrator**
   - Right-click Start button
   - Click "Terminal (Admin)"
   - Click "Yes" when asked

2. **Install uv**
   - Copy and paste this command:
   ```powershell
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```
   - Press Enter
   - Wait for "uv installed successfully"

3. **Close and reopen Terminal**
   - This makes uv available

> **Why uv?** It's 10-100x faster than pip. Handles everything automatically. No Python version headaches.

## Step 2: Create Your First Project

1. **Make a folder for your work**
   ```powershell
   cd Documents
   mkdir MyPythonWork
   cd MyPythonWork
   ```

2. **Initialize your first project**
   ```powershell
   uv init HelloPython
   cd HelloPython
   ```

3. **Test it works**
   ```powershell
   uv run main.py
   ```
   
   You should see: `Hello from hello-python!`

> **Why a project folder?** Keeps your work organized. Each script gets its own space.

## Common Issues

**"uv is not recognized"**
- You forgot to close and reopen Terminal

**"Access denied" errors**
- Make sure you opened Terminal as Administrator

**"Script cannot be loaded"**
- Normal on Windows. The install command above handles this.

## Success Check

Run this command:
```powershell
uv --version
```

If you see a version number, you're ready!

**Next: [Install VSCode Editor](editors.md)** →