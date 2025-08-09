# Working with AI to Get Code

## The Basic Loop

1. **Tell AI what you want**
2. **Get Python code**
3. **Run it**
4. **Fix issues with AI's help**
   1. Explain outcome
   2. Paste screen output
   3. Share error messages
5. **Iterate until it works**

## How to Ask for Code

### Good Request Structure

```
I need a Python script that [DOES THIS].
Input: [WHAT YOU HAVE]
Output: [WHAT YOU WANT]
Please use well-documented Python code.
```

### Think Step-by-Step

- Programs run in order: A → B → C
- Tell AI the steps in the right sequence
- Break complex tasks into smaller pieces

### Real Examples

**Example 1: File Processing**
```
I need a Python script that reads a CSV file and finds all rows where the date is last Monday.

Input: CSV file with columns: Date, Name, Amount, Status
Output: New CSV with only Monday's rows

Please use well-documented Python code.
```

**Example 2: Web Scraping**
```
I need a Python script that checks these 5 websites and tells me which ones mention "Red Fire Trucks".

Websites:
- https://example1.com
- https://example2.com
[etc]

Output: List showing each URL and whether it contains the phrase

Please use well-documented Python code.
```

## When AI Gives You Code

1. **Save it as main.py**
2. **Check the top of the script for new imports**
3. **Install any missing packages**:
   ```bash
   uv add <package-name-here>
   ```
4. **Run it**:
   ```bash
   uv run main.py
   ```
   
## Handling Errors

### Share the Exact Error

Copy the ENTIRE error message to AI:

```
I got this error when running your code:

[PASTE FULL ERROR HERE]

How do I fix this?
```

### Common Issues

**Code is wrong**
- Tell AI: "The code runs but [WHAT'S WRONG]. It should [WHAT YOU EXPECTED]"

**"File not found"**
- Check file name and location
- Tell AI: "The file is actually located at [path]"

**"No module named X"**
- There's a new package importing
- Install it: `uv add <package-name-here>`
## Successfully Iterating

### Be Specific About Problems

**Bad:** "It doesn't work"

**Good:** "The script runs but only finds 3 emails when I can see 10 in the file"

### Provide Context

**Bad:** "Fix this error"

**Good:** Copy and paste screen output, especially errors; provide samples of the output that is incorrect

### Debug Tips

- Ask for verbose output
- Test with small samples first
- Request step-by-step code if stuck

## Example: Conversation Flow

**You:** "I need a script that combines all CSV files in a folder into one big CSV"

**AI:** [Provides code]

**You:** "I'm getting 'No module named pandas'"

**AI:** "Install pandas with: uv add pandas"

**You:** "Now it says 'No CSV files found'"

**AI:** "Make sure you're running from the right folder. Try adding this to see current directory..." [provides updated code]

**You:** "Perfect! It found 5 files and combined them"

---
**Next: [Working with Prompts →](starting-prompt.md)**
---
**[← Back to Checklist](../getting-started.md)**
**[← Back to Home](../README.md)**
