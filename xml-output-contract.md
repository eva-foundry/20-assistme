# EVA DA XML Parsing Output Contract

## Overview

This document details how EVA Domain Assistant (Information Assistant) processes XML files through the document ingestion pipeline, based on code analysis of the FileLayoutParsingOther Azure Function.

**Last Updated**: 2026-01-21  
**Code Reference**: [`functions/FileLayoutParsingOther/__init__.py`](../../functions/FileLayoutParsingOther/__init__.py)

---

## XML Processing Pipeline

### 1. Entry Point: FileUploadedEtrigger

**File**: `functions/FileUploadedEtrigger/__init__.py`

When a file with `.xml` extension is uploaded:
- **Line 205**: XML is recognized as a parseable format (not plain text)
- Message sent to `non-pdf-submit-queue` for processing by FileLayoutParsingOther

```python
elif file_extension in ["htm", "csv", "docx", "eml", "html", "md", "msg", "pptx", "txt", "xlsx", "xml", "json", "tsv"]:
    # Route to FileLayoutParsingOther for structured parsing
```

---

### 2. XML Parsing: FileLayoutParsingOther

**File**: `functions/FileLayoutParsingOther/__init__.py`

#### Parsing Function: `PartitionFile()` (Lines 467-471)

```python
elif file_extension_lower == ".xml":
    from unstructured.partition.xml import partition_xml
    
    elements = partition_xml(file=bytes_io)
```

**Key Details**:
- Uses **unstructured.io** library's `partition_xml()` function
- Parses XML into `Element` objects with text and metadata
- **NO** special handling for namespaces, schemas, or validation
- Expects well-formed XML (will raise exception if malformed)

---

### 3. Element Structure

`partition_xml()` returns a list of `Element` objects with:

**Properties**:
- `element.text` - Extracted text content from XML elements
- `element.category` - Element type (e.g., "Title", "Text", "Table", "NarrativeText")
- `element.metadata.page_number` - Page number (defaults to 1 for XML)

**Example Element**:
```python
Element(
    text="This is the content of an XML element",
    category="NarrativeText",
    metadata=ElementMetadata(page_number=1)
)
```

---

### 4. Title Extraction (Lines 547-555)

EVA DA attempts to extract a title from the first `Title` category element:

```python
title = ""
for i, element in enumerate(elements):
    if title == "" and element.category == "Title":
        title = element.text  # Capture first title
        break
```

**Important**: If no element has `category == "Title"`, title remains empty string.

---

### 5. Chunking: `_optimize_chunking()` (Lines 94-120)

After parsing, elements are chunked using `unstructured.chunking.title.chunk_by_title()`:

```python
from unstructured.chunking.title import chunk_by_title

NEW_AFTER_N_CHARS = 1500
COMBINE_UNDER_N_CHARS = 500
MAX_CHARACTERS = 2000

chunks = chunk_by_title(
    elements,
    multipage_sections=True,
    new_after_n_chars=NEW_AFTER_N_CHARS,
    combine_text_under_n_chars=COMBINE_UNDER_N_CHARS,
    max_characters=MAX_CHARACTERS
)
```

**Chunking Rules**:
- Combines elements into chunks up to 2000 characters
- Creates new chunk after 1500 characters
- Combines small elements under 500 characters
- Respects title boundaries (new chunk after Title elements)

---

### 6. Chunk Processing: `_process_chunks_optimized()` (Lines 204-282)

Each chunk is written to Azure Blob Storage and metadata prepared for Search indexing.

**Key Fields Written** (via `utilities.write_chunk()`):

```python
utilities.write_chunk(
    blob_name,           # Original file name (e.g., "proj1-upload/AssistMe/knowledge_articles_r2r3_FR.xml")
    blob_uri,            # Blob URI
    f"{i}",              # Chunk index (0, 1, 2, ...)
    token_count,         # Token count of chunk text
    final_chunk_text,    # Chunk content (potentially with metadata prefix)
    page_list,           # [1] for XML (no page concept)
    "",                  # Subtitle (empty)
    title,               # Extracted title or ""
    "",                  # Section name (empty)
    MediaType.TEXT,      # Media type
    blob_content_storage # Content container name
)
```

---

### 7. Output to Search Index

The `write_chunk()` function creates a JSON file in blob storage that is later indexed by TextEnrichment function.

**Expected Search Index Document Structure**:

