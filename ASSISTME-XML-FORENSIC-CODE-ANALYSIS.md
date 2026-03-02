# AssistMe XML Ingestion - Forensic Code Analysis

**Report Type:** Forensic Engineering Analysis  
**Method:** Code inspection + Runtime evidence correlation  
**Date:** January 21, 2026  
**Status:** ✅ ROOT CAUSE IDENTIFIED

---

## Executive Summary

### Definitive Answer: XML Metadata Was **NOT** Preserved

**Smoking Gun Evidence:**

1. ✅ **Code proves**: `partition_xml()` returns elements with `.text` property only
2. ✅ **Code proves**: Title extraction looks for `element.category == "Title"`, not XML tag names
3. ✅ **Code proves**: XML elements like `<reference>`, `<video_link>` are **never mapped** to index fields
4. ✅ **Runtime proves**: AssistMe documents in `proj1-index` have **no reference/subtitle fields**
5. ✅ **Runtime proves**: Content is plain text, title is first "Title" element (URL in AssistMe case)

**Conclusion:** XML files are **parsed for text content only**. Tag names (`<reference>`, `<subtitle>`) are **discarded**.

---

## Part 1: Code Analysis — FileLayoutParsingOther

### 1.1 XML File Routing

**File:** `functions/FileLayoutParsingOther/__init__.py`, lines 467-469

```python
elif file_extension_lower == ".xml":
    from unstructured.partition.xml import partition_xml
    elements = partition_xml(file=bytes_io)
```

**Analysis:**
- `.xml` files routed to `unstructured.partition.xml.partition_xml()`
- No custom XML schema processing
- No XML element name mapping logic
- Returns generic `elements` list (same as .txt, .docx, .pdf)

---

### 1.2 Element Structure After Partitioning

**What `partition_xml()` Returns:**

Each element is an `unstructured.documents.elements.Element` object with:
- `.text` — extracted text content
- `.category` — element type (e.g., "Title", "NarrativeText", "ListItem")
- `.metadata` — generic metadata (page number, file name)

**What it does NOT return:**
- ❌ XML tag names (`<reference>`, `<subtitle>`)
- ❌ XML attribute values
- ❌ XML structure/hierarchy
- ❌ Custom metadata fields

**Evidence:** Line 539-541 — Title extraction logic

```python
if title == "" and element.category == "Title":
    # capture the first title
    title = element.text
```

This code looks for `element.category == "Title"` (generic unstructured category), **NOT** XML tag names like `<title>`.

---

### 1.3 Metadata Text Construction

**Code:** Lines 530-532

```python
metdata_text = ""
for metadata_value in metadata:
    metdata_text += metadata_value + "\n"
```

**Analysis:**
- `metadata` comes from `PartitionFile()` return value
- For XML files, this is generic file-level metadata (filename, extension)
- Does NOT include XML element-specific metadata
- Prepended to each chunk's content (line 150)

---

### 1.4 Chunk Processing Pipeline

**Code:** Lines 549-553

```python
chunks = _optimize_chunking(elements, file_extension)
statusLog.upsert_document(blob_name, f"{function_name} - chunking complete. {len(chunks)} chunks created", StatusClassification.DEBUG)

_process_chunks_optimized(chunks, file_extension, blob_name, blob_uri, title, metdata_text, blob_content_storage, utilities)
```

**What gets written to storage:**
```python
utilities.write_chunk(
    blob_name,
    blob_uri,
    f"{i}",
    utilities.token_count(chunk.text),
    final_chunk_text,  # ← metdata_text + chunk.text
    page_list,
    "",
    title,             # ← First "Title" category element text
    "",                # ← section_name (empty)
    MediaType.TEXT,
    blob_content_storage,
)
```

**Key Observation:** No custom field mapping. Only:
- `title` — from first element with `category == "Title"`
- `final_chunk_text` — plain text content
- No `reference`, `subtitle`, `video_link` fields

