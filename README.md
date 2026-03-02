# EVA DA XML Ingestion Evidence System

## Overview

This directory contains a comprehensive evidence-based investigation system for proving how EVA Domain Assistant ingests XML files and diagnosing why XML files fail.

**Objective**: Produce evidence-backed conclusions (not assumptions) using Azure resources, logs, and code analysis.

---

## 📁 Structure

```
docs/evidence/
  ├── README.md                           ← This file
  ├── assistme-xml-ingestion-proof.md     ← Main evidence report (fill in after running scripts)
  ├── xml-output-contract.md              ← How EVA DA processes XML (code analysis)
  ├── xml-validation-checklist.md         ← Requirements for valid XML
  └── out/                                ← Evidence outputs (JSON + Markdown)
      ├── group_resources_*.json/md
      ├── assistme_statuslog_*.json/md
      ├── appinsights_assistme_*.json/md
      └── search_index_assistme_*.json/md

tools/evidence/
  ├── README.md                           ← How to run scripts
  ├── discover_group_resources.py         ← Query Cosmos for resource mappings
  ├── query_statuslog_for_assistme.py     ← Query status logs for AssistMe XML
  ├── appinsights_trace_assistme_ingestion.py  ← Query App Insights traces
  └── search_index_probe.py               ← Query Azure AI Search index
```

---

## 🚀 Quick Start

### 1. Install Dependencies

```powershell
# From repo root
cd tools\evidence
pip install azure-identity azure-cosmos azure-search-documents azure-monitor-query python-dotenv
```

### 2. Run Evidence Collection

```powershell
# Run all scripts in order
python tools\evidence\discover_group_resources.py
python tools\evidence\query_statuslog_for_assistme.py
python tools\evidence\appinsights_trace_assistme_ingestion.py
python tools\evidence\search_index_probe.py
```

**Outputs**: Saved to `docs/evidence/out/` with timestamps

### 3. Review Evidence

1. **Markdown Reports** (human-readable):
   - `docs/evidence/out/*_YYYYMMDD_HHMMSS.md`

2. **JSON Data** (programmatic):
   - `docs/evidence/out/*_YYYYMMDD_HHMMSS.json`

### 4. Update Main Report

Fill in evidence sections in:
- `docs/evidence/assistme-xml-ingestion-proof.md`

---

## 📚 Documentation

### Main Documents

| Document | Purpose | Audience |
|----------|---------|----------|
| [assistme-xml-ingestion-proof.md](./assistme-xml-ingestion-proof.md) | **Main evidence report**: Proves how AssistMe XML was ingested and why new XML fails | You (fill in after running scripts) |
| [xml-output-contract.md](./xml-output-contract.md) | **Code analysis**: How `partition_xml` processes XML, what fields are preserved | Developers |
| [xml-validation-checklist.md](./xml-validation-checklist.md) | **Validation checklist**: Requirements for XML to pass ingestion | Everyone |

### Script Documentation

See [tools/evidence/README.md](../../tools/evidence/README.md) for detailed script usage.

---

## 🔍 Evidence Sources

### Azure Resources

| Resource | Purpose | Script |
|----------|---------|--------|
| **Cosmos DB** `statusdb/statuscontainer` | Status log entries for file ingestion | `query_statuslog_for_assistme.py` |
| **Azure AI Search** index | Indexed document chunks | `search_index_probe.py` |
| **Application Insights** | Trace logs and exceptions | `appinsights_trace_assistme_ingestion.py` |
| **Cosmos DB** group mappings | Upload/content containers, indexes | `discover_group_resources.py` |

### Code Analysis

| File | Purpose | Analysis |
|------|---------|----------|
| `functions/FileLayoutParsingOther/__init__.py` | XML parsing and chunking | [xml-output-contract.md](./xml-output-contract.md) |
| `functions/FileUploadedEtrigger/__init__.py` | File upload routing | Mentioned in docs |

---

## ✅ What This System Proves

### 1. How AssistMe XML Was Ingested (November 2025)

**Evidence**:
- ✅ Status log entries showing "Complete" state
- ✅ Search index documents containing extracted content
- ✅ Application Insights traces showing successful parsing
- ✅ Blob chunks created in content container

**Documented in**: [assistme-xml-ingestion-proof.md](./assistme-xml-ingestion-proof.md) Part 1

---

### 2. What EVA DA Does with XML

**Evidence**:
- ✅ Code analysis of `partition_xml()` function
- ✅ Chunking logic with `chunk_by_title()`
- ✅ Search index schema showing preserved fields
- ✅ Comparison of input XML vs. indexed content

**Documented in**: 
- [assistme-xml-ingestion-proof.md](./assistme-xml-ingestion-proof.md) Part 2
- [xml-output-contract.md](./xml-output-contract.md)

