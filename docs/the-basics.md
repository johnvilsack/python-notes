# Python Basics

You don't need to write Python. You just need to recognize what AI gives you.

## What Python Looks Like

```python
# This is a comment - notes for humans

name = "John"                   # Text (string)
age = 30                        # Number
is_ready = True                 # Yes/No (boolean)

print(f"Hello {name}")          # Shows: Hello John
```

## Core Concepts

### Variables: Data Values That Change
```python
file_path = "data.csv"          # Stores text
row_count = 1000               # Stores number
```

### Lists: Sets of Data Values
```python
files = ["doc1.pdf", "doc2.pdf", "doc3.pdf"]
```

### Functions - Where things happen
```python
# Define function called process_file that expects data called filename
def process_file(filename):     # Define action
    # <CODE THAT DOES STUFF GOES HERE>
    
    # returns back something called result
    return result

# This is how you call the function called process_file and supply it with the expected filename
process_file("data.csv")        # Use action
```
### Loops - When you want to do things to a list of values
```python
for file in files:              # Do something to each
    print(file)
```

### If/Then - If this, then do that decisions
```python
if age > 18:
    print("Adult")
else:
    print("Minor")
```

## Common Patterns You'll See

### Reading Files
```python
with open("data.txt", "r") as file:
    content = file.read()
```

### Working with CSVs
```python
import pandas as pd
df = pd.read_csv("data.csv")
```

### Getting Data from the Web
```python
import requests
response = requests.get("https://example.com")
```

## Installing Packages

When AI uses special tools, install them:

```bash
uv add pandas           # For data work
uv add requests         # For web stuff
uv add beautifulsoup4   # For HTML parsing
```

> **Packages** are apps for Python. They cut down on the amount of code you need to get the job done.

## Reading Errors

**"FileNotFoundError: data.csv"**
- File doesn't exist or wrong path

**"IndentationError"**
- Python cares about spacing. Copy code exactly.

**"ModuleNotFoundError: No module named 'pandas'"**
- Missing package. Run: `uv add pandas`

## Running Code

Use:
```bash
uv run main.py
```

> Using uv manages the packages and code for you.

**Next: [How to Use with AI](how-to-use-with-ai.md)** →
