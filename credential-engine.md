# Credential Engine Specific Guide

This guide contains specific information for Credential Engine team members working with educational data and credentials.

## Common Credential Engine Tasks

### Extracting Credentials from Websites

**Problem:** Educational institutions don't present credentials in structured formats.

**Solution Pattern:**

```
I need a Python script that extracts credential information from [WEBSITE].

The page contains:
- Program names
- Degree types
- Credit hours
- Prerequisites
- Course descriptions

Please extract this into a CSV with columns: 
ProgramName, DegreeType, Credits, Prerequisites, Description

Use beautifulsoup4 for parsing HTML.
```

### Processing Registry Data

**Working with Credential Registry API:**

```
I need to query the Credential Registry API for all credentials from [ORGANIZATION].

API endpoint: https://credentialengineregistry.org/api/
I need to extract: credential name, type, owner, competencies

Format the output as JSON matching our schema.
```

### Data Cleaning Patterns

**Standardizing Institution Names:**

```
I have a CSV with messy institution names that need standardizing.
Examples:
- "U of Michigan" → "University of Michigan"
- "MIT" → "Massachusetts Institute of Technology"
- "UCLA" → "University of California, Los Angeles"

Please create a script that uses a mapping dictionary to clean these.
```

## Useful Packages for CE Work

```bash
# Web scraping educational sites
uv add requests beautifulsoup4 playwright

# Data processing
uv add pandas openpyxl

# API work
uv add requests pydantic

# JSON schema validation
uv add jsonschema

# Fuzzy matching for institution names
uv add fuzzywuzzy python-Levenshtein
```

## CE Publisher Support Tool Integration

Your team has a tool at: https://github.com/udensidev/credential-engine-support-service-publisher

To work with it:
1. Clone the repository
2. Use Python scripts to prepare data for the tool
3. Focus on data cleaning before import

## Common Data Sources

### Types You'll Encounter

- College catalogs (HTML/PDF)
- State education databases (CSV/Excel)
- Accreditation bodies (APIs/JSON)
- Institution websites (unstructured HTML)

### Extraction Strategies

**For PDFs:**

```
I need to extract credential data from a PDF catalog.
The PDF has tables with: Course Code, Title, Credits, Description
Please use pypdf or pdfplumber to extract this data.
```

**For Complex HTML:**

```
This educational website loads data dynamically with JavaScript.
I need to use Playwright to:
1. Navigate to the programs page
2. Click "Show All" to load all programs
3. Extract the credential information
```

## Data Quality Checks

Always validate extracted data:

```python
# Check for required fields
required_fields = ['name', 'type', 'provider']

# Validate credit ranges
valid_credits = (0, 200)

# Check for duplicate entries
```

## Working with CTDL (Credential Transparency Description Language)

When preparing data for CTDL format:
```
I need to convert this CSV of credentials to CTDL-ASN JSON format.

Input columns: Name, Type, Description, Provider, Credits
Output: JSON following CTDL schema

Please include proper @context and @type fields.
```

## Typical Workflow

1. **Discovery** - Find where credentials are published
2. **Extraction** - Pull data from sources
3. **Cleaning** - Standardize formats and values
4. **Validation** - Check against CE schemas
5. **Publishing** - Format for Registry upload

## Getting Help

- Internal CE documentation
- Registry API docs: https://credentialengineregistry.org/api-docs
- CTDL Handbook: https://credreg.net/ctdl/handbook

## Example Projects

### Project 1: State University System Scraper

```
Create a script that:
1. Reads a list of university URLs
2. Extracts all degree programs
3. Standardizes the data
4. Exports to CE-compatible format
```

### Project 2: Competency Extractor

```
Parse course descriptions to extract:
- Learning outcomes
- Competencies
- Skills
Map these to existing frameworks when possible
```

## Remember

- Educational data is messy - expect inconsistencies
- Always validate against CE schemas
- Institution names need careful standardization
- Save raw data before processing
- Document your extraction logic

**[← Back to Main Guide](README.md)**