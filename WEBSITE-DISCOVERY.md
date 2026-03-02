# AssistMe (KMT) Website Discovery

**URL**: https://kmt-ogc.service.gc.ca/  
**Full Name**: Knowledge Management Tool (KMT)  
**Owner**: ESDC - Pensions Programs (CPP, OAS, CPPD)  
**Discovery Date**: 2026-01-30  

---

## Executive Summary

The **Knowledge Management Tool (KMT)** is ESDC's intranet-based knowledge repository for Pensions guidance (CPP, OAS, CPPD programs). It serves as a centralized portal where procedures, bulletins, announcements, and reference materials are published and maintained.

**Key Finding**: This is **not a data export tool** but a **knowledge base CMS** where content is created, published, and managed. XML exports would come from the underlying CMS platform (likely Microsoft Dynamics 365 or similar).

---

## System Overview

### Purpose
- **Primary Function**: Self-serve portal for Pensions guidance
- **Content Types**: 
  - Knowledge articles (procedures, scenarios)
  - Bulletins (implementation updates)
  - Announcements (policy changes, outages)
  - Resources (forms, letters, toolboxes)
  - Training materials

### Target Users
- CPP processors
- OAS administrators  
- CPPD case workers
- Service Canada staff
- Pensions operations teams

---

## Site Structure

### Main Sections

#### 1. **Home Page**
- **URL**: https://kmt-ogc.service.gc.ca/
- **Features**:
  - Search functionality
  - Recent announcements (with "New" badges)
  - Trending articles
  - Benefits Toolbox (quick links)
  - System outage notifications

#### 2. **Understanding the KMT** (Help/Guide)
- **URL**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01529
- **Contains**: Navigation guide, how to use features
- **Key Article**: KA-04319 - Understanding the Knowledge Management Tool

#### 3. **Resources and Tools**
- **URL**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01359
- **Sub-Sections**:
  - **Announcements** (KA-04435)
  - **Benefits Toolbox** (KA-01960)
    - CPP-specific tools (production schedules, benefit rates)
    - OAS-specific tools (payment schedules, benefit rates)
    - All Programs (CRA contacts, country codes, tax rates)
  - **NEXO** (PowerApps link)
  - **Bulletins** (KA-04729)
    - Implementation bulletins for system releases
    - Policy change notifications
    - Process updates
  - **Corporate Correspondence Tool** (KA-03459)
  - **EReference Library** (KA-03137)
    - Functional Guidance and Procedures Index (KA-05204)
  - **Forms and Letters** (CAT-01524, KA-03134)
  - **Information Sharing Agreements** (KA-04980)
  - **System and Network Outages** (CAT-01900, KA-04864)
  - **Training** (CAT-01528, KA-03144)

#### 4. **Trending Topics**
- **URL**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01532
- **Recent Examples**:
  - CPPD Reassessment (KA-05573)
  - CPMS Release Fall 2025 (KA-05601)
  - eServices Release 7 Fall 2025 (KA-05600)
  - Process Automation—CPP Record of Earnings (KA-05004)
  - Automatic Enrolment—OAS Pension and the GIS (KA-01746)

---

## Article Identifier Pattern

All knowledge articles use a **PID (Primary ID)** format:
- **Pattern**: `KA-#####` (5 digits)
- **Examples**:
  - KA-05582 - Dual Workflow Charts for CPP and CPPD Processors
  - KA-05624 - GIS Automatic Enrolment Program Compliance Review
  - KA-05618 - 2025 Tax Slips Reminders and Information
  - KA-04435 - All Announcements Index

Categories use **CID (Category ID)** format:
- **Pattern**: `CAT-#####` (5 digits)
- **Examples**:
  - CAT-01529 - Understanding the KMT
  - CAT-01359 - Resources and Tools
  - CAT-01532 - Trending
  - CAT-01524 - Forms and Letters

---

## External Links & Integrations

### SharePoint Integration
Multiple links to `014gc.sharepoint.com` for:
- Production schedules
- Benefit rate tables
- Workload system guidelines
- Country code lists

**Example URLs**:
- `https://014gc.sharepoint.com/sites/ops-prl-brt/Operations1/Production-Schedules/`
- `https://014gc.sharepoint.com/sites/CPPandOASBM-MARPCetSV/PWSGuide/`

### Internal Tools
- **CRT-ORC** (crt-orc.esdc-edsc.canada.ca): Processing center locations, time frames
- **NEXO**: PowerApps application (link to apps.powerapps.com)
- **ITRDS**: System releases and maintenance bulletins

### External Resources
- Canada.ca (public-facing benefit info)
- Bank of Canada (exchange rates, currency converter)
- Service Canada office locator

