# Installing Python (Windows 11)

## Installation

We're going to use the Windows Terminal. While it may seem daunting at first, the Terminal is just a way to work with files and folders through text.

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
   - Type "```uv```" - You should see info about uv, not an error message

> [!TIP]
> When you type a command and hit enter, you are telling the computer to do stuff. Some commands take longer to do than others and your cursor will disappear during this time. When the command is done, your cursor will return.

## Initialize Your First Project

Type these commands in:
1. ```cd $env:USERPROFILE```: Change to your C:\Users\YOURUSERNAME directory
2. ```mkdir github\python-notes```: Creates the github directory to store all your projects and a directory for this project called "```python-notes```"
3. ```cd github\python-notes```: Moves you into the directory you just created
4. ```uv init```: Initializes the project with metadata files it will need
5. ```uv sync```: Creates the virtual environment and installs Python
6. ```uv run main.py```: Runs the python script main.py

You should see: `Hello from hello-python!`

> [!NOTE]
> uv manages Python for you. [Learn more](about-uv.md)

> [!TIP]
> Click here to learn more about **[Basic Terminal Commands](basic-terminal-commands.md)** 

<br>

---

<br>

## **Next: [Install VSCode Editor →](editors.md)**
