I would like to:
1. Install uv (e.g.  powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex")
2. Add uv to path
3. Create python-notes project folder in windows equivalent of $HOME\Documents\python-notes
4. cd into folder and uv init folder
5. Install latest Python and these packages using uv
  - pandas
  - pydantic
  - beautifulsoup4 
  - playwright
  - requests
  - openpyxl
  - Jupyter Notebook
6. Install playwright with python -m install playwright or whatever the appropriate command is
7. create a notebook.ipynb file with some sample code in it to bootstrap a notebook
8. make sure git is installed or install via winget
9. Install VS Code via winget if not found on system
10. Install Github Desktop via winget if not found on system
11. Install Python and Jupyter Notebook extensions automatically into VSCode
12. Add `code` to enable VS Code path in Terminal
13. Create a VS Code workspace for this project
    1.  Ensure initial settings of workspace open both main.py, and notebook.ipynb
    2.  Ensure terminal is opened and pointed into the project's directory
14. Point this vscode workspace to this python interpreter
15. Open VS Code to this workspace

I would also like a script that python-global-installer.ps1:
1. Installs latest python globally
2. Installs the packages above globally
