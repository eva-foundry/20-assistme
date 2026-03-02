# XML Generation Plan - Complete KMT Database Export
**Project**: EVA DA XML Ingestion (AssistMe Data Source)  
**Created**: 2026-01-30  
**Status**: Planning Phase  

---

## Executive Summary

**Objective**: Generate complete XML exports of the KMT knowledge base with full article content in both English and French languages.

**Current State**: 
- Have XML exports for Curam R2/R3 only (102 articles, 49.8% of database)
- Comprehensive inventory of 195+ unique articles across 5 major systems
- Article metadata collected (PIDs, titles, categories)

**Target State**:
- Complete XML export covering all 195+ articles (English)
- Complete XML export covering all 195+ articles (French)
- Full article content (not just metadata)
- Preserve XML structure compatible with existing EVA DA ingestion pipeline

---

## 1. Data Sources & Coverage

### 1.1 Current XML Exports (Reference Format)
**Files**: 
- `knowledge_articles_r2r3_en 2.xml` (1.3 MB, 102 articles)
- `knowledge_articles_r2r3_FR.xml` (1.3 MB, 102 articles)

**XML Structure** (from analysis):
```xml
<?xml version="1.0" encoding="utf-8"?>
<knowledgebase>
  <article>
    <title>Article Title Here</title>
    <summary>Brief summary text</summary>
    <content><![CDATA[Full HTML content with formatting]]></content>
    <categories>
      <category>Category Name</category>
    </categories>
    <tags>
      <tag>tag1</tag>
      <tag>tag2</tag>
    </tags>
    <reference>https://kmt-ogc.service.gc.ca/knowledgebase/article-latest?pid=KA-#####&amp;cid=CAT-#####</reference>
    <datecreated>YYYY-MM-DDTHH:MM:SS</datecreated>
    <datemodified>YYYY-MM-DDTHH:MM:SS</datemodified>
    <author>Author Name</author>
  </article>
</knowledgebase>
```

### 1.2 Target Coverage (from KMT-DATABASE-INVENTORY-COMPLETE.json)

| System | Category ID | Articles | Coverage Status |
|--------|-------------|----------|-----------------|
| **ITRDS** | CAT-01913 | 59 | ❌ Missing from XML |
| **CPMS** | CAT-01496 | 27 | ❌ Missing from XML |
| **PWS** | CAT-01915 | 7 | ❌ Missing from XML |
| **Curam** | CAT-01958 | 102 | ✅ Have XML export |
| **Persons** | CAT-02016 | 9 (cross-listed) | ✅ Included in Curam |
| **Appeals** | CAT-01931 | ~3 (estimated) | ❌ Not yet crawled |
| **PSCD** | CAT-01917 | ~5 (estimated) | ❌ Not yet crawled |
| **SAP** | CAT-01918 | ~2 (estimated) | ❌ Not yet crawled |

**Total Target**: 195-205 unique articles × 2 languages = **390-410 total articles**

---

## 2. Implementation Strategy

### 2.1 Three-Phase Approach

#### **Phase 1: Content Fetching** (Estimated: 4-6 hours)
**Objective**: Retrieve full HTML content for all 195+ articles in both languages

**Method**: PowerShell web scraping with ESDC SSL certificate handling

