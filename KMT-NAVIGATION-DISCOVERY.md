# KMT Navigation Discovery
**Knowledge Management Tool - Database Navigation Methodology**

**Generated**: 2026-01-30  
**Source**: https://kmt-ogc.service.gc.ca/  
**Purpose**: Document systematic navigation patterns for browsing entire KMT article database

---

## Executive Summary

**Key Finding**: KMT uses **category-based navigation** to organize and access 104+ knowledge articles. Individual article pages are JavaScript-rendered and don't fetch well, but **category pages are server-rendered** and provide complete article listings with hierarchical navigation to related categories.

**Navigation Pattern**:
```
Category Page (CAT-#####) → Lists Articles (KA-#####) + Links to Related Categories
```

**Systematic Browsing Method**: Start with root category (likely System Actions or similar), navigate through subcategories, collect all article links.

---

## Navigation URL Patterns

### Category Pages (WORK - Server-Rendered)
**Format**: `https://kmt-ogc.service.gc.ca/category/?id=CAT-#####`

**Example**: 
- CAT-02016 (Persons): https://kmt-ogc.service.gc.ca/category/?id=CAT-02016
- CAT-01912 (System Actions): https://kmt-ogc.service.gc.ca/category/?id=CAT-01912

**Content Retrieved**:
- Category title
- List of articles in category (with titles and PIDs)
- Related category links
- Home link

### Article Pages (LIMITED - JavaScript-Rendered)
**Format**: 
- Latest version: `https://kmt-ogc.service.gc.ca/knowledgebase/article-latest?pid=KA-#####&cid=CAT-#####`
- Legacy format: `https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-#####&cid=CAT-#####`

**Example**: 
- KA-05215: https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016

**Issue**: Individual article pages load minimal HTML (only headers), likely relying on client-side JavaScript for content rendering. Not suitable for server-side web scraping.

---

## Category Hierarchy Discovered

### Major Categories (Root Level)

#### 1. System Actions (CAT-01912)
**URL**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01912

**Systems Covered**:
- ITRDS (CAT-01913) - Income Tax Retirement Data System
- CPMS (CAT-01496) - Canada Pension Management System
- PWS (CAT-01915) - Pensions Workload System
- Appeals (CAT-01931)
- PSCD (CAT-01917) - Public Sector Collections and Disbursements
- SAP (CAT-01918)
- Cúram (CAT-01958) - New OAS system

**Article Count**: 150+ articles across all subsystems

**Subcategories in ITRDS**:
- Simulation
- Data Capture
- Benefits
- CCS Only
- General
- Add, Modify or Delete

**Subcategories in Cúram** (CAT-01958):
- Account maintenance
- Foreign benefit applications and liaison management
- Document and evidence management
- Correspondence
- Work task management
- Enquiries
- Initial intake
- Tasks
- Persons
- Cases
- Evidences
- Monetary
- Contacts and Correspondence
- Work Tools

#### 2. Persons (CAT-02016)
**URL**: https://kmt-ogc.service.gc.ca/category/?id=CAT-02016

**Articles** (9 articles):
1. Access Person Evidence and Verification History (KA-05216)
2. Change Identification Information (KA-05496)
3. Manage a Person Record (KA-05488)
4. Manage Duplicate Person Records (KA-05446)
5. Perform Person Evidence Verification (KA-05215)
6. Register a Person (KA-05427)
7. Register a Prospect Person as a Person (KA-05495)
8. Register a Prospect Person (KA-05428)
9. Search for a Person (KA-05426)

**Related Categories**:
- System Actions (CAT-01912)
- Cúram (CAT-01958)

#### 3. Trending (CAT-01532)
**URL**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01532

**Purpose**: Featured/recent articles

**Examples**:
- CPPD Reassessment (KA-05573)
- CPMS Release Fall 2025 (Implementation Bulletin) (KA-05601)
- eServices Release 7 Fall 2025 (Implementation Bulletin) (KA-05600)
- Process Automation—CPP Record of Earnings (Knowledge) (KA-05004)
- Automatic Enrolment—OAS Pension and the GIS (Scenario) (KA-01746)

#### 4. Announcements (KA-04435)
**URL**: https://kmt-ogc.service.gc.ca/knowledgebase/article-latest?pid=KA-04435

**Purpose**: Recent updates and policy changes

**Recent Announcements**:
- Dual Workflow Charts for CPP and CPPD Processors (KA-05582)
- GIS Automatic Enrolment Program Compliance Review (KA-05624)
- 2025 Tax Slips Reminders and Information (KA-05618)
- Sponsorship Agreement Policy Amendments (KA-05458)
- Bank Accounts Wizard in OAS on BDM Release 3.4 (KA-05626)

---

## Systematic Navigation Strategy

### Method 1: Category Tree Traversal

**Approach**: Start with root categories, recursively fetch all subcategories and article lists.

