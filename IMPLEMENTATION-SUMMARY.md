# Evidence System Implementation - Summary

## What Was Created

A comprehensive evidence-gathering and analysis system to prove how EVA DA ingests XML files and diagnose failures.

**Date**: 2026-01-21  
**Repository**: EVA-JP-v1.2  
**Workspace**: c:\Users\marco.presta\OneDrive - ESDC EDSC\Documents\AICOE\EVA-JP-v1.2

---

## 📦 Deliverables

### 1. Evidence Collection Scripts (`tools/evidence/`)

| Script | Purpose | Azure Resource |
|--------|---------|----------------|
| **discover_group_resources.py** | Discover Cosmos DB group mappings, containers, indexes | Cosmos DB |
| **query_statuslog_for_assistme.py** | Query status logs for AssistMe XML ingestion records | Cosmos DB statusdb/statuscontainer |
| **appinsights_trace_assistme_ingestion.py** | Query App Insights for XML parsing traces/errors | Application Insights |
| **search_index_probe.py** | Query Azure AI Search for indexed AssistMe content | Azure AI Search |

**All scripts**:
- ✅ Use `DefaultAzureCredential` (Entra ID)
- ✅ Load environment from `app/backend/backend.env` and `scripts/environments/.env`
- ✅ Output JSON + Markdown to `docs/evidence/out/`
- ✅ Include error handling and logging
- ✅ Runnable on Windows PowerShell

---

### 2. Documentation (`docs/evidence/`)

| Document | Purpose | Status |
|----------|---------|--------|
| **README.md** | Master index and quick start guide | ✅ Complete |
| **assistme-xml-ingestion-proof.md** | Main evidence report (template to fill in) | ⚠️ Template (fill after running scripts) |
| **xml-output-contract.md** | Code analysis: how partition_xml processes XML | ✅ Complete |
| **xml-validation-checklist.md** | XML validation requirements and common failures | ✅ Complete |

---

### 3. Script Documentation (`tools/evidence/README.md`)

- Installation instructions
- Usage for each script
- Troubleshooting guide
- Output file descriptions

---

## 🎯 What This System Proves

### Question 1: How did EVA DA ingest AssistMe XML in Nov 2025?

**Evidence to collect**:
- ✅ Cosmos DB status log entries (state transitions, timestamps)
- ✅ Azure AI Search index documents (indexed chunks)
- ✅ Application Insights traces (parsing logs)

**Scripts**: `query_statuslog_for_assistme.py`, `search_index_probe.py`, `appinsights_trace_assistme_ingestion.py`

**Documented in**: `assistme-xml-ingestion-proof.md` Part 1

---

### Question 2: What does EVA DA do with XML parse output?

**Evidence collected**:
- ✅ Code analysis of `FileLayoutParsingOther/__init__.py`
- ✅ `partition_xml()` function behavior (lines 467-471)
- ✅ Chunking logic with `chunk_by_title()` (lines 94-120)
- ✅ Search index schema from indexed documents

**Key Findings**:
- Uses `unstructured.partition.xml.partition_xml()` library
- Extracts plain text from XML elements (tags NOT preserved)
- Chunks into 1500-2000 character segments
- Indexes: file metadata + content text (structure lost)

**Documented in**: `xml-output-contract.md`

---

### Question 3: Why does new XML fail?

**Evidence to collect**:
- ✅ Status log error messages
- ✅ App Insights exception traces
- ✅ Comparison with working AssistMe XML structure

**Common failures** (based on code analysis):
1. Malformed XML (unclosed tags)
2. Invalid tag names (starting with numbers)
3. Encoding mismatches
4. Unescaped special characters
5. Multiple root elements

**Documented in**: `xml-validation-checklist.md`, `assistme-xml-ingestion-proof.md` Part 3

---

## 📋 How to Use This System

### Step 1: Install Dependencies

```powershell
pip install azure-identity azure-cosmos azure-search-documents azure-monitor-query python-dotenv
```

### Step 2: Verify Environment Variables

**Check `app/backend/backend.env`**:
```
COSMOSDB_URL=https://infoasst-cosmos-hccld2.documents.azure.com:443/
COSMOSDB_DB=statusdb
COSMOSDB_LOG_CONTAINER=statuscontainer
AZURE_SEARCH_SERVICE=<service>
AZURE_SEARCH_INDEX=<index>
APPLICATIONINSIGHTS_CONNECTION_STRING=<connection-string>
```

### Step 3: Run Evidence Collection

```powershell
# From repo root
python tools\evidence\discover_group_resources.py
python tools\evidence\query_statuslog_for_assistme.py
python tools\evidence\appinsights_trace_assistme_ingestion.py
python tools\evidence\search_index_probe.py
```

### Step 4: Review Evidence

**Location**: `docs/evidence/out/`

**Files**:
- `*_YYYYMMDD_HHMMSS.md` - Human-readable reports
- `*_YYYYMMDD_HHMMSS.json` - Programmatic data

**What to look for**:
- Status log: `state: "Error"`, `error_message` field
- App Insights: Exception traces with XML filename
- Search index: Presence/absence of indexed documents

### Step 5: Update Main Report