**Steps**:
1. Read `KMT-DATABASE-INVENTORY-COMPLETE.json` for article list
2. For each article PID (KA-#####):
   - Fetch English version: `https://kmt-ogc.service.gc.ca/knowledgebase/article-latest?pid=KA-#####`
   - Fetch French version: `https://kmt-ogc.service.gc.ca/fr/knowledgebase/article-latest?pid=KA-#####`
   - Extract full article content (title, summary, body HTML, metadata)
   - Rate limit: 0.5-1 second delay between requests (195 articles × 2 languages × 1s = ~7 minutes minimum)
3. Save to intermediate JSON format for processing

**Output**: `kmt-articles-raw-en.json`, `kmt-articles-raw-fr.json`

#### **Phase 2: Content Processing** (Estimated: 1-2 hours)
**Objective**: Transform raw HTML into structured XML format

**Steps**:
1. Parse HTML content from article pages
2. Extract article body (remove navigation, headers, footers)
3. Clean HTML (preserve formatting, remove KMT-specific styling)
4. Extract metadata:
   - Title (from H1 or title tag)
   - Summary (from meta description or first paragraph)
   - Categories (from breadcrumb navigation)
   - Tags (from article metadata section)
   - Dates (created, modified from page metadata)
   - Author (if available)
5. Build article object matching XML schema

**Output**: `kmt-articles-processed-en.json`, `kmt-articles-processed-fr.json`

#### **Phase 3: XML Generation** (Estimated: 30 minutes)
**Objective**: Generate final XML files matching existing format

**Steps**:
1. Read processed JSON articles
2. Generate XML structure:
   - XML declaration with UTF-8 encoding
   - Root `<knowledgebase>` element
   - One `<article>` element per article
   - CDATA wrapping for HTML content
   - Proper XML escaping for special characters
3. Validate XML well-formedness
4. Split by system for manageability (optional)

**Output**:
- `knowledge_articles_complete_en.xml` (all 195+ articles)
- `knowledge_articles_complete_fr.xml` (all 195+ articles)

**Optional Split Output**:
- `knowledge_articles_itrds_en.xml` / `*_fr.xml`
- `knowledge_articles_cpms_en.xml` / `*_fr.xml`
- `knowledge_articles_pws_en.xml` / `*_fr.xml`
- `knowledge_articles_curam_en.xml` / `*_fr.xml` (already have R2/R3 subset)

---

## 3. Technical Implementation

### 3.1 PowerShell Crawler Script

**Why PowerShell**: 
- Handles ESDC internal SSL certificates without modification
- Native Windows integration
- Previous success with `Invoke-WebRequest` on KMT categories

**Script**: `scripts/Fetch-KMT-Articles-Full.ps1`

**Key Functions**:
```powershell
function Fetch-ArticleContent {
    param(
        [string]$ArticlePID,
        [string]$Language = "en"  # "en" or "fr"
    )
    
    $baseUrl = if ($Language -eq "fr") {
        "https://kmt-ogc.service.gc.ca/fr/knowledgebase/article-latest"
    } else {
        "https://kmt-ogc.service.gc.ca/knowledgebase/article-latest"
    }
    
    $url = "$baseUrl?pid=$ArticlePID"
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        return Parse-ArticlePage $response.Content
    } catch {
        Write-Warning "[ERROR] Failed to fetch $ArticlePID ($Language): $_"
        return $null
    }
}

function Parse-ArticlePage {
    param([string]$HtmlContent)
    
    # Extract article components using regex patterns
    $article = @{
        Title = Extract-Title $HtmlContent
        Summary = Extract-Summary $HtmlContent
        Content = Extract-Body $HtmlContent
        Categories = Extract-Categories $HtmlContent
        Tags = Extract-Tags $HtmlContent
        DateCreated = Extract-DateCreated $HtmlContent
        DateModified = Extract-DateModified $HtmlContent
        Author = Extract-Author $HtmlContent
    }
    
    return $article
}
```

### 3.2 Content Extraction Patterns

**Based on KMT website structure analysis**:

```powershell
# Title extraction
$title = if ($html -match '<h1[^>]*>(.*?)</h1>') { $matches[1] } else { "" }

# Summary extraction (first paragraph after title)
$summary = if ($html -match '<div class="article-summary"[^>]*>(.*?)</div>') {
    $matches[1] 
} else { 
    # Fallback: first <p> tag
    if ($html -match '<p[^>]*>(.*?)</p>') { $matches[1].Substring(0, [Math]::Min(200, $matches[1].Length)) }
}

# Content extraction (main article body)
$content = if ($html -match '<div class="article-body"[^>]*>(.*?)</div>') {
    $matches[1]
} elseif ($html -match '<article[^>]*>(.*?)</article>') {
    $matches[1]
}

# Category extraction (breadcrumb navigation)
$categories = if ($html -match '<nav class="breadcrumb"[^>]*>(.*?)</nav>') {
    $breadcrumb = $matches[1]
    # Extract category names from breadcrumb links
    [regex]::Matches($breadcrumb, '<a[^>]*>([^<]+)</a>') | ForEach-Object { $_.Groups[1].Value }
}

# Tags extraction
$tags = if ($html -match '<div class="article-tags"[^>]*>(.*?)</div>') {
    $tagSection = $matches[1]
    [regex]::Matches($tagSection, '<span[^>]*>([^<]+)</span>') | ForEach-Object { $_.Groups[1].Value }
}

# Date extraction
$dateCreated = if ($html -match 'data-created="([^"]+)"') { $matches[1] }
$dateModified = if ($html -match 'data-modified="([^"]+)"') { $matches[1] }

# Author extraction
$author = if ($html -match '<meta name="author" content="([^"]+)"') { $matches[1] }
```

### 3.3 XML Generation Logic

**Script**: `scripts/Generate-KMT-XML.ps1`

```powershell
function Generate-XML {
    param(
        [array]$Articles,
        [string]$OutputPath,
        [string]$Language
    )
    
    $xmlSettings = New-Object System.Xml.XmlWriterSettings
    $xmlSettings.Indent = $true
    $xmlSettings.IndentChars = "  "
    $xmlSettings.Encoding = [System.Text.Encoding]::UTF8
    
    $writer = [System.Xml.XmlWriter]::Create($OutputPath, $xmlSettings)
    
    # XML Declaration
    $writer.WriteStartDocument()
    
    # Root element
    $writer.WriteStartElement("knowledgebase")
    
    foreach ($article in $Articles) {
        $writer.WriteStartElement("article")
        
        # Title
        $writer.WriteElementString("title", $article.Title)
        
        # Summary
        $writer.WriteElementString("summary", $article.Summary)
        
        # Content (CDATA section for HTML)
        $writer.WriteStartElement("content")
        $writer.WriteCData($article.Content)
        $writer.WriteEndElement()
        
        # Categories
        $writer.WriteStartElement("categories")
        foreach ($cat in $article.Categories) {
            $writer.WriteElementString("category", $cat)
        }
        $writer.WriteEndElement()
        
        # Tags
        $writer.WriteStartElement("tags")
        foreach ($tag in $article.Tags) {
            $writer.WriteElementString("tag", $tag)
        }
        $writer.WriteEndElement()
        
        # Reference URL
        $refUrl = "https://kmt-ogc.service.gc.ca/knowledgebase/article-latest?pid=$($article.PID)"
        if ($Language -eq "fr") {
            $refUrl = "https://kmt-ogc.service.gc.ca/fr/knowledgebase/article-latest?pid=$($article.PID)"
        }
        $writer.WriteElementString("reference", $refUrl)
        
        # Metadata
        $writer.WriteElementString("datecreated", $article.DateCreated)
        $writer.WriteElementString("datemodified", $article.DateModified)
        $writer.WriteElementString("author", $article.Author)
        
        $writer.WriteEndElement() # </article>
    }
    
    $writer.WriteEndElement() # </knowledgebase>
    $writer.WriteEndDocument()
    $writer.Close()
    
    Write-Host "[PASS] Generated XML: $OutputPath ($($Articles.Count) articles)" -ForegroundColor Green
}
```

---

## 4. Execution Plan

### 4.1 Prerequisites
- [ ] PowerShell 7+
- [ ] Access to ESDC VPN or internal network (kmt-ogc.service.gc.ca)
- [ ] `KMT-DATABASE-INVENTORY-COMPLETE.json` file
- [ ] 2-3 GB disk space for intermediate files and final XML exports

### 4.2 Execution Steps

**Step 1: Prepare Environment** (5 minutes)
```powershell
# Create output directories
New-Item -ItemType Directory -Force -Path ".\output\raw-json"
New-Item -ItemType Directory -Force -Path ".\output\processed-json"
New-Item -ItemType Directory -Force -Path ".\output\xml"
New-Item -ItemType Directory -Force -Path ".\logs"

# Load article inventory
$inventory = Get-Content ".\KMT-DATABASE-INVENTORY-COMPLETE.json" | ConvertFrom-Json
$allArticles = $inventory.categories | ForEach-Object { $_.articles }
Write-Host "[INFO] Loaded $($allArticles.Count) articles from inventory"
```

**Step 2: Fetch English Articles** (60-90 minutes)
```powershell
.\scripts\Fetch-KMT-Articles-Full.ps1 `
    -InventoryFile ".\KMT-DATABASE-INVENTORY-COMPLETE.json" `
    -Language "en" `
    -OutputFile ".\output\raw-json\kmt-articles-raw-en.json" `
    -DelaySeconds 1 `
    -Verbose
```

**Step 3: Fetch French Articles** (60-90 minutes)
```powershell
.\scripts\Fetch-KMT-Articles-Full.ps1 `
    -InventoryFile ".\KMT-DATABASE-INVENTORY-COMPLETE.json" `
    -Language "fr" `
    -OutputFile ".\output\raw-json\kmt-articles-raw-fr.json" `
    -DelaySeconds 1 `
    -Verbose
```

**Step 4: Process Content** (5-10 minutes)
```powershell
.\scripts\Process-KMT-Articles.ps1 `
    -RawJsonFile ".\output\raw-json\kmt-articles-raw-en.json" `
    -OutputFile ".\output\processed-json\kmt-articles-processed-en.json" `
    -Language "en"

.\scripts\Process-KMT-Articles.ps1 `
    -RawJsonFile ".\output\raw-json\kmt-articles-raw-fr.json" `
    -OutputFile ".\output\processed-json\kmt-articles-processed-fr.json" `
    -Language "fr"
```

**Step 5: Generate XML** (2-5 minutes)
```powershell
.\scripts\Generate-KMT-XML.ps1 `
    -ProcessedJsonFile ".\output\processed-json\kmt-articles-processed-en.json" `
    -OutputFile ".\output\xml\knowledge_articles_complete_en.xml" `
    -Language "en"

.\scripts\Generate-KMT-XML.ps1 `
    -ProcessedJsonFile ".\output\processed-json\kmt-articles-processed-fr.json" `
    -OutputFile ".\output\xml\knowledge_articles_complete_fr.xml" `
    -Language "fr"
```

**Step 6: Validate XML** (2-3 minutes)
```powershell
.\scripts\Validate-KMT-XML.ps1 `
    -XmlFile ".\output\xml\knowledge_articles_complete_en.xml" `
    -ReferenceXmlFile ".\knowledge_articles_r2r3_en 2.xml"

.\scripts\Validate-KMT-XML.ps1 `
    -XmlFile ".\output\xml\knowledge_articles_complete_fr.xml" `
    -ReferenceXmlFile ".\knowledge_articles_r2r3_FR.xml"
```

### 4.3 Total Estimated Time
- **Automated execution**: 2.5-3.5 hours (mostly fetching with rate limiting)
- **Manual validation**: 30 minutes
- **Total**: **3-4 hours wall-clock time**

---

## 5. Validation & Quality Assurance

### 5.1 Validation Checklist

**XML Structure Validation**:
- [ ] Well-formed XML (no syntax errors)
- [ ] UTF-8 encoding declaration
- [ ] All required elements present (title, summary, content, reference)
- [ ] CDATA sections properly used for HTML content
- [ ] Special characters properly escaped

**Content Validation**:
- [ ] Article count matches inventory (195+ articles per language)
- [ ] Each article has non-empty title
- [ ] Each article has content body (not just metadata)
- [ ] Reference URLs are valid and match article PIDs
- [ ] Category tags match KMT-DATABASE-INVENTORY categories

**Bilingual Validation**:
- [ ] English and French XML have same article PIDs
- [ ] Article count matches between EN and FR
- [ ] Content is properly translated (not just English duplicated)

**Comparison with Existing XML**:
- [ ] Curam articles (102) match existing `knowledge_articles_r2r3_*.xml`
- [ ] Structure matches existing XML format
- [ ] File sizes reasonable (expected: 10-15 MB per language)

### 5.2 Validation Script

**Script**: `scripts/Validate-KMT-XML.ps1`

```powershell
function Validate-XML {
    param(
        [string]$XmlPath,
        [string]$ReferenceXmlPath
    )
    
    Write-Host "`n[INFO] Validating $XmlPath..." -ForegroundColor Cyan
    
    # Test 1: Well-formed XML
    try {
        [xml]$xml = Get-Content $XmlPath -Encoding UTF8
        Write-Host "[PASS] XML is well-formed" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] XML is NOT well-formed: $_" -ForegroundColor Red
        return $false
    }
    
    # Test 2: Article count
    $articles = $xml.knowledgebase.article
    Write-Host "[INFO] Found $($articles.Count) articles"
    if ($articles.Count -lt 195) {
        Write-Host "[WARN] Expected 195+ articles, found $($articles.Count)" -ForegroundColor Yellow
    } else {
        Write-Host "[PASS] Article count meets minimum threshold" -ForegroundColor Green
    }
    
    # Test 3: Required elements
    $missingElements = 0
    foreach ($article in $articles) {
        if (-not $article.title) { $missingElements++; Write-Host "[WARN] Article missing title: $($article.reference)" }
        if (-not $article.content) { $missingElements++; Write-Host "[WARN] Article missing content: $($article.reference)" }
        if (-not $article.reference) { $missingElements++; Write-Host "[WARN] Article missing reference" }
    }
    
    if ($missingElements -eq 0) {
        Write-Host "[PASS] All articles have required elements" -ForegroundColor Green
    } else {
        Write-Host "[WARN] $missingElements articles missing required elements" -ForegroundColor Yellow
    }
    
    # Test 4: Compare structure with reference XML
    if ($ReferenceXmlPath -and (Test-Path $ReferenceXmlPath)) {
        [xml]$refXml = Get-Content $ReferenceXmlPath -Encoding UTF8
        $refArticle = $refXml.knowledgebase.article[0]
        $newArticle = $xml.knowledgebase.article[0]
        
        $structureMatch = $true
        $refElements = $refArticle | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
        $newElements = $newArticle | Get-Member -MemberType Property | Select-Object -ExpandProperty Name
        
        $missingInNew = $refElements | Where-Object { $_ -notin $newElements }
        if ($missingInNew) {
            Write-Host "[WARN] New XML missing elements from reference: $($missingInNew -join ', ')" -ForegroundColor Yellow
            $structureMatch = $false
        } else {
            Write-Host "[PASS] XML structure matches reference format" -ForegroundColor Green
        }
    }
    
    # Test 5: File size sanity check
    $fileSize = (Get-Item $XmlPath).Length / 1MB
    Write-Host "[INFO] File size: $([Math]::Round($fileSize, 2)) MB"
    if ($fileSize -lt 5) {
        Write-Host "[WARN] File size seems too small (expected 10-15 MB)" -ForegroundColor Yellow
    } elseif ($fileSize -gt 50) {
        Write-Host "[WARN] File size seems too large (expected 10-15 MB)" -ForegroundColor Yellow
    } else {
        Write-Host "[PASS] File size is reasonable" -ForegroundColor Green
    }
    
    Write-Host "`n[COMPLETE] Validation finished`n" -ForegroundColor Cyan
    return $true
}
```

---

## 6. Risk Management

### 6.1 Identified Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **SSL Certificate Issues** | Medium | High | Use PowerShell `Invoke-WebRequest` (proven to work) |
| **Rate Limiting** | Low | Medium | Implement 1-second delays between requests |
| **Incomplete Article Content** | Medium | High | Parse failures logged; manual review of failed articles |
| **Network Timeouts** | Medium | Medium | Retry logic (3 attempts per article) |
| **JavaScript-Rendered Content** | High | High | Some KMT articles may be SPA-rendered; use headless browser fallback |
| **Changed HTML Structure** | Low | Medium | Test extraction patterns on sample articles first |
| **Bilingual Mismatches** | Low | Low | Validate EN/FR pairing by PID |
| **Disk Space** | Low | Low | Monitor disk usage; clean intermediate files after success |

### 6.2 Fallback Plans

**If PowerShell Scraping Fails**:
1. **Option A**: Use Playwright headless browser (handles JavaScript rendering)
2. **Option B**: Request official export API access from KMT administrators
3. **Option C**: Manual export using browser automation (slower but guaranteed)

**If Content Extraction Pattern Fails**:
1. Save raw HTML for manual inspection
2. Use multiple extraction patterns (try selector A, fallback to B, C)
3. Flag articles for manual review

**If Rate Limiting Occurs**:
1. Increase delay between requests to 2-3 seconds
2. Implement exponential backoff
3. Split execution across multiple sessions

---

## 7. Deliverables

### 7.1 Generated Files

**Primary Deliverables**:
1. `knowledge_articles_complete_en.xml` (195+ articles, ~12-15 MB)
2. `knowledge_articles_complete_fr.xml` (195+ articles, ~12-15 MB)

**Optional Split Files** (if manageable size preferred):
3. `knowledge_articles_itrds_en.xml` / `*_fr.xml` (59 articles)
4. `knowledge_articles_cpms_en.xml` / `*_fr.xml` (27 articles)
5. `knowledge_articles_pws_en.xml` / `*_fr.xml` (7 articles)
6. `knowledge_articles_curam_complete_en.xml` / `*_fr.xml` (102 articles, expanded from R2/R3)

**Supporting Files**:
7. `kmt-articles-raw-en.json` (intermediate: raw fetched data)
8. `kmt-articles-raw-fr.json`
9. `kmt-articles-processed-en.json` (intermediate: cleaned data)
10. `kmt-articles-processed-fr.json`
11. `xml-generation-log.txt` (execution log with statistics)
12. `failed-articles.csv` (articles that failed to fetch/process)

### 7.2 Documentation Deliverables

13. **XML-GENERATION-SUMMARY.md**: Execution summary, statistics, known issues
14. **ARTICLE-MAPPING.csv**: Mapping of PIDs to categories, systems, and file locations
15. **VALIDATION-REPORT.md**: Quality assurance results, comparison with reference XML

---

## 8. Next Steps

### 8.1 Immediate Actions (Before Execution)

1. **Verify Access**: Confirm ESDC VPN connection and KMT website accessibility
2. **Test Extraction**: Run pilot test on 5 articles (1 from each system) to validate extraction patterns
3. **Review Reference XML**: Examine `knowledge_articles_r2r3_en 2.xml` structure in detail
4. **Prepare Scripts**: Create all 4 PowerShell scripts (Fetch, Process, Generate, Validate)

### 8.2 Pilot Test Procedure

**Test Articles** (one from each system):
- ITRDS: KA-01215 (Simulation of the Death Benefit)
- CPMS: KA-01347 (Add or Override a Voluntary Tax Withhold)
- PWS: KA-01135 (Assign a Work Item)
- Curam: KA-05215 (Perform Person Evidence Verification)

**Pilot Test Steps**:
```powershell
# Fetch pilot articles
$pilotPIDs = @("KA-01215", "KA-01347", "KA-01135", "KA-05215")
.\scripts\Fetch-KMT-Articles-Full.ps1 -ArticlePIDs $pilotPIDs -Language "en" -PilotMode

