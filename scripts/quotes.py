# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "requests",
#   "rich"
# ]
# ///

import random
import requests
from requests.exceptions import RequestException
from rich.console import Console
from rich.panel import Panel

console = Console()

OFFLINE_QUOTES = [
    ("Simplicity is the soul of efficiency.", "Austin Freeman"),
    ("Talk is cheap. Show me the code.", "Linus Torvalds"),
    ("Programs must be written for people to read.", "Harold Abelson"),
]

def get_quote():
    try:
        res = requests.get("https://zenquotes.io/api/random", timeout=3)
        res.raise_for_status()
        data = res.json()[0]
        return data["q"], data["a"]
    except (RequestException, KeyError, IndexError):
        return random.choice(OFFLINE_QUOTES)

quote, author = get_quote()
panel = Panel(f"[bold cyan]“{quote}”[/bold cyan]\n[green]— {author}[/green]", title="Your First Quote", border_style="magenta")
console.print(panel)