---

## Content Types & Metadata

### Article Types Observed
1. **Knowledge Articles** - Procedural guidance, scenarios
2. **Implementation Bulletins** - System release information
3. **Announcements** - Policy changes, outages, updates
4. **Resources** - Forms, templates, reference materials
5. **Training Materials** - Learning content

### Status Indicators
- **New** - Recently published articles (visible badge)
- **Updated** - Recently revised content
- No badge - Established content

### Recent Topics (November 2025 - January 2026)
- Migration to Cúram system
- CPP Enhancement implementation
- CPMS/ITRDS system releases
- Automatic enrolment programs
- Bank accounts wizard (OAS on BDM)
- Tax slip processing
- Returned correspondence procedures

---

## XML Export Hypothesis

### Where XML Might Come From

Based on website structure, XML files could be generated from:

1. **CMS Backend Export**
   - Bulk export of knowledge articles
   - Metadata + content in structured format
   - Likely from Microsoft Dynamics 365 Customer Service or similar CMS

2. **Article-Level Export**
   - Individual article XML with metadata
   - Fields: PID, title, content, category, tags, publish date

3. **Category/Bulk Export**
   - Export entire category tree (e.g., all bulletins)
   - Hierarchical XML structure

4. **Search Results Export**
   - Export filtered search results to XML
   - Multiple articles in single file

### Expected XML Structure (Hypothesis)

Based on CMS patterns, XML likely contains:

```xml
<KnowledgeBase>
  <Article>
    <PID>KA-05582</PID>
    <Title>Dual Workflow Charts for CPP and CPPD Processors</Title>
    <Category>CAT-01359</Category>
    <PublishDate>2025-11-XX</PublishDate>
    <Status>New</Status>
    <Content>
      <Section>
        <Heading>Overview</Heading>
        <Body>...</Body>
      </Section>
    </Content>
    <Metadata>
      <Program>CPP</Program>
      <DocumentType>Chart</DocumentType>
      <Tags>workflow,processing,dual</Tags>
    </Metadata>
  </Article>
  <!-- More articles... -->
</KnowledgeBase>
```

### Fields EVA DA Needs
According to `xml-output-contract.md`:
- ✅ Text content (extracted from XML elements)
- ✅ File metadata (name, URI, path)
- ❌ XML structure (tags, hierarchy) - NOT preserved
- ❌ XML attributes - NOT preserved

---

## Export Mechanism (To Investigate)

### Potential Export Methods

1. **Admin Portal** (not visible to regular users)
   - Backend CMS admin interface
   - Bulk export functionality
   - Scheduled/manual exports

2. **API Endpoints** (programmatic)
   - REST API for content retrieval
   - Dynamics 365 Web API
   - OData queries

3. **PowerShell/Scripts** (automated)
   - SharePoint export scripts
   - Dynamics 365 SDK scripts
   - Custom export automation

4. **Manual Export** (per-article)
   - Right-click → Save As XML (if available)
   - Print → Save as PDF/XML
   - Browser developer tools

### Next Steps to Discover Export Method

1. **Check with KMT Administrators**
   - Contact knowledge base owners
   - Ask about bulk export capabilities
   - Request sample XML export

2. **Inspect Browser Network Traffic**
   - Open article in browser
   - Check Network tab for API calls
   - Look for JSON/XML responses

3. **Review Dynamics 365 Documentation**
   - Search for knowledge article export
   - Check OData query examples
   - Review SDK documentation

4. **Test Article URLs**
   - Try adding `?format=xml` to article URLs
   - Test API endpoints: `/api/data/v9.0/knowledgearticles`
   - Check for RSS/Atom feeds

---

## Known Article Examples

### Recently Published (November-December 2025)

| PID | Title | Type | Date |
|-----|-------|------|------|
| KA-05582 | Dual Workflow Charts for CPP and CPPD Processors | Resource | Nov 2025 |
| KA-05624 | GIS Automatic Enrolment Program Compliance Review | Announcement | Dec 2025 |
| KA-05618 | 2025 Tax Slips Reminders and Information | Announcement | Dec 2025 |
| KA-05626 | Bank Accounts Wizard in OAS on BDM Release 3.4 | Announcement | Dec 2025 |
| KA-05532 | Simplified CPPD Client Engagement National Pilot | Announcement | Nov 2025 |
| KA-05544 | Migration to Cúram (Pensions)—Procedures in the KMT | Resource | Updated |
| KA-05606 | Returned Correspondence | Resource | New |
| KA-05617 | Cancellation of the OAS Pension and Benefits Procedures | Resource | - |
| KA-05612 | Automated Correspondence in Cúram | Resource | - |
| KA-05601 | CPMS Release Fall 2025 (Implementation Bulletin) | Bulletin | - |
| KA-05600 | eServices Release 7 Fall 2025 (Implementation Bulletin) | Bulletin | - |
| KA-05610 | ITRDS December 2025 Release (Implementation Bulletin) | Bulletin | - |

