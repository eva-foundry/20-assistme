# AssistMe XML Ingestion Evidence Collection

**Investigation Goal:** Determine exactly how EVA DA ingested AssistMe XML files in November 2025, specifically whether XML metadata elements (e.g., `<reference>`, `<title>`, `<subtitle>`) were preserved as structured fields or flattened into plain text content.

**Status:** Evidence collection framework created. **Execute scripts to populate this document with findings.**

---

## Investigation Approach

This investigation follows a systematic, evidence-based methodology:

1. **Azure AI Search Schema Analysis**
   - Discover search index names from Cosmos DB group mappings
   - Retrieve index schemas to identify field definitions
   - Determine if XML metadata fields exist as separate, indexed fields

2. **Search Query Evidence Collection**
   - Execute targeted searches for AssistMe content using multiple strategies:
     - Filename markers (`knowledge_articles_r2r3`)
     - Folder path markers (`proj1-upload/AssistMe`)
     - Content phrases extracted from actual documents
   - Retrieve top-ranked documents with full field data
   - Analyze whether XML metadata appears in dedicated fields vs. embedded in content

3. **Status Log Analysis** *(supplementary)*
   - Query Cosmos DB status logs for processing history
   - Identify pipeline stages and state transitions
   - Detect parsing errors or metadata extraction failures

---

## Files Under Investigation

The following AssistMe XML files were ingested on **2025-11-04**:

- `proj1-upload/AssistMe/knowledge_articles_r2r3_FR.xml`
- `proj1-upload/AssistMe/knowledge_articles_r2r3_en_2.xml`

---

## Evidence Collection Scripts

### Script 1: Search Schema & Content Analysis

**File:** `tools/evidence/prove_assistme_xml_ingestion.py`

**Purpose:**
- Load configuration from `backend.env` (Entra ID auth only, no keys)
- Discover search indexes from Cosmos DB group map
- Retrieve index schemas to identify all fields
- Execute searches targeting AssistMe content
- Analyze whether XML metadata exists as structured fields

**Authentication:**
- Uses `DefaultAzureCredential` (Entra ID)
- Required RBAC roles:
  - **Cosmos DB Data Reader** (for group map discovery)
  - **Search Index Data Reader** (for schema and queries)

**Outputs:**
- `docs/evidence/out/<timestamp>_assistme_search_schema.json` - Full index schemas
- `docs/evidence/out/<timestamp>_assistme_search_hits.json` - Raw search results
- `docs/evidence/out/<timestamp>_assistme_search_report.md` - Human-readable analysis

**Run Command:**
```powershell
python tools\evidence\prove_assistme_xml_ingestion.py
```

---

### Script 2: Status Log Analysis

**File:** `tools/evidence/prove_assistme_statuslog.py`

**Purpose:**
- Query Cosmos DB `statusdb/statuscontainer` for AssistMe file logs
- Show state transitions through processing pipeline
- Identify any parsing errors or metadata extraction issues

**Authentication:**
- Uses `DefaultAzureCredential` (Entra ID)
- Required RBAC role: **Cosmos DB Data Reader**

**Outputs:**
- `docs/evidence/out/<timestamp>_assistme_statuslog.json` - Raw status logs
- `docs/evidence/out/<timestamp>_assistme_statuslog_report.md` - Processing timeline

**Run Command:**
```powershell
python tools\evidence\prove_assistme_statuslog.py
```

---

## Configuration (from backend.env)

```env
AZURE_SEARCH_SERVICE=infoasst-search-hccld2
AZURE_SEARCH_SERVICE_ENDPOINT=https://infoasst-search-hccld2.search.windows.net/
COSMOSDB_URL=https://infoasst-cosmos-hccld2.documents.azure.com:443/
COSMOSDB_LOG_DATABASE_NAME=statusdb
COSMOSDB_LOG_CONTAINER_NAME=statuscontainer
COSMOSDB_DATABASE_GROUP_MAP=groupsToResourcesMap
COSMOSDB_CONTAINER_GROUP_MAP=groupResourcesMapContainer
KB_FIELDS_CONTENT=content
KB_FIELDS_SOURCEFILE=file_uri
KB_FIELDS_PAGENUMBER=pages
KB_FIELDS_CHUNKFILE=chunk_file
```

---

## Evidence Analysis Framework

Once scripts are executed, this section will be populated with evidence to answer:

### Question 1: Does XML Metadata Survive as Structured Fields?

**Answer:** *[TO BE DETERMINED FROM EVIDENCE]*

**Evidence Required:**
- Index schema showing fields named `reference`, `title`, `subtitle`, `section`, `url`, or similar
- Field types (String, Collection, etc.)
- Searchability and filterability attributes
- Sample document showing populated metadata fields

**Possible Outcomes:**
- ✅ **YES - Structured Preservation:** Schema contains dedicated XML metadata fields, and search results show these fields populated with values from XML elements
- ❌ **NO - Flattened:** Schema lacks XML metadata fields, and content field contains XML tags as plain text (e.g., `<reference>XYZ</reference>` appears in content)
- ⚠️ **PARTIAL:** Some metadata fields exist (e.g., title) but others (e.g., reference, subtitle) are missing

---

### Question 2: How Does This Impact Retrieval and Answers?