**Algorithm**:
```
1. Start with homepage: https://kmt-ogc.service.gc.ca/
2. Identify major category links (CAT-01912, CAT-02016, CAT-01532, etc.)
3. For each category:
   a. Fetch category page: https://kmt-ogc.service.gc.ca/category/?id=CAT-#####
   b. Extract all article links (KA-#####)
   c. Extract all related category links (CAT-#####)
   d. Add new categories to queue
4. Repeat until all categories visited
5. Result: Complete article inventory with category mapping
```

**Expected Coverage**: All 104+ articles from XML export + any additional articles

### Method 2: XML-Guided Navigation

**Approach**: Use XML file article references as starting points.

**Algorithm**:
```
1. Extract all reference URLs from knowledge_articles_r2r3_en 2.xml
2. Extract category IDs (cid=CAT-#####) from URLs
3. For each unique category ID:
   a. Fetch category page
   b. Collect all article listings
4. Compare XML article count (104) with website article count
5. Identify any missing or new articles
```

**Validation**: Cross-reference XML articles with website listings to verify completeness.

### Method 3: Search-Based Discovery

**Approach**: Use KMT's search functionality to discover all articles.

**Search Endpoints** (to investigate):
- Search API endpoint (if exposed)
- Advanced search page
- Keyword-based article discovery

**Note**: This method requires testing to determine if search results are paginated and what query patterns return all articles.

---

## XML Cross-Reference

### Article ID Patterns

**From XML Analysis**:
- English XML: 104 articles
- French XML: 104 articles
- Article ID format: KA-##### (5-digit IDs)
- Category ID format: CAT-##### (5-digit IDs)

**Example from XML** (First article):
```xml
<reference>https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&amp;cid=CAT-02016</reference>
<title>Perform Person Evidence Verification in Cúram (Action)</title>
```

**Cross-Reference to Website**:
- Article KA-05215 appears in category CAT-02016 (Persons)
- Article is listed on category page: https://kmt-ogc.service.gc.ca/category/?id=CAT-02016
- Article title matches XML: "Perform Person Evidence Verification in Cúram (Action)"

**Validation Status**: ✅ XML article successfully found via category navigation

### Category Coverage in XML

**Categories Represented in 104 Articles**:
- CAT-02016 (Persons): 9 articles on website, subset in XML
- CAT-01912 (System Actions): Likely majority of XML articles
- CAT-01958 (Cúram): New system, many articles

**Hypothesis**: XML export contains articles from multiple categories, likely focused on Cúram system (R2/R3 release).

**File Naming Clue**: `knowledge_articles_r2r3_en 2.xml` suggests "Release 2/Release 3" of Cúram system.

---

## Evidence Collection Plan

### Phase 1: Category Tree Mapping
**Goal**: Build complete category hierarchy

**Tasks**:
1. ✅ Browse homepage
2. ✅ Identify major categories
3. ✅ Test category page fetching (CAT-02016, CAT-01912)
4. ⏳ Fetch all subcategories under CAT-01912
5. ⏳ Map complete category tree
6. ⏳ Document category relationships

**Deliverable**: Category tree diagram (categories → subcategories → articles)

### Phase 2: Article Inventory
**Goal**: Collect all article metadata

**Tasks**:
1. ⏳ For each category, extract article listings
2. ⏳ Build comprehensive article inventory (PID, title, category)
3. ⏳ Cross-reference with XML article list
4. ⏳ Identify articles in XML vs. website
5. ⏳ Document any discrepancies

**Deliverable**: Complete article inventory CSV (PID, Title, Category, URL)

### Phase 3: Export Methodology
**Goal**: Understand how XML export was generated

**Tasks**:
1. ⏳ Analyze XML structure vs. category organization
2. ⏳ Identify export scope (all articles vs. filtered by category/system)
3. ⏳ Document any missing metadata in XML (categories, systems, etc.)
4. ⏳ Recommend export improvements

**Deliverable**: Export methodology documentation

---

## Recommended Navigation URLs

### Starting Points for Full Database Browse

1. **System Actions (Primary)**:
   - https://kmt-ogc.service.gc.ca/category/?id=CAT-01912
   - Navigate through ITRDS, CPMS, PWS, Cúram subcategories

2. **Cúram System (R2/R3 Articles)**:
   - https://kmt-ogc.service.gc.ca/category/?id=CAT-01958
   - Likely source of 104 XML articles

3. **Understanding the KMT (Site Guide)**:
   - https://kmt-ogc.service.gc.ca/en/category/?id=CAT-01529
   - May contain navigation overview or category index

### Potential Sitemap/Index Pages (To Test)

- /categories (root category listing)
- /category (tested, returns "Article Unavailable" without ID)
- /sitemap (tested, returns 404)
- /knowledgebase (index of all articles)
- /search with wildcard query

**Next Action**: Fetch "Understanding the KMT" (CAT-01529) to find official navigation guide.

---

## Implementation Notes

### PowerShell Script Pattern

