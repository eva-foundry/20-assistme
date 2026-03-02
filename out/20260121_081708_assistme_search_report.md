# AssistMe XML Ingestion Evidence Report

**Generated:** 2026-01-21T08:17:25.406664
**Investigation Target:** AssistMe XML files ingested Nov 2025

## Executive Summary

**Verdict:** Insufficient evidence to determine XML metadata preservation

## Configuration

- **Search Endpoint:** https://infoasst-search-hccld2.search.windows.net/
- **Cosmos URL:** https://infoasst-cosmos-hccld2.documents.azure.com:443/
- **Indexes Investigated:** 1

## Indexes Discovered

- `index-jurisprudence`

## Schema Analysis

### No XML Metadata Fields Found

⚠ No fields with names suggesting XML metadata preservation (reference, title, subtitle, etc.)

## Flattening Evidence

No evidence of XML flattening found in content fields.

## Sample Documents


## Errors Encountered

- **Stage:** get_index_schema
  - **Error:** Schema fetch failed for index-jurisprudence: () No index with the name 'index-jurisprudence' was found in the service 'infoasst-search-hccld2'.
Code: 
Message: No index with the name 'index-jurisprudence' was found in the service 'infoasst-search-hccld2'.
  - **Suggestion:** Required RBAC: Search Index Data Reader


## Conclusion

This report provides evidence-based analysis of AssistMe XML ingestion.
Review the full schema and search hits JSON files for complete details.
