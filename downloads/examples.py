"""
Python Examples - Learn by Doing
Each section shows a real task you might need at work
"""

# Import everything we'll use
import pandas as pd
import requests
from bs4 import BeautifulSoup
from pydantic import BaseModel, field_validator
from datetime import datetime
import json
from pathlib import Path

# === PANDAS: Working with Data ===

def work_with_spreadsheets():
    """Read CSV, filter data, save to Excel"""
    
    # Read the sample data
    df = pd.read_csv('example-data/example-employees.csv')
    print("Original data:")
    print(df.head())  # Show first 5 rows
    
    # Filter: Find all employees in Engineering making over 70k
    engineers = df[(df['department'] == 'Engineering') & (df['salary'] > 70000)]
    print(f"\nFound {len(engineers)} engineers making over $70k")
    
    # Add a new column: Calculate annual bonus (10% of salary)
    df['bonus'] = df['salary'] * 0.10
    
    # Group by department: Get average salary per department
    dept_avg = df.groupby('department')['salary'].mean().round(2)
    print("\nAverage salary by department:")
    print(dept_avg)
    
    # Save to Excel with multiple sheets
    with pd.ExcelWriter('example-data/employee_report.xlsx') as writer:
        df.to_excel(writer, sheet_name='All Employees', index=False)
        engineers.to_excel(writer, sheet_name='High Paid Engineers', index=False)
        dept_avg.to_excel(writer, sheet_name='Department Averages')
    
    print("\n✓ Saved report to employee_report.xlsx")

# === PYDANTIC: Validate Data ===

class Employee(BaseModel):
    """Ensure employee data is always valid"""
    name: str
    email: str
    department: str
    salary: float
    start_date: datetime
    
    @field_validator('email')
    def email_must_contain_at(cls, v):
        """Check email has @ symbol"""
        if '@' not in v:
            raise ValueError('Invalid email')
        return v
    
    @field_validator('salary')
    def salary_must_be_positive(cls, v):
        """Salary can't be negative"""
        if v < 0:
            raise ValueError('Salary must be positive')
        return v

def validate_employee_data():
    """Show how Pydantic catches bad data"""
    
    # Good data - this works
    good_employee = Employee(
        name="Jane Smith",
        email="jane@company.com",
        department="Engineering",
        salary=85000,
        start_date="2023-01-15"
    )
    print("Valid employee created:")
    print(f"  {good_employee.name} - ${good_employee.salary:,.0f}")
    
    # Bad data - this will fail
    try:
        bad_employee = Employee(
            name="John Doe",
            email="john_at_company.com",  # Missing @
            department="Sales",
            salary=-5000,  # Negative salary
            start_date="2023-01-01"
        )
    except Exception as e:
        print("\nPydantic caught bad data:")
        print(f"  Error: {e}")
    
    # Convert to dictionary for saving
    employee_dict = good_employee.model_dump()
    print("\nEmployee as dictionary (ready for database):")
    print(f"  {employee_dict}")

# === REQUESTS + BEAUTIFULSOUP: Get Web Data ===

def scrape_website_example():
    """Get data from a website"""
    
    # Get a simple website
    url = "https://example.com"
    response = requests.get(url)
    
    # Check if request worked
    if response.status_code == 200:
        print(f"Successfully fetched {url}")
        
        # Parse the HTML
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find the title
        title = soup.find('title').text
        print(f"Page title: {title}")
        
        # Find all paragraphs
        paragraphs = soup.find_all('p')
        print(f"Found {len(paragraphs)} paragraphs")
        
        # Get text from first paragraph
        if paragraphs:
            first_p = paragraphs[0].text
            print(f"First paragraph: {first_p[:100]}...")
    else:
        print(f"Failed to fetch {url}")

