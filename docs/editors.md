## Development
Python code can be edited in any text editor. VS Code is a free and popular choice.

### Install VS Code Editor
* [Install and Run Visual Studio Code](https://code.visualstudio.com/)
* On left sidebar, open Extensions
  * Install Python
* ```Ctrl+Shift+P``` to open Command Palette
  * Type ```Python Select Intrepreter``` and point to your app directory.
  Why? This tells VSCode where your Python and packages live
<Do we explain terminal here or is that too much for covering the absolute basics?>
<Do we include adding code to path?>
### Python Notebooks
A Python notebook is like a digital lab notebook where you can mix:

* Code (Python you can run right there)
* Results (plots, tables, numbers)
* Notes (plain text, explanations, formulas)

All in one scrolling document.

Instead of running a whole program start-to-finish in a terminal, you can run one chunk (“cell”) at a time, see the result immediately, tweak it, and keep going — like building a Lego set piece by piece and seeing it take shape.

Scientists, data analysts, and teachers love them because you can explain what you’re doing right next to the code that does it.

#### Using Python Notebooks
* To create a notebook, create a file with the file extension ```.ipynb```
* Opening the file in VS Code will automatically enable the notebook

#### Jupyter Notebooks
<insert here>
<install jupyter in vscode?>
Use JupyterLab
```uv pip install jupyterlab && jupyter lab```
To run:
```uv run jupyter lab```
-or-
* <vs code install and run instructions>


# Edit your App
Open main.py
Enter

```python

# Define your first function - what you use to run code
def main():
    # Outputs Hello, world! to the screen
    print("Hello, world!")

# Tells Python (if the name of the file is main, then run the function main)
if __name__ == "__main__":
    main()
```
