# Setting Up VSCode

Time: 10 minutes

## Step 1: Install VSCode

1. **Download VSCode**
   - Go to [code.visualstudio.com](https://code.visualstudio.com/)
   - Click the big download button
   - Run the installer
   - Keep clicking "Next" (default options are fine)

> **Why VSCode?** Free. Popular. AI understands it well. Has everything built-in.

## Step 2: Add Python Support

1. **Open VSCode**

2. **Install Python Extension**
   - Click Extensions icon on left (looks like 4 squares)
   - Search "Python"
   - Click "Install" on the first result (by Microsoft)
   - Wait 30 seconds

## Step 3: Open Your Project

1. **Open your HelloPython folder**
   - File → Open Folder
   - Navigate to Documents → MyPythonWork → HelloPython
   - Click "Select Folder"

2. **Trust the folder**
   - Click "Yes, I trust the authors" when asked

## Step 4: Configure Python

1. **Tell VSCode which Python to use**
   - Press `Ctrl+Shift+P`
   - Type "Python: Select Interpreter"
   - Choose the one that mentions "HelloPython"

> **Why this step?** VSCode needs to know which Python to use for your project.

## Step 5: Open the Terminal

1. **View → Terminal**
   - This opens a command area at the bottom
   - This is where you'll run your scripts

## Test It Works

1. **Open main.py** (should already exist)
2. **In the terminal, type:**
   ```
   uv run main.py
   ```
3. **You should see output**

## Quick Terminal Commands

- `uv run main.py` - Runs your Python file
- `Ctrl+C` - Stops a running program
- `cls` - Clears the terminal screen

---
**Next: [Learn Python Basics →](the-basics.md)**
---
**[← Back to Checklist](../getting-started.md)**
**[← Back to Home](../README.md)**