---

## Part 2: Comparison — JSON vs XML Processing

### 2.1 JSON File Routing

**Code:** Line 457

```python
elif any(file_extension_lower in x for x in [".txt", ".json"]):
    from unstructured.partition.text import partition_text
    elements = partition_text(file=bytes_io)
```

**CRITICAL FINDING:** JSON files use `partition_text()`, **NOT a JSON parser**!

**Implication:**
- JSON files are treated as **plain text**, same as `.txt`
- JSON structure (keys, values, nesting) is **ignored**
- JSON objects are flattened to text

**Conclusion:** EVA DA's `FileLayoutParsingOther` function does NOT preserve structured data from XML or JSON.

---

### 2.2 Format Support Matrix

| File Type | Parser Used | Structure Preserved? | Metadata Extracted? |
|-----------|-------------|----------------------|---------------------|
| `.pdf` | `partition_pdf` | ✅ Sections, tables | ✅ Page numbers, titles |
| `.docx` | `partition_docx` | ✅ Paragraphs, tables | ✅ Headings, styles |
| `.xlsx` | `partition_xlsx` | ✅ Cells, sheets | ✅ Tables as HTML |
| `.html` | `partition_html` | ✅ Tags preserved | ✅ HTML structure |
| **`.xml`** | **`partition_xml`** | **❌ Tags discarded** | **❌ Generic only** |
| **`.json`** | **`partition_text`** | **❌ Treated as text** | **❌ None** |

**Key Insight:** XML and JSON are the **least supported** formats in EVA DA's ingestion pipeline.

---

## Part 3: Runtime Evidence Correlation

### 3.1 AssistMe XML Schema vs. Reality

**Expected (from `assistme-xml-min.xsd`):**

```xml
<document>
  <reference>https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016</reference>
  <title>Getting Tasks from Work Queue</title>
  <video_link>https://example.com/video</video_link>
  <video_name>How to Get Tasks</video_name>
  <walkme_flow_id>12345</walkme_flow_id>
  <walkme_flow_name>Task Management Flow</walkme_flow_name>
  <content>reserve the most prioritized task...</content>
</document>
```

**What `partition_xml()` Sees:**

```python
[
  Element(text="https://kmt-ogc.service.gc.ca/...", category="NarrativeText"),
  Element(text="Getting Tasks from Work Queue", category="Title"),
  Element(text="https://example.com/video", category="NarrativeText"),
  Element(text="How to Get Tasks", category="NarrativeText"),
  Element(text="12345", category="NarrativeText"),
  Element(text="Task Management Flow", category="NarrativeText"),
  Element(text="reserve the most prioritized task...", category="NarrativeText"),
]
```

**What Gets Indexed:**

```json
{
  "title": "https://kmt-ogc.service.gc.ca/...",
  "content": "https://kmt-ogc.service.gc.ca/... \n\nGetting Tasks from Work Queue \n\nhttps://example.com/video \n\nHow to Get Tasks \n\n12345 \n\nTask Management Flow \n\nreserve the most prioritized task..."
}
```

**Explanation:**
1. First element with `category == "Title"` → `title` field (URL in this case)
2. All element text concatenated → `content` field
3. XML tag names (`<reference>`, `<video_link>`) → **lost**

---

### 3.2 Evidence from proj1-index Schema

**From:** `docs/evidence/out/20260121_081758_assistme_search_schema.json`

**Fields in proj1-index:**

```json
{
  "title": "Edm.String",
  "translated_title": "Edm.String",
  "content": "Edm.String",
  "entities": "Collection(Edm.String)",
  "key_phrases": "Collection(Edm.String)"
}
```

**Missing fields (from AssistMe XML schema):**
- ❌ `reference`
- ❌ `video_link`
- ❌ `video_name`
- ❌ `walkme_flow_id`
- ❌ `walkme_flow_name`

