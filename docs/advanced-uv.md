# Advanced uv Reference

Quick reference for common uv commands beyond the basics.

## Managing Packages

### Install Packages

```bash
uv add pandas                    # Install latest version
uv add pandas==2.0.0            # Install specific version
uv add "pandas>=2.0,<3.0"       # Install with version range
```

### Update Packages

```bash
uv add --upgrade pandas         # Update single package
uv lock --upgrade-package pandas  # Update just pandas in lock
uv lock --upgrade              # Update all packages
```

### Remove Packages

```bash
uv remove pandas               # Uninstall package
```

### See What's Installed

```bash
uv pip list                    # List all packages
uv tree                        # Show dependency tree
```

## Working with Python Versions

### Use Different Python

```bash
uv python install 3.12         # Install Python 3.12
uv init --python 3.12         # New project with Python 3.12
uv python pin 3.12            # Set project to use Python 3.12
```

### List Available Pythons

```bash
uv python list                 # Show installed versions
uv python list --all-versions # Show all available
```

## Project Management

### Lock Files - Force Exact Versions of Python and Packages

```bash
uv lock                        # Create/update lock file
uv sync                        # Install from lock file
```
> Lock files ensure everyone gets exact same package versions

### Running Scripts

```bash
uv run main.py                 # Run with project packages
uv run python                  # Interactive Python shell
uv run --with pandas script.py # Temporary package for one run
```

### Installing Tools Globally

```bash
uv tool install ruff           # Install tool globally
uv tool list                   # List installed tools
uv tool upgrade ruff          # Update tool
```

## Working with Requirements Files

### Export/Import

```bash
uv pip freeze > requirements.txt    # Export current packages
uv pip install -r requirements.txt  # Install from file
```

### Convert Existing Projects

```bash
# In folder with requirements.txt:
uv init
uv add -r requirements.txt     # Import all packages
```

## Useful Patterns

### Quick Scripts Without Project

```bash
# Run script with inline dependencies
uv run --with pandas,requests script.py
```

### Multiple Package Sources

```bash
# Add from PyPI and Git
uv add pandas
uv add git+https://github.com/user/repo.git
```

### Development Dependencies

```bash
uv add --dev pytest           # Dev-only package
uv sync --no-dev             # Install without dev deps
```

## Common Issues

**"Package conflict" errors**

```bash
uv lock --upgrade             # Recalculate all versions
```

**Clean slate**

```bash
rm -rf .venv uv.lock         # Windows: rmdir /s .venv
uv sync                       # Rebuild everything
```

**See what uv is doing**

```bash
uv -v run main.py            # Verbose output
```

## Keep uv Updated

```bash
uv self update               # Update uv itself
```

## Learn More

- [Official uv Docs](https://docs.astral.sh/uv/)
- [uv GitHub](https://github.com/astral-sh/uv)

---
**[← Back to Additional Tools](additional-tools-and-resources.md)**
**[← Back to Home](../README.md)**
