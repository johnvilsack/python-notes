# Installers

Don't want to deal with the hassle of setup? These scripts are for you

## Bootstrapper for this Repo

Run this script and set up everything covered in this tutorial and more.

```powershell
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -c "irm https://raw.githubusercontent.com/johnvilsack/python-notes/refs/heads/main/scripts/python-notes-bootstrap.ps1 | iex"
```
This script:
  1. Installs uv
  2. Installs Python
  3. Creates the "python-notes" project
  4. Installs Python packages
    1. pandas
    2. pydantic
    3. beautifulsoup4
    4. playwright
    5. requests
    6. openpyxl
    7. notebook
    8. ipykernel
  4. Adds files to the project:
     1. main.py - Where your script begins
     2. notebook.ipynb - Blank Python notebook
     3. examples.py - Sample script showcasing what the packages do
        1. example-data
           1. example-employees.csv - Used by examples.py 
  5. Installs Playwright tool
  6. Checks and Installs
    1. Git
    2. Github Desktop
    3. Visual Studio Code
  7. Configures VS Code
    1. Adds extensions Python and Jupyter Notebook
    2. Adds `code` command to command line, so you can: 
       1. type `code .` to open the project workspace in VS Code
       2. type `code <filename>` to open a file directly in the editor
  8.  Runs VS Code
    1.  Adds VS Code workspace files to the project
    2.  Opens VS Code to the workspace with the new files open


<what python script does>
