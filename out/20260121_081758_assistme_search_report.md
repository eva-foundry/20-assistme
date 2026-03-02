# AssistMe XML Ingestion Evidence Report

**Generated:** 2026-01-21T08:18:04.980098
**Investigation Target:** AssistMe XML files ingested Nov 2025

## Executive Summary

**Verdict:** XML metadata appears to be preserved as structured fields

## Configuration

- **Search Endpoint:** https://infoasst-search-hccld2.search.windows.net/
- **Cosmos URL:** https://infoasst-cosmos-hccld2.documents.azure.com:443/
- **Indexes Investigated:** 1

## Indexes Discovered

- `proj1-index`

## Schema Analysis

### XML Metadata Fields Found (2)

| Index | Field Name | Type | Searchable | Filterable |
|-------|------------|------|------------|------------|
| proj1-index | `title` | Edm.String | ✓ | ✗ |
| proj1-index | `translated_title` | Edm.String | ✓ | ✗ |

## Flattening Evidence

No evidence of XML flattening found in content fields.

## Sample Documents

### Document 1
- **Index:** proj1-index
- **Score:** 17.8461
- **Query Type:** folder_marker

**Fields:**
```json
{
  "title": "Welcome to the EVA Domain Assistant Accelerator Program",
  "translated_title": "Welcome to the EVA Domain Assistant Accelerator Program",
  "file_uri": "https://infoasststorehccld2.blob.core.windows.net/proj1-upload/AICoE-DAAP-Welcome-and-Registration-EN.docx",
  "id": "QUlDb0UtREFBUC1XZWxjb21lLWFuZC1SZWdpc3RyYXRpb24tRU4uZG9jeC9BSUNvRS1EQUFQLVdlbGNvbWUtYW5kLVJlZ2lzdHJhdGlvbi1FTi0zLmpzb24=",
  "chunk_file": "AICoE-DAAP-Welcome-and-Registration-EN.docx/AICoE-DAAP-Welcome-and-Registration-EN-3.json",
  "content": "Welcome to the EVA Domain Assistant Accelerator Program \n  \n  \n File Requirements:\n\nUse a replicable naming convention for your documents.\n\nIf you don’t have a naming convention, we recommend reviewing this Information Management Best Practices quick reference card for consideration. This support tool for naming files may also be helpful.\n\nTagging:\n\nIn the EVA Domain Assistant, tagging is the process of adding descriptive labels to uploaded documents for easy classification, organization, and retrieval. These tags help the system pull out specific files in response to queries and understand the document's context to give relevant answers. You can tag documents at the time of upload.\n\nPrepare for Success with EVA\n\nWe recommend reviewing the following resources to help you maximize your use ..."
}
```

### Document 2
- **Index:** proj1-index
- **Score:** 14.5874
- **Query Type:** folder_marker

**Fields:**
```json
{
  "title": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016",
  "translated_title": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016",
  "file_uri": "https://infoasststorehccld2.blob.core.windows.net/proj1-upload/AssistMe/knowledge_articles_r2r3_en_2.xml",
  "id": "QXNzaXN0TWUva25vd2xlZGdlX2FydGljbGVzX3IycjNfZW5fMi54bWwva25vd2xlZGdlX2FydGljbGVzX3IycjNfZW5fMi0xOTcuanNvbg==",
  "chunk_file": "AssistMe/knowledge_articles_r2r3_en_2.xml/knowledge_articles_r2r3_en_2-197.json",
  "content": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016 \n  \n  \n reserve the most prioritized task. Note: The Get Next Task... from a manual work queue is to be generally used when working on manual workload or campaign queues and you must be subscribed to the manual work queue by your team lead. Tasks are grouped by High, Medium and Low priority and sorted within the priority group as follows: Receipt Date (oldest to newest) Creation Date (oldest to newest) Due Date (oldest to newest) Note: When a Mailroom Clerk receives a new document for upload, Cúram will create a new task which will go to the allocation batch. If the new task's Skill Type matches the Skill Type of the officer allocated to another task for the same client, Cúram will bundle the tasks to ..."
}
```

### Document 3
- **Index:** proj1-index
- **Score:** 14.4668
- **Query Type:** folder_marker

**Fields:**
```json
{
  "title": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016",
  "translated_title": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016",
  "file_uri": "https://infoasststorehccld2.blob.core.windows.net/proj1-upload/AssistMe/knowledge_articles_r2r3_FR.xml",
  "id": "QXNzaXN0TWUva25vd2xlZGdlX2FydGljbGVzX3IycjNfRlIueG1sL2tub3dsZWRnZV9hcnRpY2xlc19yMnIzX0ZSLTE5Ny5qc29u",
  "chunk_file": "AssistMe/knowledge_articles_r2r3_FR.xml/knowledge_articles_r2r3_FR-197.json",
  "content": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016 \n  \n  \n reserve the most prioritized task. Note: The Get Next Task... from a manual work queue is to be generally used when working on manual workload or campaign queues and you must be subscribed to the manual work queue by your team lead. Tasks are grouped by High, Medium and Low priority and sorted within the priority group as follows: Receipt Date (oldest to newest) Creation Date (oldest to newest) Due Date (oldest to newest) Note: When a Mailroom Clerk receives a new document for upload, Cúram will create a new task which will go to the allocation batch. If the new task's Skill Type matches the Skill Type of the officer allocated to another task for the same client, Cúram will bundle the tasks to ..."
}
```


## Errors Encountered

No errors encountered.

## Conclusion

This report provides evidence-based analysis of AssistMe XML ingestion.
Review the full schema and search hits JSON files for complete details.
