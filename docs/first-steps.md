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
   - Type "```uv```" - You should see info about uv, not an error message

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

## Getting Around in Terminal

Familiarizing yourself with Terminal will make working with files and folders much easier. Here are a few of the most common to get you started:

- ```pwd```: Print working directory to see where you are
- ```cd <directoryname>```: Change directory to move around the filesystem
- ```ls```: List all the files and folders in a directory
- ```mv``` Move a file or folder
- ```cp``` Copy a file or folder
- ```rm``` Remove a file or folder
- ```man <command>``` Help manual for any command

<br>

> [!TIP]
> You can run the install without admin privileges, but there may be issues with the `uv tool` command later.

<br>

---

<br>

## **Next: [Install VSCode Editor →](editors.md)**