def get_json_from_api():
    """Get JSON data from an API"""
    
    # Free API that returns JSON
    api_url = "https://api.github.com/users/microsoft/repos"
    
    # Get data with timeout (good practice)
    response = requests.get(api_url, timeout=10)
    
    if response.status_code == 200:
        # Parse JSON automatically
        repos = response.json()
        
        print(f"Microsoft has {len(repos)} public repos")
        
        # Show top 5 by stars
        sorted_repos = sorted(repos, key=lambda x: x['stargazers_count'], reverse=True)
        
        print("\nTop 5 Microsoft repos by stars:")
        for i, repo in enumerate(sorted_repos[:5], 1):
            print(f"  {i}. {repo['name']}: ⭐ {repo['stargazers_count']:,}")

# === WORKING WITH FILES ===

def work_with_json_files():
    """Save and load JSON data"""
    
    # Data to save
    config = {
        "database": "production",
        "timeout": 30,
        "features": ["search", "export", "notifications"],
        "last_updated": datetime.now().isoformat()
    }
    
    # Save to JSON file
    with open('example-data/config.json', 'w') as f:
        json.dump(config, f, indent=2)
    print("Saved configuration to config.json")
    
    # Load from JSON file
    with open('example-data/config.json', 'r') as f:
        loaded_config = json.load(f)
    
    print(f"Loaded config - Database: {loaded_config['database']}")
    print(f"Features enabled: {', '.join(loaded_config['features'])}")

# === COMBINING EVERYTHING ===

def process_employee_report():
    """Real example: Fetch data, validate, analyze, save"""
    
    print("=== Employee Report Generator ===\n")
    
    # Step 1: Read employee data
    df = pd.read_csv('example-data/example-employees.csv')
    print(f"Loaded {len(df)} employees")
    
    # Step 2: Validate each employee
    valid_count = 0
    for _, row in df.iterrows():
        try:
            emp = Employee(
                name=row['name'],
                email=row['email'],
                department=row['department'],
                salary=row['salary'],
                start_date=row['start_date']
            )
            valid_count += 1
        except:
            print(f"  ⚠ Invalid data for {row['name']}")
    
    print(f"Validated {valid_count}/{len(df)} employees")
    
    # Step 3: Analysis
    high_earners = df[df['salary'] > df['salary'].quantile(0.75)]
    print(f"\nTop 25% earners: {len(high_earners)} employees")
    print(f"Average top salary: ${high_earners['salary'].mean():,.0f}")
    
    # Step 4: Create summary
    summary = {
        "report_date": datetime.now().isoformat(),
        "total_employees": len(df),
        "departments": df['department'].unique().tolist(),
        "salary_range": {
            "min": float(df['salary'].min()),
            "max": float(df['salary'].max()),
            "average": float(df['salary'].mean())
        },
        "top_earners": high_earners[['name', 'department', 'salary']].to_dict('records')
    }
    
    # Step 5: Save report
    with open('example-data/report_summary.json', 'w') as f:
        json.dump(summary, f, indent=2)
    
    print("\n✓ Report saved to report_summary.json")
    print(f"✓ Found {len(summary['top_earners'])} high earners")

# === MAIN: Run Examples ===

def main():
    """Run all examples - comment out ones you don't need"""
    
    # Create data folder if it doesn't exist
    Path('example-data').mkdir(exist_ok=True)
    
    print("\n1. PANDAS - Working with spreadsheets")
    print("-" * 40)
    work_with_spreadsheets()
    
    print("\n2. PYDANTIC - Validating data")
    print("-" * 40)
    validate_employee_data()
    
    print("\n3. WEB SCRAPING - Getting online data")
    print("-" * 40)
    scrape_website_example()
    
    print("\n4. APIs - Getting JSON data")
    print("-" * 40)
    get_json_from_api()
    
    print("\n5. FILES - Saving and loading")
    print("-" * 40)
    work_with_json_files()
    
    print("\n6. COMPLETE EXAMPLE - Full workflow")
    print("-" * 40)
    process_employee_report()
    
    print("\n" + "="*50)
    print("All examples complete! Check the 'example-data' folder for outputs.")
    print("="*50)

if __name__ == "__main__":
    # This runs when you execute the script
    main()