```json
{
  "id": "<unique-id>",
  "chunk_id": "0",
  "chunk_file": "proj1-upload/AssistMe/knowledge_articles_r2r3_FR.xml",
  "file_name": "knowledge_articles_r2r3_FR.xml",
  "file_uri": "https://.../proj1-upload/AssistMe/knowledge_articles_r2r3_FR.xml",
  "pages": [1],
  "offset": 0,
  "title": "Extracted Title or Empty",
  "section": "",
  "content": "Chunk text content extracted from XML elements...",
  "category": "NarrativeText",
  "filepath": "/AssistMe/",
  "metadata": {},
  "document_id": "<doc-id>"
}
```

**Metadata Preserved**:
- ✅ Original file name (`chunk_file`, `file_name`)
- ✅ Blob URI (`file_uri`)
- ✅ Title (if extracted from first Title element)
- ✅ Content text (all XML text concatenated)
- ❌ XML structure (tags, attributes) **NOT preserved**
- ❌ XML element names **NOT preserved**
- ❌ XML namespaces **NOT preserved**

---

## How `partition_xml()` Works

Based on `unstructured.io` library documentation:

### Text Extraction Rules

1. **Element Text**: Extracts text content from XML elements
2. **No Tag Names**: Element tag names are **NOT** included in output
3. **No Attributes**: XML attributes are **NOT** included in output
4. **Flattening**: Nested elements are flattened into sequential text

### Example:

**Input XML**:
```xml
<document>
  <title>Knowledge Article</title>
  <content>
    <paragraph>This is the first paragraph.</paragraph>
    <paragraph>This is the second paragraph.</paragraph>
  </content>
</document>
```

**Output Elements** (conceptual):
```python
[
  Element(text="Knowledge Article", category="Title", metadata=...),
  Element(text="This is the first paragraph.", category="NarrativeText", metadata=...),
  Element(text="This is the second paragraph.", category="NarrativeText", metadata=...)
]
```

**Indexed Content** (after chunking):
```
Knowledge Article
This is the first paragraph.
This is the second paragraph.
```

---

## Error Handling

**Line 472**: If `partition_xml()` raises an exception:

```python
except Exception as e:
    raise UnstructuredError(f"An error occurred trying to parse the file: {str(e)}") from e
```

**Status Log Entry**: Error logged to Cosmos DB:
```python
statusLog.upsert_document(
    blob_name,
    f"{function_name} - An error occurred - {str(e)}",
    StatusClassification.ERROR,
    State.ERROR
)
```

**Common Errors**:
- **Malformed XML**: Unclosed tags, invalid syntax
- **Encoding issues**: Non-UTF-8 characters without declaration
- **Namespace errors**: While `partition_xml` can handle namespaces, it may fail on complex schemas
- **Empty elements**: Files with no extractable text

---

## Key Takeaways

### What EVA DA Does with XML:
1. ✅ Extracts all text content from XML elements
2. ✅ Attempts to identify titles
3. ✅ Chunks text into 1500-2000 character segments
4. ✅ Preserves file metadata (name, URI, path)
5. ✅ Indexes content for full-text search

### What EVA DA Does NOT Do:
1. ❌ Preserve XML structure (tags, hierarchy)
2. ❌ Validate against XML schemas
3. ❌ Extract or preserve XML attributes
4. ❌ Handle XML namespaces specially
5. ❌ Preserve element names in indexed content

### Requirements for Successful XML Ingestion:
1. ✅ Well-formed XML (parseable by Python's XML libraries)
2. ✅ UTF-8 encoding (or explicit encoding declaration)
3. ✅ No illegal characters in tag names
4. ✅ Extractable text content (not just empty tags)
5. ⚠️ Simple structure preferred (no complex namespaces)

---

## Evidence Sources

This document is based on:
- **Code Analysis**: [`functions/FileLayoutParsingOther/__init__.py`](../../functions/FileLayoutParsingOther/__init__.py) lines 1-571
- **Unstructured.io Library**: [partition_xml documentation](https://unstructured-io.github.io/unstructured/bricks.html#partition-xml)
- **Status Log Entries**: Cosmos DB `statusdb/statuscontainer`
- **Search Index**: Azure AI Search index structure

---

## Related Documentation

- [AssistMe XML Ingestion Proof](./assistme-xml-ingestion-proof.md)
- [XML Comparison and Validation Checklist](./xml-validation-checklist.md)
- [Evidence Discovery Scripts README](../../tools/evidence/README.md)
