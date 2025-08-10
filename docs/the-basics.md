# Python Basics

You don't write Python. You just need to recognize what AI gives you.

## What Python Looks Like

```python
# This is a comment - notes for humans

name = "John"                   # Text (string)
age = 30                        # Number
is_ready = True                 # Yes/No (boolean)

print(f"Hello {name}")          # Shows: Hello John
```

## Core Concepts

### Variables - Storage Boxes
```python
file_path = "data.csv"          # Stores text
row_count = 1000               # Stores number
```

### Lists - Multiple Items
```python
files = ["doc1.pdf", "doc2.pdf", "doc3.pdf"]
```

### Functions - Action Blocks
```python
def process_file(filename):     # Define what to do
    # Do something
    return result

process_file("data.csv")        # Actually do it
```
### Loops - Repeat for Each Item
```python
for file in files:              # Do something to each
    print(file)
```

### If/Then - Decisions
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

> [!TIP]
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

> [!TIP]
> Using uv manages the packages and code for you.

<br>

---

<br>

## **Next: [How to Use with AI →](how-to-use-with-ai.md)**
