# About uv

## What is uv?

A single tool that manages Python for you. No more juggling multiple programs.

## Why Not Just Install Python?

**Traditional Way:**
- Install Python globally on computer
- Install pip for packages
- Create virtual environments manually

**uv Way:**
- One tool does everything
- Each project gets its own Python
- No version conflicts ever
- Works immediately

## What uv Actually Does

When you run `uv init`:
- Creates project structure
- Sets up Python environment
- Manages all dependencies

When you run `uv run main.py`:
- Installs Python automatically! (if needed)
- Installs missing packages
- Runs your script

uv isolates projects using **virtual environments (.venv). You can run different versions of software at the same time without conflict.

```
Project1/
  - Uses Python 3.11
  - Has pandas 2.0
  
Project2/  
  - Uses Python 3.12
  - Has pandas 1.5
```

## Common Questions

**"Where is Python installed?"**
- In a hidden `.venv` folder in your project
- You never need to touch it

**"Can I use regular Python commands?"**
- Yes, but always through uv: `uv run python <your command>`

**"What if I need Python everywhere?"**
- See [Install Python Globally](install-python.md)

**[← Back to First Steps](first-steps.md)** | **[Advanced uv →](advanced-uv.md)**
