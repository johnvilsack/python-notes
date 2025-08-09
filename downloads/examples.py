"""
Quick Examples - See What Each Package Does
Run any function to see it work!
"""

import pandas as pd
import requests
from bs4 import BeautifulSoup
from pydantic import BaseModel, field_validator
from datetime import datetime
import json

# === PANDAS: Work with Data ===

def pandas_demo():
    """Load CSV, filter, save to Excel - 5 lines"""
    
    # Load data
    df = pd.read_csv('example-data/example-employees.csv')
    print(f"Loaded {len(df)} employees\n")
    
    # Find high earners
    high_earners = df[df['salary'] > 80000]
    print(f"Found {len(high_earners)} making over $80k:")
    print(high_earners[['name', 'department', 'salary']])
    
    # Save to Excel
    high_earners.to_excel('high_earners.xlsx', index=False)
    print("\n✓ Saved to high_earners.xlsx")

# === PYDANTIC: Validate Data ===

class Employee(BaseModel):
    """Auto-validates employee data"""
    name: str
    email: str
    salary: float
    
    @field_validator('email')
    def check_email(cls, v):
        if '@' not in v:
            raise ValueError('Need @ in email')
        return v

def pydantic_demo():
    """Catch bad data automatically"""
    
    # Good data works
    emp = Employee(name="Alice", email="alice@co.com", salary=75000)
    print(f"✓ Valid: {emp.name}")
    
    # Bad data fails
    try:
        bad = Employee(name="Bob", email="no-at-sign", salary=50000)
    except Exception as e:
        print(f"✗ Caught bad email: {e}")

# === WEB SCRAPING: Get Data from Websites ===

def scrape_demo():
    """Get title from any website"""
    
    response = requests.get("https://example.com")
    soup = BeautifulSoup(response.text, 'html.parser')
    
    title = soup.find('title').text
    print(f"Page title: {title}")
    
    # Find all links
    links = soup.find_all('a')
    print(f"Found {len(links)} links")

def api_demo():
    """Get JSON from API"""
    
    # GitHub API - no auth needed
    response = requests.get("https://api.github.com/users/microsoft")
    data = response.json()
    
    print(f"Microsoft GitHub:")
    print(f"  Public repos: {data['public_repos']}")
    print(f"  Followers: {data['followers']:,}")

# === RUN EVERYTHING ===

def run_all():
    """See all packages in action"""
    
    print("=== PANDAS ===\n")
    pandas_demo()
    
    print("\n=== PYDANTIC ===\n")
    pydantic_demo()
    
    print("\n=== WEB SCRAPING ===\n")
    scrape_demo()
    
    print("\n=== API CALLS ===\n")
    api_demo()

if __name__ == "__main__":
    print("Python Package Examples")
    print("-" * 40)
    run_all()
    print("\n✓ All examples complete!")