# Validate extraction patterns
.\scripts\Validate-Extraction-Patterns.ps1 -PilotArticles ".\output\pilot\*.json"

# Generate pilot XML
.\scripts\Generate-KMT-XML.ps1 -InputJson ".\output\pilot\*.json" -OutputFile ".\output\pilot\pilot_test.xml"

# Compare with reference
.\scripts\Compare-XML-Structure.ps1 `
    -TestXml ".\output\pilot\pilot_test.xml" `
    -ReferenceXml ".\knowledge_articles_r2r3_en 2.xml"
```

### 8.3 Go/No-Go Decision Criteria

**Proceed with Full Execution if**:
- ✅ Pilot test successfully extracts all 4 articles
- ✅ Generated XML structure matches reference XML
- ✅ Content is complete (not truncated)
- ✅ English and French versions are properly paired
- ✅ No SSL certificate errors
- ✅ Extraction patterns work across different systems

**Delay Execution if**:
- ❌ SSL certificate errors persist
- ❌ Content extraction patterns fail on >20% of pilot articles
- ❌ JavaScript rendering prevents content access
- ❌ Network timeouts occur frequently

---

## 9. Success Metrics

### 9.1 Quantitative Metrics

| Metric | Target | Acceptance Threshold |
|--------|--------|----------------------|
| **Articles Fetched** | 195+ per language | ≥95% (185+ articles) |
| **Content Completeness** | 100% have body content | ≥90% |
| **XML Well-Formedness** | 100% valid | 100% (mandatory) |
| **Bilingual Pairing** | 100% EN/FR match | ≥95% |
| **Execution Time** | 3-4 hours | ≤6 hours |
| **Fetch Success Rate** | 100% | ≥95% |
| **File Size** | 10-15 MB per XML | 5-20 MB acceptable range |

### 9.2 Qualitative Metrics

- **Content Accuracy**: Spot-check 20 random articles; content matches website
- **Format Consistency**: All articles follow same XML schema
- **EVA DA Compatibility**: XML can be ingested by existing EVA DA pipeline without errors
- **Maintainability**: Scripts can be re-run for incremental updates

---

## 10. Future Enhancements

### 10.1 Incremental Updates
- Implement "Updated" status marker detection
- Fetch only changed articles (based on datemodified)
- Merge with existing XML (append new, replace updated)

### 10.2 Scheduled Automation
- Schedule weekly/monthly re-export to capture updates
- Set up Azure Function or GitHub Action for automation
- Email notification on completion with statistics

### 10.3 Enhanced Metadata
- Extract related articles (cross-references)
- Capture article views/popularity
- Include version history if available

### 10.4 Quality Improvements
- Add image extraction and embedding
- Preserve formatting (tables, lists, bold/italic)
- Extract code snippets with syntax highlighting
- Handle attachments/downloadable documents

---

## Appendix A: Script Templates

### A.1 Main Orchestration Script

**File**: `scripts/Generate-Complete-KMT-XML.ps1`

```powershell
<#
.SYNOPSIS
    Main orchestration script to generate complete KMT XML exports
