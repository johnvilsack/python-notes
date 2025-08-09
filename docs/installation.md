# Python First Steps
These is the highest possible overview of setting up and using Python.

## Installation

### Windows
* Run the following command to install the Python uv package manager
  ```powershell -c "iwr https://astral.sh/uv/install.ps1 -UseBasicParsing | iex"```

* Now use uv to install Python
  ```uv python install --default```

### Bootstrap You App

* Our example is 'HelloPython'
  ```
  uv init HelloPython
  cd HelloPython
  ```
  Why?
    1. Creates the HelloPython directory
    2. Adds important metadata files
    3. Creates the main.py file, the starting point in your app
   
### Installing Packages
Python packages are libraries that speed up development

```
uv add pandas pydantic beautifulsoup4 playwright
python -m playwright install
```
Why? This installs the packages most useful
  **[pandas](<link to pandas>)*** <what pandas does>
  <do the rest>
What packages do:
requests for uris
Playwright (selectors, waits), 
pandas (joins, cleaning), 
Beautiful Soup (HTML parsing).
pandas for wrangling, 
Beautiful Soup/Playwright for scraping, 
pydantic for validation

<SPLIT OFF EDITORS TO OWN FILE. REDO THE HEADINGS OF EDITORS TO MATCH ITS OWN FILE>
