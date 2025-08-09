# Install Python Globally

Sometimes you need Python everywhere on your computer, not just in projects.

## When You'd Want This

- Running random scripts from anywhere
- Using Python as a calculator
- System-wide tools that need Python
- You're comfortable managing versions yourself

## How It's Different from uv

**Global Python:**
- One Python for entire computer
- All projects share same version
- Packages installed for all scripts

**uv Python:**
- Each project has own Python
- No conflicts between projects
- Packages isolated per project

## Install Methods

### Method 1: Windows Package Manager (Recommended)

```powershell
winget install Python.Python.3.12
```

### Method 2: Direct Download

1. Go to [python.org/downloads](https://python.org/downloads)
2. Download latest version
3. Run installer
4. **CHECK "Add Python to PATH"**
5. Click Install

## Test It Works

```powershell
python --version
```
Should show: `Python 3.12.x`

## Install Packages Globally

```powershell
pip install pandas
pip install requests
```

> **Warning:** Global packages affect ALL Python scripts

## Managing Package Versions

### In Global Environment

```powershell
pip install pandas==2.0.0    # Specific version
pip install --upgrade pandas # Latest version
pip list                     # See what's installed
```

### In uv Project (Better)

```bash
uv add pandas==2.0.0         # Only affects this project
```

## Keep Python Updated

### Check Current Version

```powershell
python --version
```

### Update Python

- Rerun winget: `winget upgrade Python.Python.3.12`
- Or download new version from python.org

### Update pip

```powershell
python -m pip install --upgrade pip
```

## Common Issues

**"python is not recognized"**

- Python not in PATH
- Reinstall and check "Add to PATH"

**"pip is not recognized"**

```powershell
python -m ensurepip
```

**Version conflicts between projects**

- This is why we recommend uv instead
- Consider switching: [First Steps](first-steps.md)

## Which Should You Use?

**Use Global Python if:**

- You're only running simple scripts
- You don't need different package versions
- You're comfortable with manual management

**Use uv if:**

- You work on multiple projects
- You need different Python versions
- You want automatic management
- You're following this guide

## Bottom Line

Global Python works but uv is easier for real projects.

<br>

---

<br>

**[← Back to Additional Tools](additional-tools-and-resources.md)**

<br>

**[← Back to Home](../README.md)**
