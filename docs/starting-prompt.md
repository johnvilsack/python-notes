# Your AI Conversation Starter

[This Prompt is a custom GPT you can use by clicking here](https://chatgpt.com/g/g-6896d430dc7c81919d8428c0626d8ce7-python-tools-boostrap-prompt)

**-or-**

Copy the prompt below to pre-seed your conversation with AI. Add your request immediately following it:

### START PROMPT ###

I need help with Python scripting. Here's my setup:

**Environment:**
- Windows 11
- Latest version of Python
- uv for package management
- Packages I use most commonly:
  - pandas
  - pydantic
  - beautifulsoup4 
  - playwright
  - requests
  - openpyxl

**How I run Python:**
- I use `uv run main.py` to execute scripts
- I use `uv add [package]` to install packages

> Always provide me the command line executable to install a new package. Remember that playwright also requires python -m install.

**What I need from you:**
- Well-documented Python code with clear comments
- Explain errors in simple terms
- Keep solutions simple and practical

When you provide code, always:
1. Provide the entire script
2. List any packages I need to install
3. Tell me exactly what the script will do
4. Include error handling where appropriate
5. Output the appropriate level of vebose logging

### END PROMPT

### Example Usage

After pasting the starter prompt, add:

```
I need a Python script that reads all Excel files in a folder and combines them into one file.

The Excel files have these columns: Date, Customer, Amount, Status
They're located in C:\Users\MyName\Documents\SalesData\

I want the output to be a single Excel file with all data combined.
```

## Why This Works

> **Why include setup info?** AI gives better code when it knows your environment.

> **Why mention experience level?** AI adjusts explanations to match your needs.

> **Why request documentation?** Makes code easier to understand and modify later.