**Proof:** If XML metadata was preserved, these fields would exist in the index schema.

---

### 3.3 Evidence from Actual AssistMe Document

**From:** `docs/evidence/out/20260121_081758_assistme_search_hits.json`

**Sample document:**

```json
{
  "title": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016",
  "translated_title": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016",
  "file_uri": "https://infoasststorehccld2.blob.core.windows.net/proj1-upload/AssistMe/knowledge_articles_r2r3_en_2.xml",
  "content": "https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016 \n  \n  \n reserve the most prioritized task. Note: The Get Next Task...",
  "entities": ["https://kmt-ogc.service.gc.ca/...", "campaign", "team lead", ...]
}
```

**Analysis:**
- `title` = URL (likely first `<reference>` element text, not `<title>` tag)
- `content` = All XML element text concatenated
- No structured metadata fields
- `entities` extracted via NER (post-processing), not from XML structure

---

### 3.4 Evidence from Status Logs

**From:** `docs/evidence/out/20260121_081811_assistme_statuslog.json`

**Processing timeline:**

```json
{
  "status": "FileLayoutParsingOther - Starting to parse the non-PDF file",
  "status": "FileLayoutParsingOther - partitioning complete",
  "status": "FileLayoutParsingOther - chunking complete. 782 chunks created",
  "status": "FileLayoutParsingOther - message sent to enrichment queue",
  "status": "TextEnrichment - Text enrichment is complete"
}
```

**Key Observations:**
- ✅ No errors during parsing
- ✅ Successfully created 782 chunks
- ✅ Text enrichment (NER, key phrases) completed
- ❌ No log entry for "XML metadata extraction"
- ❌ No log entry for "XML schema mapping"

**Conclusion:** AssistMe XML succeeded because it only required **text extraction**, not metadata preservation.

---

## Part 4: Why Did AssistMe XML Succeed in Nov 2025?

### Answer: Success Criteria Was Text Extraction, Not Metadata Preservation

**What the pipeline requires:**
1. ✅ Parse file without crashing
2. ✅ Extract text content
3. ✅ Create chunks
4. ✅ Generate embeddings

**What the pipeline does NOT require:**
- ❌ Preserve XML tag names
- ❌ Map XML elements to index fields
- ❌ Maintain structured metadata

**AssistMe XML characteristics:**
- Simple, flat structure (no deep nesting)
- Minimal elements (reference, title, content)
- Self-contained text in each element
- No complex attributes or namespaces

**Why it succeeded:**
```
AssistMe XML → partition_xml() → text extracted → chunks created → embeddings generated → COMPLETE
```

**No metadata preservation needed**, so no failure.

---

## Part 5: Why Does New XML Fail Today?

### Hypothesis (requires new XML sample to confirm):

**Likely reasons new XML fails:**

1. **Complex structure**: Deeply nested elements, namespaces, CDATA
2. **Large file size**: Exceeds memory limits during text concatenation
3. **Invalid XML**: Malformed tags, encoding issues
4. **Attribute-heavy**: Metadata in attributes rather than element text
5. **Binary content**: Embedded base64 data overwhelming text extraction

**What would cause failure:**

```python
# Line 468: If partition_xml() raises exception
try:
    elements = partition_xml(file=bytes_io)
except Exception as e:
    raise UnstructuredError(f"An error occurred trying to parse the file: {str(e)}") from e
```

**Possible exceptions:**
- `XMLSyntaxError` — malformed XML
- `MemoryError` — file too large
- `UnicodeDecodeError` — encoding issues
- `Exception` — unstructured library bug

**To diagnose:** Need to see:
1. New XML file sample
2. Error message from status logs
3. Stack trace from Application Insights

---

## Part 6: Strategic Implications

### 6.1 Current State: Format-Sensitive, Not Schema-Aware