**Key Findings**:
- ✅ Extracts plain text from XML elements
- ✅ Chunks into 1500-2000 character segments
- ✅ Preserves file metadata (name, URI, path)
- ❌ Does NOT preserve XML tags, attributes, or structure

---

### 3. Why New XML Fails

**Evidence**:
- ✅ Status log error messages
- ✅ Application Insights exception traces
- ✅ XML validation rules from code analysis
- ✅ Comparison with working AssistMe XML

**Documented in**:
- [assistme-xml-ingestion-proof.md](./assistme-xml-ingestion-proof.md) Part 3
- [xml-validation-checklist.md](./xml-validation-checklist.md)

**Common Failure Patterns**:
1. Malformed XML (unclosed tags, invalid syntax)
2. Invalid tag names (starting with numbers)
3. Encoding mismatches (UTF-16 vs UTF-8)
4. Unescaped characters (`<`, `>`, `&`)
5. Multiple root elements

---

## 🛠️ Troubleshooting

### No Results from Scripts

**Possible Causes**:
- Date range incorrect (scripts search November 2025)
- File names don't match search patterns
- Authentication issues (need Reader roles on Azure resources)

**Solutions**:
- Adjust query date ranges in scripts
- Broaden search terms (e.g., search for folder path)
- Verify `az login` authentication

---

### Authentication Errors

**Required Roles**:
- Cosmos DB: **Cosmos DB Data Reader**
- Azure Search: **Search Index Data Reader**
- App Insights: **Log Analytics Reader** (requires workspace ID)

**Fix**:
```powershell
az login
# Verify roles in Azure Portal → IAM
```

---

### Missing Environment Variables

**Required in `app/backend/backend.env`**:
```
COSMOSDB_URL=https://infoasst-cosmos-hccld2.documents.azure.com:443/
COSMOSDB_DB=statusdb
COSMOSDB_LOG_CONTAINER=statuscontainer
AZURE_SEARCH_SERVICE=<service-name>
AZURE_SEARCH_INDEX=<index-name>
APPLICATIONINSIGHTS_CONNECTION_STRING=<connection-string>
```

**Optional** (for App Insights queries):
```
LOG_ANALYTICS_WORKSPACE_ID=<workspace-id>
```

---

## 📊 Workflow: From Evidence to Conclusion

```
1. Run Evidence Scripts
   ↓
2. Review Markdown Reports
   ↓
3. Identify Error Messages/Patterns
   ↓
4. Compare with Validation Checklist
   ↓
5. Update assistme-xml-ingestion-proof.md
   ↓
6. Formulate Concrete Diagnosis
   ↓
7. Fix XML Issues
   ↓
8. Re-test Ingestion
```

---

## 📝 Next Steps

### For Your Investigation

1. **Run Scripts**:
   ```powershell
   python tools\evidence\discover_group_resources.py
   python tools\evidence\query_statuslog_for_assistme.py
   python tools\evidence\appinsights_trace_assistme_ingestion.py
   python tools\evidence\search_index_probe.py
   ```

2. **Review Outputs**:
   - Open `docs/evidence/out/*_YYYYMMDD_HHMMSS.md` files
   - Look for error messages, exception traces
   - Compare with working AssistMe XML structure

3. **Update Main Report**:
   - Fill in evidence sections in `assistme-xml-ingestion-proof.md`
   - Paste JSON snippets, error messages
   - Document concrete diagnosis

4. **Validate Your XML**:
   - Use checklist: `xml-validation-checklist.md`
   - Test locally: `[xml]$xml = Get-Content "file.xml"`
   - Compare structure to AssistMe XML

5. **Test Fix**:
   - Upload corrected XML to EVA DA
   - Monitor status log with `query_statuslog_for_assistme.py`
   - Verify indexed content with `search_index_probe.py`

---

## 📖 Additional Resources

- **EVA DA Architecture**: See `analysis-output/SYSTEM-DOCUMENTATION-COMPREHENSIVE.md`
- **Pipeline Details**: See `docs/features/features.md`
- **Azure Resources**: See Azure Portal for resource IDs and configuration

---

## 🤝 Contributing

To add new evidence scripts:

1. Create script in `tools/evidence/`
2. Use `DefaultAzureCredential` for auth
3. Output JSON + Markdown to `docs/evidence/out/`
4. Update `tools/evidence/README.md` with usage
5. Reference in `assistme-xml-ingestion-proof.md`

---

## 📅 Maintenance

- **Update scripts** when Azure resource names change
- **Update code analysis** when FileLayoutParsingOther function changes
- **Re-run evidence collection** when investigating new failures

---

**Last Updated**: 2026-01-21