**If Structured (YES):**
- XML metadata fields can be used for filtering, faceting, and boosting
- Retrieval can prioritize documents by metadata (e.g., filter by section, boost by reference type)
- Answers can cite metadata fields directly (e.g., "According to reference ABC-123...")
- Hybrid search can leverage metadata embeddings separately from content

**If Flattened (NO):**
- XML metadata treated as plain text within content
- No field-level filtering or boosting on metadata
- Metadata only influences retrieval through full-text and semantic search on content
- Citations cannot reference structured metadata fields
- `<reference>` and `<title>` values are searchable but not semantically distinguished from other text

---

### Question 3: Sample Document Evidence

*[TO BE POPULATED WITH ACTUAL SEARCH RESULTS]*

**Expected Fields to Analyze:**
- `id` / `chunk_id` - Document identifier
- `file_uri` - Source file path
- `chunk_file` - Chunk identifier
- `pages` - Page numbers
- `content` - Main text content
- `reference` *(if structured)* - XML reference field
- `title` *(if structured)* - XML title field
- `subtitle` *(if structured)* - XML subtitle field
- `section` *(if structured)* - XML section field
- `url` *(if structured)* - XML URL field
- `metadata` *(if structured)* - Generic metadata JSON

**Sample Document (Placeholder):**
```json
{
  "@search.score": 0.XXX,
  "id": "...",
  "file_uri": "proj1-upload/AssistMe/knowledge_articles_r2r3_en_2.xml",
  "chunk_file": "...",
  "pages": "...",
  "content": "...[400-800 char snippet]...",
  "title": "[IF STRUCTURED: Title value]",
  "reference": "[IF STRUCTURED: Reference value]",
  "subtitle": "[IF STRUCTURED: Subtitle value]"
}
```

---

## Status Log Evidence

*[TO BE POPULATED AFTER RUNNING prove_assistme_statuslog.py]*

**Key Questions:**
- What pipeline stages did AssistMe XML files pass through?
- Were there any parsing errors or warnings?
- Did metadata extraction succeed or fail?
- What timestamps mark key processing milestones?

---

## Conclusion

**Final Verdict:** *[TO BE DETERMINED AFTER EVIDENCE COLLECTION]*

**Recommendations:**
*[Based on findings, recommend next steps such as:]*
- If flattened: Consider re-ingesting with XML parsing enabled
- If structured: Verify approaches use metadata fields for filtering/boosting
- If RBAC blocked: Request specific roles and re-run investigation

---

## Execution Instructions

### Prerequisites

1. **Python Environment:**
   ```powershell
   cd tools\evidence
   pip install -r requirements.txt
   ```

2. **Azure Authentication:**
   - Ensure you're logged into Azure CLI or have valid Entra ID credentials
   - Scripts use `DefaultAzureCredential` (no keys required)

3. **RBAC Permissions:**
   - **Cosmos DB Data Reader** on:
     - `infoasst-cosmos-hccld2` database: `groupsToResourcesMap`
     - `infoasst-cosmos-hccld2` database: `statusdb`
   - **Search Index Data Reader** on:
     - `infoasst-search-hccld2` service

### Run Evidence Collection

```powershell
# Step 1: Collect search schema and content evidence
python tools\evidence\prove_assistme_xml_ingestion.py

# Step 2: Collect status log evidence
python tools\evidence\prove_assistme_statuslog.py

# Step 3: Review generated reports
cd docs\evidence\out
ls *assistme*
```

### Expected Outputs

After running both scripts, you will have:

- **6 evidence files** in `docs/evidence/out/`:
  - `<timestamp>_assistme_search_schema.json`
  - `<timestamp>_assistme_search_hits.json`
  - `<timestamp>_assistme_search_report.md`
  - `<timestamp>_assistme_statuslog.json`
  - `<timestamp>_assistme_statuslog_report.md`
  - This document updated with findings

### Next Steps After Evidence Collection

1. **Review Generated Reports:**
   - Open markdown reports for human-readable summaries
   - Open JSON files for detailed raw data

2. **Update This Document:**
   - Fill in "Evidence Analysis Framework" section with findings
   - Answer the three key questions with citations
   - Write final conclusion and recommendations

3. **If RBAC Blocked:**
   - Scripts will print exact 403 errors and required role names
   - Request permissions and re-run
   - Scripts continue with what they can access (graceful degradation)

---

## Troubleshooting

### Permission Errors

If you see:
```
✗ Cosmos DB access failed: (Forbidden) ...
```

**Solution:**
- Request **Cosmos DB Data Reader** role on resource group `infoasst-hccld2`
- Or use a DevBox with pre-configured access

### No Indexes Found

If scripts report "No indexes found":
- Check that `groupsToResourcesMap` database contains group mappings
- Verify index names manually in Azure Portal → AI Search service
- Edit script to use hardcoded index name if needed

### Empty Search Results

If searches return no hits:
- Verify AssistMe files were fully processed (check status logs)
- Confirm index is populated: Azure Portal → Search Explorer
- Try broader search terms (e.g., just "AssistMe")

---

## Appendix: Evidence File Locations

All evidence outputs are saved to:

```
docs/evidence/out/
├── <timestamp>_assistme_search_schema.json
├── <timestamp>_assistme_search_hits.json
├── <timestamp>_assistme_search_report.md
├── <timestamp>_assistme_statuslog.json
└── <timestamp>_assistme_statuslog_report.md
```

**Note:** Timestamps use format `YYYYMMDD_HHMMSS` for chronological sorting.