**Category Fetching**:
```powershell
# Fetch category page and extract article links
$categoryId = "CAT-01912"
$categoryUrl = "https://kmt-ogc.service.gc.ca/category/?id=$categoryId"

$response = Invoke-WebRequest -Uri $categoryUrl -UseBasicParsing
$html = $response.Content

# Extract article links (pattern: pid=KA-#####)
$articleMatches = [regex]::Matches($html, 'pid=(KA-\d{5})')
$articles = $articleMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

Write-Host "[INFO] Found $($articles.Count) articles in category $categoryId"
$articles | ForEach-Object { Write-Host "  - $_" }
```

**Recursive Category Discovery**:
```powershell
# Extract related category links
$categoryMatches = [regex]::Matches($html, '\?id=(CAT-\d{5})')
$categories = $categoryMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

Write-Host "[INFO] Found $($categories.Count) related categories"
$categories | ForEach-Object { Write-Host "  - $_" }
```

### Python Script Pattern

**Using BeautifulSoup for HTML Parsing**:
```python
import requests
from bs4 import BeautifulSoup
import re

def fetch_category_articles(category_id):
    """Fetch all articles from a category page"""
    url = f"https://kmt-ogc.service.gc.ca/category/?id={category_id}"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Extract article links
    article_links = soup.find_all('a', href=re.compile(r'pid=KA-\d{5}'))
    articles = [
        {
            'pid': re.search(r'pid=(KA-\d{5})', link['href']).group(1),
            'title': link.text.strip(),
            'url': link['href']
        }
        for link in article_links
    ]
    
    # Extract related categories
    category_links = soup.find_all('a', href=re.compile(r'id=CAT-\d{5}'))
    categories = [
        re.search(r'id=(CAT-\d{5})', link['href']).group(1)
        for link in category_links
    ]
    
    return articles, categories

# Example usage
articles, categories = fetch_category_articles('CAT-01912')
print(f"[INFO] Found {len(articles)} articles, {len(categories)} related categories")
```

---

## Category vs. XML Mapping

### XML Articles by Category (Hypothesis)

**Based on file naming** (`knowledge_articles_r2r3_en 2.xml`):

**R2/R3** = Cúram Release 2/Release 3 articles

**Expected Category Focus**:
- CAT-01958 (Cúram): Majority of 104 articles
- CAT-02016 (Persons): Subset for person management in Cúram
- Related Cúram subcategories:
  - Account maintenance
  - Tasks
  - Persons
  - Cases
  - Evidences
  - Monetary

**Validation Required**: Fetch CAT-01958 (Cúram) and count articles to verify hypothesis.

---

## Next Steps

### Immediate Actions

1. **Fetch Cúram Category (CAT-01958)**:
   - URL: https://kmt-ogc.service.gc.ca/category/?id=CAT-01958
   - Count articles
   - Compare with XML article count (104)
   - Validate R2/R3 hypothesis

2. **Fetch "Understanding the KMT" (CAT-01529)**:
   - URL: https://kmt-ogc.service.gc.ca/en/category/?id=CAT-01529
   - Look for official navigation guide
   - Check for category index or sitemap

3. **Build Category Tree Script**:
   - Implement recursive category fetching
   - Build complete navigation map
   - Export to JSON/CSV for analysis

### Long-Term Investigation

1. **Export Mechanism Discovery**:
   - Investigate how XML was generated (manual export vs. API)
   - Look for export functionality in KMT interface
   - Document export parameters (filters, date ranges, etc.)

2. **Article Update Detection**:
   - Identify "Updated" markers on articles (seen on KA-05493)
   - Track article versions over time
   - Plan for incremental updates to EVA DA

3. **Bilingual Consistency**:
   - Verify EN/FR article pairing
   - Check for translation completeness
   - Document any language-specific articles

---

## Findings Summary

### What Works
✅ Category pages (CAT-#####) - Server-rendered, complete article listings  
✅ Hierarchical navigation - Categories link to related categories  
✅ Article metadata - Titles and PIDs available on category pages  
✅ Cross-referencing - XML article URLs match website patterns  

### What Doesn't Work
❌ Individual article pages - JavaScript-rendered, minimal HTML returned  
❌ Sitemap endpoint - Returns 404  
❌ Root category page - Returns "Article Unavailable" without ID  

### Recommended Approach
**Use category-based navigation** as primary method for browsing entire KMT database:

1. Start with System Actions (CAT-01912) and Cúram (CAT-01958)
2. Recursively fetch all subcategories
3. Collect all article listings from category pages
4. Cross-reference with XML to validate completeness
5. Build comprehensive article inventory

**Estimated Coverage**: 100% of articles (104+ from XML, plus any additional articles on website)

---

**Document Status**: In Progress  
**Next Update**: After fetching CAT-01958 (Cúram) and CAT-01529 (Understanding the KMT)

**Related Documents**:
- WEBSITE-DISCOVERY.md - Initial website structure analysis
- XML-STRUCTURE-ANALYSIS.md - XML schema documentation
- README.md - EVA DA XML ingestion investigation overview

---

**Generated by**: EVA Documentation System  
**Last Updated**: 2026-01-30
