# CLAUDE.md

Project guidance for AI assistants working with this repository.

## Project Goal

Create the simplest possible introduction to using Python with AI assistance. Target audience: Complete beginners who need to solve real data problems at work.

**Current Status**: v3.0.0 - Complete tutorial system with automated setup, documentation, and examples. Battle-tested through multiple iterations focusing on extreme simplicity and speed.

## Core Principles

1. **Speed over depth** - Users should be productive in 1 hour
2. **Action over theory** - Show what to do, not why
3. **Real over abstract** - Use actual work examples
4. **Simple over complete** - Cover 80% of needs with 20% of complexity

## Evolution Lessons

This project underwent extensive refinement. Key learnings:

1. **"Genius in simplicity and brevity"** - Every revision made content shorter and clearer
2. **Remove all emojis** - They clutter and distract from the goal
3. **Speed metrics over engagement** - Users want to "burn through" content, not linger
4. **Show, don't tell** - Code comments explain concepts better than paragraphs
5. **Robust automation** - Scripts must handle edge cases and provide clear feedback

## Style Guide

### Writing
- **Ultra-concise** - Every word must earn its place
- **Direct commands** - "Do this" not "You should do this"
- **No fluff** - Skip pleasantries, introductions, conclusions
- **Code comments** - Explain concepts inline, not in paragraphs
- **No emojis** - They distract from the core message

### Structure
- **Clear headers** - Users scan, not read
- **Short sections** - One concept per section
- **Practical examples** - Real scenarios, not foo/bar
- **Quick reference style** - Lists and code blocks dominate

### Code
```python
# Comments explain the concept right here
name = "John"    # This style, not paragraphs above
```

## Document Purposes

### Core Path (1 hour total)
1. **first-steps.md** - Install uv and create project (10 min)
2. **editors.md** - VSCode setup (10 min)
3. **the-basics.md** - Recognize Python patterns (10 min)
4. **how-to-use-with-ai.md** - Core skill: AI collaboration (20 min)
5. **starting-prompt.md** - Template for AI conversations (10 min)

### Supporting Docs
- **about-uv.md** - Why uv instead of traditional Python
- **advanced-uv.md** - Command reference for later
- **learning-checklist.md** - Self-paced skill progression
- **additional-tools-and-resources.md** - Next steps when ready

### Special
- **credential-engine.md** - Specific guidance for CE team

## What NOT to Do

**Critical mistakes from development:**
- **Don't add emojis** - User explicitly rejected them as "too much"
- **Don't be verbose** - Each revision cut content by 50%+ 
- **Don't explain concepts** - Show with code comments instead
- **Don't add "why" sections** - Users want action, not justification
- **Don't create new files** - Edit existing ones first
- **Don't complicate scripts** - Automation must be invisible to user

## Key Messages

1. You're not learning to program, you're learning to direct AI
2. Python is just the language AI speaks best
3. Errors are normal, AI helps fix them
4. Start working immediately, learn by doing

## Technical Choices

- **uv** - Fastest, simplest Python management
- **VSCode** - Free, popular, AI understands it
- **Windows 11** - Primary target platform
- **PowerShell** - Default terminal

## Project Components

### Documentation (docs/)
Complete tutorial path from zero to productive in 1 hour.

### Automation (scripts/)
- **python-notes-bootstrap.ps1** - One-command setup (209 lines, production-ready)
- **python-global-installer.ps1** - System-wide Python installation
- Both scripts: Error handling, progress reporting, idempotent operations

### Examples (downloads/)
- **examples.py** - Real-world package demonstrations
- **sample-data.csv** - Practice dataset
- Auto-downloaded during bootstrap for immediate hands-on learning

### Infrastructure
- **installers.md** - One-liner installation commands
- **CHANGELOG.md** - Version tracking
- **credential-engine.md** - Company-specific guidance

## Success Metrics

User can:
1. Install everything in 30 minutes
2. Run first script in 45 minutes
3. Solve a real problem in 2 hours
4. Feel confident asking AI for help

## Maintenance Notes

- Keep all examples Windows-compatible
- Test commands before documenting
- Update package lists quarterly
- Maintain Custom GPT alignment with prompts

## Remember

This isn't a programming tutorial. It's a guide to getting work done with AI assistance. Every decision should optimize for speed to productivity, not depth of understanding.