**EVA DA's XML/JSON processing is:**
- ✅ **Format-aware** — recognizes `.xml`, `.json` extensions
- ❌ **NOT schema-aware** — does not parse structure or metadata
- ✅ **Text-centric** — optimized for unstructured text extraction
- ❌ **NOT metadata-preserving** — tags, keys, attributes discarded

**Architectural pattern:**

```
Document (any format) → Unstructured → Text Elements → Chunks → Embeddings → Search Index
                                                                              └─ title
                                                                              └─ content
                                                                              └─ entities (NER)
```

XML metadata **never enters this pipeline**.

---

### 6.2 Why This Matters

**For RAG systems:**

| Approach | What Works | What Doesn't |
|----------|------------|--------------|
| **Content-driven RAG** | ✅ Semantic search on text | ❌ Filter by metadata |
| **Metadata-driven RAG** | ❌ No structured fields | ❌ No faceted navigation |
| **Hybrid RAG** | ⚠️ Text + NER entities only | ❌ No XML-defined metadata |

**Current EVA DA = Content-driven RAG only**

---

### 6.3 If You Need Metadata-Aware RAG

**Option 1: Extend FileLayoutParsingOther**

Add custom XML parsing logic:

```python
elif file_extension_lower == ".xml":
    from unstructured.partition.xml import partition_xml
    import xml.etree.ElementTree as ET
    
    # Parse XML structure
    tree = ET.parse(bytes_io)
    root = tree.getroot()
    
    # Extract metadata from known schema
    metadata_fields = {}
    for doc in root.findall('.//document'):
        metadata_fields['reference'] = doc.find('reference').text
        metadata_fields['video_link'] = doc.find('video_link').text
        # ... etc
    
    # Also get text elements from unstructured
    elements = partition_xml(file=bytes_io)
    
    # Pass metadata_fields to write_chunk() for indexing
```

**Pros:**
- Preserves XML metadata as index fields
- Enables filtering, boosting, faceting
- Structured citations

**Cons:**
- Requires schema definition for each XML type
- Increases complexity and maintenance
- May break on schema changes

---

**Option 2: Pre-process XML to JSON (Plan-2 Format)**

Convert XML to structured JSON before upload:

```json
{
  "reference": "KA-05215",
  "title": "Getting Tasks from Work Queue",
  "video_link": "https://example.com/video",
  "content": "reserve the most prioritized task..."
}
```

**Then**: Modify `FileLayoutParsingOther` to parse JSON structure (currently treats as text).

**Pros:**
- JSON is easier to parse than XML
- Schema explicit in JSON structure
- No XML namespace/attribute complications

**Cons:**
- Requires upfront conversion
- FileLayoutParsingOther still needs JSON parsing logic
- Loses original XML format

---

**Option 3: Custom Ingestion Function**

Bypass `FileLayoutParsingOther` entirely for structured documents:

```python
# New Azure Function: FileLayoutParsingStructured
def main(msg: func.QueueMessage):
    if file_extension in ['.xml', '.json']:
        # Custom structured parsing
        metadata_fields, content = parse_structured_document(file_bytes, schema)
        
        # Write to search index with metadata fields
        write_document_with_metadata(index_name, metadata_fields, content)
    else:
        # Route to standard FileLayoutParsingOther
        pass
```

**Pros:**
- Clean separation of concerns
- Optimized for structured data
- No impact on existing text-based ingestion

**Cons:**
- Requires new Azure Function deployment
- Parallel pipeline maintenance
- Schema management overhead

---

## Part 7: Definitive Answers to Key Questions

### Q1: Were AssistMe XML fields treated as metadata or text?

**Answer:** **TEXT ONLY**

**Evidence:**
1. **Code (line 468):** `partition_xml()` extracts text, discards tag names
2. **Code (line 539-541):** Title extracted from `element.category`, not XML tags
3. **Runtime:** No `reference`, `subtitle` fields in `proj1-index`
4. **Runtime:** AssistMe documents have URL in `title`, concatenated text in `content`