---

## Technical Observations

### Website Technology Stack
- **CMS Platform**: Likely Microsoft Dynamics 365 Customer Service
- **Authentication**: Government of Canada SSO (likely ADFS/Azure AD)
- **Frontend**: Server-rendered HTML (minimal JavaScript)
- **URL Pattern**: Clean URLs with category IDs and article PIDs
- **Search**: Integrated search functionality (header search bar)

### Navigation Patterns
- Breadcrumb navigation
- Category-based browsing
- Tag/keyword filtering (likely)
- Related articles (not visible in fetched content)

### Content Management Features
- Article versioning ("Updated" badge)
- Publish date tracking
- Status indicators (New, Updated)
- Category hierarchy
- Cross-linking between articles

---

## Questions to Answer

### For KMT Administrators
1. How do you export multiple knowledge articles at once?
2. Is there an XML export feature in the admin portal?
3. What is the underlying CMS platform?
4. Can you share a sample XML export of 2-3 articles?
5. Are there API endpoints for programmatic access?

### For EVA DA Integration
1. What XML structure was used in the original AssistMe ingestion?
2. Were articles exported individually or in bulk?
3. What metadata fields were included in the XML?
4. How was the XML generated (manual, script, API)?
5. Can we access the original XML file that was successfully ingested?

---

## Comparison with EVA DA Requirements

### EVA DA XML Processing (from `xml-output-contract.md`)

**What EVA DA Does**:
- ✅ Extracts plain text from all XML elements
- ✅ Chunks text into 1500-2000 character segments
- ✅ Preserves file metadata (name, URI, path)
- ✅ Indexes content for search
- ❌ Does NOT preserve XML tags/structure
- ❌ Does NOT preserve XML attributes
- ❌ Does NOT maintain hierarchical relationships

**Implication for KMT XML**:
- Article structure (sections, headings) will be flattened
- Content will be chunked arbitrarily (mid-paragraph splits possible)
- Links between articles will be lost
- Metadata (PID, category, tags) must be in file metadata, not XML structure

### Recommended XML Format for EVA DA

To optimize for EVA DA ingestion, XML should:

1. **Include all text content in elements** (not attributes)
   ```xml
   <!-- Good -->
   <Title>Dual Workflow Charts</Title>
   
   <!-- Bad - attribute will be lost -->
   <Article title="Dual Workflow Charts">
   ```

2. **Put important metadata in file path/name**
   ```
   AssistMe/CPP/Bulletins/KA-05601_CPMS_Release_Fall_2025.xml
   ```

3. **Use flat structure** (avoid deep nesting)
   ```xml
   <Article>
     <PID>KA-05601</PID>
     <Title>...</Title>
     <Content>Full article text here...</Content>
   </Article>
   ```

4. **Ensure UTF-8 encoding** (avoid UTF-16)
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   ```

5. **Escape special characters** properly
   - `<` → `&lt;`
   - `>` → `&gt;`
   - `&` → `&amp;`

---

## Next Actions

### Immediate (Evidence Gathering)
1. ✅ Run `discover_group_resources.py` - Find AssistMe container mappings
2. ✅ Run `query_statuslog_for_assistme.py` - Find original XML ingestion logs
3. ✅ Run `search_index_probe.py` - Examine indexed AssistMe content
4. ⏳ Contact KMT administrators for export documentation

### Short-Term (XML Acquisition)
1. Request original XML file from AssistMe upload
2. Compare original XML structure with indexed content
3. Document any transformations/losses during ingestion
4. Identify why new XML fails vs. original XML

### Medium-Term (Process Documentation)
1. Create XML export SOP (Standard Operating Procedure)
2. Document required XML structure for EVA DA compatibility
3. Create validation checklist for new XML files
4. Establish testing workflow before production upload

---

## References

- **KMT Home**: https://kmt-ogc.service.gc.ca/
- **Understanding KMT**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01529
- **Resources**: https://kmt-ogc.service.gc.ca/category/?id=CAT-01359
- **Evidence Scripts**: `tools/evidence/`
- **XML Processing Code**: `functions/FileLayoutParsingOther/__init__.py`
- **Validation Checklist**: `docs/eva-foundation/projects/20-AssistMe/xml-validation-checklist.md`

---

**Discovery Status**: Initial reconnaissance complete  
**Next Step**: Run evidence collection scripts to find original XML  
**Last Updated**: 2026-01-30
