# About uv

## What is uv?

One tool that manages Python. No juggling.

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

`uv init` = Set up project
`uv run main.py` = Run code (installs Python/packages automatically)

Each project is isolated. No conflicts.

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

<br>

---

<br>

**[← Back to First Steps](first-steps.md)** | **[Advanced uv →](advanced-uv.md)**