**File**: `docs/evidence/assistme-xml-ingestion-proof.md`

**Fill in sections**:
- Part 1.2: Status log query results
- Part 1.3: Search index document samples
- Part 1.4: App Insights trace samples
- Part 3.4: Concrete failure diagnosis

### Step 6: Validate Your XML

**Use checklist**: `docs/evidence/xml-validation-checklist.md`

**Key checks**:
- [ ] Well-formed XML (test with `[xml]$xml = Get-Content "file.xml"`)
- [ ] Single root element
- [ ] Valid tag names (no leading numbers, no spaces)
- [ ] UTF-8 encoding with matching declaration
- [ ] Escaped special characters
- [ ] Extractable text content

### Step 7: Test Fix

Upload corrected XML to EVA DA and re-run evidence collection to verify success.

---

## 🔑 Key Technical Details

### XML Parsing Pipeline

```
FileUploadedEtrigger
  ↓ (detects .xml extension)
non-pdf-submit-queue
  ↓
FileLayoutParsingOther.PartitionFile()
  ↓ (line 467-471)
partition_xml(file=bytes_io)
  ↓ (returns Element objects)
Title extraction (line 547-555)
  ↓
Chunking with chunk_by_title() (line 94-120)
  ↓
Write chunks to blob storage (line 122-169)
  ↓
text-enrichment-queue
  ↓
TextEnrichment function
  ↓
Azure AI Search index
```

### Element Structure

```python
Element(
    text="Extracted text content",
    category="Title" | "NarrativeText" | "Text",
    metadata=ElementMetadata(page_number=1)
)
```

### Chunking Parameters

```python
NEW_AFTER_N_CHARS = 1500
COMBINE_UNDER_N_CHARS = 500
MAX_CHARACTERS = 2000
```

### Search Index Fields (from XML)

- `chunk_file`: Original file path
- `file_name`: Filename
- `file_uri`: Blob URI
- `content`: Extracted text
- `title`: First Title element or ""
- `pages`: [1] (default for XML)
- `section`: "" (empty)

---

## 🚨 Critical Constraints

### What partition_xml Does

- ✅ Extracts text from XML elements
- ✅ Categorizes elements (Title, Text, etc.)
- ❌ Does NOT preserve XML tag names
- ❌ Does NOT preserve XML attributes
- ❌ Does NOT preserve XML structure/hierarchy

### XML Requirements

**Must satisfy**:
1. Well-formed XML (parseable by Python's XML parser)
2. UTF-8 encoding (or explicit declaration)
3. Valid tag names (XML naming rules)
4. Escaped special characters (`<`, `>`, `&`)
5. Single root element

**Recommended**:
- No namespaces (simpler is better)
- No schema references (not validated)
- Extractable text content (not empty elements)

---

## 📊 Evidence Workflow Summary

```
[Run Scripts] → [Collect Evidence] → [Review Outputs]
     ↓
[Identify Errors] → [Compare with Checklist] → [Diagnose Root Cause]
     ↓
[Update Report] → [Fix XML] → [Re-test]
```

---

## 📁 File Structure Created

```
EVA-JP-v1.2/
├── tools/
│   └── evidence/
│       ├── README.md                              ← Script usage guide
│       ├── discover_group_resources.py            ← Cosmos resource discovery
│       ├── query_statuslog_for_assistme.py        ← Status log queries
│       ├── appinsights_trace_assistme_ingestion.py ← App Insights traces
│       └── search_index_probe.py                  ← Search index queries
│
└── docs/
    └── evidence/
        ├── README.md                              ← Master index (this area)
        ├── assistme-xml-ingestion-proof.md        ← Main evidence report (template)
        ├── xml-output-contract.md                 ← Code analysis
        ├── xml-validation-checklist.md            ← Validation requirements
        └── out/                                   ← Evidence outputs (created by scripts)
            ├── group_resources_YYYYMMDD_HHMMSS.json/md
            ├── assistme_statuslog_YYYYMMDD_HHMMSS.json/md
            ├── appinsights_assistme_YYYYMMDD_HHMMSS.json/md
            └── search_index_assistme_YYYYMMDD_HHMMSS.json/md
```

---

## ✅ Next Actions for You

1. **Run scripts** to collect evidence from Azure resources
2. **Review outputs** in `docs/evidence/out/*.md`
3. **Fill in** `assistme-xml-ingestion-proof.md` with evidence
4. **Identify** specific error from status log or App Insights
5. **Compare** your XML structure to AssistMe XML
6. **Validate** your XML with checklist
7. **Fix** identified issues
8. **Re-test** by uploading to EVA DA

---

## 📖 References

- **Main Report**: `docs/evidence/assistme-xml-ingestion-proof.md`
- **Code Analysis**: `docs/evidence/xml-output-contract.md`
- **Validation**: `docs/evidence/xml-validation-checklist.md`
- **Script Guide**: `tools/evidence/README.md`
- **Source Code**: `functions/FileLayoutParsingOther/__init__.py`

---

**Implementation Complete** ✅

All scripts, documentation, and evidence templates are ready. Run the scripts to gather evidence and complete the investigation.
