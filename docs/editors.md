# Setting Up VSCode

## Install VSCode

1. **Download VSCode**
   - Go to [code.visualstudio.com](https://code.visualstudio.com/)
   - Click the big download button
   - Run the installer
   - Keep clicking "Next" (default options are fine)

> [!TIP]
> **Why VSCode?** Free. Popular. AI understands it well. Has everything built-in.

## Add Python Support

Extensions enabled VSCode to work better with whatever you are working on. The Python extensions enables autocompletion, code formatting, error checking, and much more.

1. **Open VSCode**

2. **Install Python Extension**
   - Click Extensions icon on left (looks like 4 squares)
   - Search "Python"
   - Click "Install" on the first result (by Microsoft)
   - Wait until finished

## Open Your Project

You can open up your project 2 ways. You can open it manually 

1. **Open your python-notes folder in VSCode**
   - File → Open Folder
   - In the sidebar, navigate to This PC → Users → YOURUSERNAME → python-notes
   - Click "Select Folder"

2. **Trust the folder**
   - Click "Yes, I trust the authors" when asked

3. **Save as Workspace**
   - File → Save Workspace As
   - When you open this file again, it'll open your python-notes folder with all its settings

> [!TIP]
> **Open from Terminal** You can open files and folders in the Terminal by typing ```code``` and the file or folder name. If you are in python-notes, you can type ```code .``` and open the workspace immediately. If you just installed VSCode, you might have to restart your terminal.

## Configure Python

1. **Tell VSCode which Python to use**

   VSCode needs to know which Python to use for your project. uv installed a version specific to this project when you ran the main script the first time, so we will want to point to that.

   - Press `Ctrl+Shift+P`
   - Type "Python: Select Interpreter"
   - Choose the one that mentions venv. This is the virtual environment for the project

> [!TIP]
> The venv entry should look something like this: ```Python <version number> ('.venv':venv) <path to venv vesion>```

## Open the Terminal

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

<br>

---

<br>

## **Next: [Learn Python Basics →](the-basics.md)**