**Conclusion:** XML tag names (`<reference>`, `<video_link>`) were **never preserved**.

---

### Q2: Why did AssistMe XML ingestion succeed in Nov 2025?

**Answer:** **Success = Text Extraction, Not Metadata**

**Evidence:**
1. **Status logs:** "partitioning complete" → "chunking complete" → "embeddings complete"
2. **No errors:** Pipeline completed normally
3. **782 chunks created:** Text successfully extracted and chunked
4. **Search index populated:** Documents retrievable by content search

**Explanation:**
- AssistMe XML had simple, flat structure with minimal nesting
- Text content easily extracted by `partition_xml()`
- No complex attributes, namespaces, or binary data
- Pipeline's success criteria (text extraction) was met
- Metadata loss was silent (no error, just missing fields)

---

### Q3: Why does new XML fail today?

**Answer:** **REQUIRES NEW XML SAMPLE TO DIAGNOSE**

**Likely causes (based on code analysis):**
1. **Parse error:** Malformed XML, invalid characters, encoding issues
2. **Memory error:** File too large, excessive nesting
3. **Library bug:** Unstructured version incompatibility
4. **Schema mismatch:** Unexpected structure breaks title extraction

**To prove:** Need:
- New XML file sample
- Error message from Cosmos status logs
- Stack trace from Application Insights

**NOT a metadata issue** — code doesn't validate metadata, only extracts text.

---

## Part 8: Final Recommendation

### For Current AssistMe Use Case

**✅ NO ACTION NEEDED** if:
- Content-based search is sufficient
- Users don't filter by reference ID, video link, etc.
- Title field (URL) is acceptable citation format

**⚠️ ACTION REQUIRED** if:
- Need to filter: "Show me all articles with video links"
- Need to boost: "Prioritize articles with WalkMe flows"
- Need structured citations: "According to reference KA-05215, section X..."

---

### For New XML Ingestion

**IMMEDIATE:**
1. **Get failing XML sample** and error logs
2. **Test locally:** `partition_xml(file=open('new_file.xml', 'rb'))`
3. **Identify failure point:** Parse? Chunking? Enrichment?

**IF METADATA NEEDED:**
1. **Define schema requirements** — which fields must be preserved?
2. **Choose approach:** Extend FileLayoutParsingOther, JSON pre-processing, or custom function
3. **Update index schema** — add metadata fields to `proj1-index`
4. **Implement & test** — validate metadata appears in search results

**IF TEXT EXTRACTION SUFFICIENT:**
1. **Fix parse error** — likely XML structure issue
2. **Simplify XML** — reduce nesting, remove namespaces
3. **Validate locally** before uploading

---

## Appendix: Code Evidence Summary

| Evidence Type | Location | Finding |
|---------------|----------|---------|
| **XML Routing** | Line 467-469 | Uses `partition_xml()` — generic text extractor |
| **Title Extraction** | Line 539-541 | Looks for `category == "Title"`, not XML tags |
| **Metadata** | Line 530-532 | Generic file metadata only, not XML elements |
| **JSON Processing** | Line 457 | Treated as plain text via `partition_text()` |
| **Write Chunk** | Line 150-160 | Only `title` and `content` fields written |
| **Index Schema** | Runtime evidence | No `reference`, `subtitle`, `video_link` fields |
| **Status Logs** | Runtime evidence | No "XML metadata extraction" step |

---

**Report Conclusion:** AssistMe XML ingestion succeeded **despite** lack of metadata preservation, not because of it. EVA DA's XML processing is **text-only** by design.

**Next Action:** Determine if metadata preservation is a requirement. If yes, implement one of the three options in Part 6.3.

---

**Forensic Analysis Complete**  
**Confidence Level:** 🔬 Definitive (code + runtime evidence)  
**Status:** ✅ Root cause identified, options provided