.DESCRIPTION
    Executes all phases: Fetch, Process, Generate, Validate
.PARAMETER Language
    Language to process: "en", "fr", or "both"
.PARAMETER SkipFetch
    Skip fetching and use existing raw JSON files
.EXAMPLE
    .\Generate-Complete-KMT-XML.ps1 -Language "both"
#>

param(
    [ValidateSet("en", "fr", "both")]
    [string]$Language = "both",
    
    [switch]$SkipFetch,
    [switch]$PilotMode,
    [int]$DelaySeconds = 1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$projectRoot = $PSScriptRoot | Split-Path
$inventoryFile = Join-Path $projectRoot "KMT-DATABASE-INVENTORY-COMPLETE.json"
$outputRoot = Join-Path $projectRoot "output"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  KMT Complete XML Generation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Phase 1: Fetch Articles
if (-not $SkipFetch) {
    Write-Host "[PHASE 1] Fetching articles from KMT website..." -ForegroundColor Yellow
    
    if ($Language -eq "en" -or $Language -eq "both") {
        & "$PSScriptRoot\Fetch-KMT-Articles-Full.ps1" `
            -InventoryFile $inventoryFile `
            -Language "en" `
            -OutputFile "$outputRoot\raw-json\kmt-articles-raw-en.json" `
            -DelaySeconds $DelaySeconds `
            -PilotMode:$PilotMode
    }
    
    if ($Language -eq "fr" -or $Language -eq "both") {
        & "$PSScriptRoot\Fetch-KMT-Articles-Full.ps1" `
            -InventoryFile $inventoryFile `
            -Language "fr" `
            -OutputFile "$outputRoot\raw-json\kmt-articles-raw-fr.json" `
            -DelaySeconds $DelaySeconds `
            -PilotMode:$PilotMode
    }
}

# Phase 2: Process Content
Write-Host "`n[PHASE 2] Processing article content..." -ForegroundColor Yellow

if ($Language -eq "en" -or $Language -eq "both") {
    & "$PSScriptRoot\Process-KMT-Articles.ps1" `
        -RawJsonFile "$outputRoot\raw-json\kmt-articles-raw-en.json" `
        -OutputFile "$outputRoot\processed-json\kmt-articles-processed-en.json" `
        -Language "en"
}

if ($Language -eq "fr" -or $Language -eq "both") {
    & "$PSScriptRoot\Process-KMT-Articles.ps1" `
        -RawJsonFile "$outputRoot\raw-json\kmt-articles-raw-fr.json" `
        -OutputFile "$outputRoot\processed-json\kmt-articles-processed-fr.json" `
        -Language "fr"
}

# Phase 3: Generate XML
Write-Host "`n[PHASE 3] Generating XML files..." -ForegroundColor Yellow

if ($Language -eq "en" -or $Language -eq "both") {
    & "$PSScriptRoot\Generate-KMT-XML.ps1" `
        -ProcessedJsonFile "$outputRoot\processed-json\kmt-articles-processed-en.json" `
        -OutputFile "$outputRoot\xml\knowledge_articles_complete_en.xml" `
        -Language "en"
}

if ($Language -eq "fr" -or $Language -eq "both") {
    & "$PSScriptRoot\Generate-KMT-XML.ps1" `
        -ProcessedJsonFile "$outputRoot\processed-json\kmt-articles-processed-fr.json" `
        -OutputFile "$outputRoot\xml\knowledge_articles_complete_fr.xml" `
        -Language "fr"
}

# Phase 4: Validate XML
Write-Host "`n[PHASE 4] Validating generated XML..." -ForegroundColor Yellow

if ($Language -eq "en" -or $Language -eq "both") {
    & "$PSScriptRoot\Validate-KMT-XML.ps1" `
        -XmlFile "$outputRoot\xml\knowledge_articles_complete_en.xml" `
        -ReferenceXmlFile "$projectRoot\knowledge_articles_r2r3_en 2.xml"
}

if ($Language -eq "fr" -or $Language -eq "both") {
    & "$PSScriptRoot\Validate-KMT-XML.ps1" `
        -XmlFile "$outputRoot\xml\knowledge_articles_complete_fr.xml" `
        -ReferenceXmlFile "$projectRoot\knowledge_articles_r2r3_FR.xml"
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  [COMPLETE] XML Generation Finished" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Display output files
Write-Host "Generated files:" -ForegroundColor Cyan
Get-ChildItem "$outputRoot\xml\*.xml" | ForEach-Object {
    $sizeMB = [Math]::Round($_.Length / 1MB, 2)
    Write-Host "  - $($_.Name) ($sizeMB MB)" -ForegroundColor White
}
```

---

## Appendix B: Pilot Test Results Template

**File**: `PILOT-TEST-RESULTS.md`

```markdown
# Pilot Test Results - KMT XML Generation

**Date**: YYYY-MM-DD
**Tester**: [Name]
**Environment**: [VPN/DevBox/Local]

## Test Articles
- ITRDS: KA-01215 (Simulation of the Death Benefit)
- CPMS: KA-01347 (Add or Override a Voluntary Tax Withhold)
- PWS: KA-01135 (Assign a Work Item)
- Curam: KA-05215 (Perform Person Evidence Verification)

## Results

### Fetch Phase
- [ ] All 4 articles fetched successfully (EN)
- [ ] All 4 articles fetched successfully (FR)
- [ ] No SSL certificate errors
- [ ] Network latency acceptable (<2s per article)

### Extraction Phase
- [ ] Title extracted correctly (4/4)
- [ ] Summary extracted correctly (4/4)
- [ ] Body content extracted correctly (4/4)
- [ ] Categories extracted correctly (4/4)
- [ ] Tags extracted (if present)
- [ ] Dates extracted (if present)

### XML Generation
- [ ] XML well-formed (validates)
- [ ] Structure matches reference XML
- [ ] CDATA sections properly used
- [ ] Special characters properly escaped
- [ ] File size reasonable (~50-100 KB for 4 articles)

### Bilingual Pairing
- [ ] EN and FR articles have same PIDs
- [ ] Content is properly translated (not duplicated)
- [ ] Both languages have same structure

## Issues Found
[List any issues discovered during pilot test]

## Go/No-Go Decision
- [ ] **GO** - Proceed with full execution
- [ ] **NO-GO** - Address issues before full execution

**Decision Rationale**: [Explain decision]
```

---

**Status**: ✅ Plan Complete - Ready for Implementation  
**Next Action**: Create pilot test scripts and execute pilot test on 4 sample articles  
**Estimated Full Execution Time**: 3-4 hours  
**Expected Output**: 2 complete XML files (~12-15 MB each) with 195+ articles per language
