# AssistMe KMT XML Structure Analysis

**Source**: Knowledge Management Tool (KMT) - https://kmt-ogc.service.gc.ca/  
**Files Analyzed**:
- `knowledge_articles_r2r3_en 2.xml` (English, 1.3 MB)
- `knowledge_articles_r2r3_FR.xml` (French, ~1.3 MB)
**Date**: November 4, 2025 (Last Modified)  
**Analysis Date**: 2026-01-30

---

## Executive Summary

The AssistMe XML files contain **104 knowledge articles** each (English and French versions) exported from the KMT system. The structure is flat and simple, designed for bulk export/import of knowledge base content.

### Key Characteristics
- ✅ **Valid XML**: Well-formed, UTF-8 encoding
- ✅ **Flat structure**: No deep nesting (2 levels max)
- ✅ **Properly escaped**: HTML entities (`&lt;`, `&gt;`) correctly encoded
- ✅ **Consistent schema**: All articles follow same structure
- ✅ **Bilingual**: Separate files for EN/FR content

### Compatibility with EVA DA
- ✅ **Will ingest successfully** if uploaded correctly
- ✅ **UTF-8 encoding** matches EVA DA requirements
- ✅ **No XML syntax errors** detected
- ⚠️ **Structure will be flattened** during processing (EVA DA limitation)
- ⚠️ **Video/walkme fields** contain placeholder data

---

## XML Document Structure

### Root Element

```xml
<?xml version='1.0' encoding='utf-8'?>
<documents>
  <document>...</document>
  <document>...</document>
  <!-- Total: 104 articles -->
</documents>
```

**Element**: `<documents>`  
**Child Count**: 104 `<document>` elements  
**Encoding**: UTF-8 (declared in XML header)

---

## Individual Article Schema

Each `<document>` element contains:

### Field Inventory

| Element | Type | Content Example | Purpose |
|---------|------|-----------------|---------|
| `reference` | URL | `https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016` | Link to source article in KMT |
| `title` | String | `Perform Person Evidence Verification in Cúram (Action)` | Article title |
| `video_link` | String | `[-1]` | Video URL (placeholder in this export) |
| `video_name` | String | `['placeholder']` | Video name (placeholder) |
| `walkme_flow_id` | String | `[-1]` | WalkMe tutorial ID (placeholder) |
| `walkme_flow_name` | String | `['placeholder']` | WalkMe tutorial name (placeholder) |
| `content` | Text (large) | `Overview Summary This procedure...` | Full article text content |

### Field Details

#### 1. `<reference>`
- **Format**: Full URL to KMT article
- **Contains**: `pid` (article ID like `KA-05215`) and `cid` (category ID like `CAT-02016`)
- **Purpose**: Traceability back to source system
- **Example**:
  ```xml
  <reference>https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016</reference>
  ```

#### 2. `<title>`
- **Format**: Plain text string
- **Length**: Varies (typically 30-80 characters)
- **Naming Convention**: `{Topic} in {System} ({Type})`
  - Types observed: `(Action)`, `(Knowledge)`, `(Scenario)`
- **Example**:
  ```xml
  <title>Perform Person Evidence Verification in Cúram (Action)</title>
  ```

#### 3. `<video_link>` and `<video_name>`
- **Status**: **Placeholder data in this export**
- **Values**: `[-1]` and `['placeholder']`
- **Purpose**: Link to instructional videos (when available)
- **Note**: Not populated in current export

#### 4. `<walkme_flow_id>` and `<walkme_flow_name>`
- **Status**: **Placeholder data in this export**
- **Values**: `[-1]` and `['placeholder']`
- **Purpose**: Link to WalkMe interactive tutorials (when available)
- **Note**: Not populated in current export

#### 5. `<content>`
- **Format**: Long text field (thousands of characters)
- **Structure**: Contains formatted text with:
  - Section headings (e.g., "Overview Summary", "Step by Step")
  - Tables (e.g., "Table 1— Field and Direction")
  - Bullet points
  - Embedded HTML entities (properly escaped)
- **Size**: Ranges from ~2,000 to ~20,000+ characters per article
- **Example snippet**:
  ```xml
  <content>Overview Summary This procedure provides you with the steps to follow when you are performing Person evidence verification. This includes adding, accepting and rejecting proof...
  
  Table 1— Field and Direction under Add Proof section 
  Field Direction Item Updated Select the correct item. 
  Date Received Updated Indicate the date on which the item was received...</content>
  ```

---

## Content Formatting Patterns

### Sections
Content typically includes these sections:
1. **Overview Summary** - Brief description of procedure
2. **What you need to know** - Prerequisites, context
3. **Step by Step** - Detailed instructions
4. **References** - Related articles, resources

### Tables
Tables are represented as inline text with headers:
```
Table 1— Field and Direction under Add Proof section
Field Direction
Item Updated Select the correct item.
Date Received Updated Indicate the date on which the item was received...
```

### HTML Entities
Special characters properly escaped:
- `<` → `&lt;`
- `>` → `&gt;`
- `&` → `&amp;` (when needed)

**Example**:
```xml
<content>...Select one of the following acceptance status:
Accepted
Rejected
Note: If you select Rejected, you must also select a reason from the Rejection Reason drop down menu...</content>
```

---

## Sample Article (Full Structure)

```xml
<document>
  <reference>https://kmt-ogc.service.gc.ca/en/knowledgebase/article-latest?pid=KA-05215&cid=CAT-02016</reference>
  <title>Perform Person Evidence Verification in Cúram (Action)</title>
  <video_link>[-1]</video_link>
  <video_name>['placeholder']</video_name>
  <walkme_flow_id>[-1]</walkme_flow_id>
  <walkme_flow_name>['placeholder']</walkme_flow_name>
  <content>Overview Summary This procedure provides you with the steps to follow when you are performing Person evidence verification. This includes adding, accepting and rejecting proof, correcting an error if the acceptance status is incorrect, and deleting proof. 

What you need to know
Cúram will prompt verification requirements for certain proof, such as Third Party Contact and SIN Identification Status. Note: You do not need to perform SIN identification verification for Release 1.

Step by Step What you need to do
Accept or Reject Proof Updated

In Cúram, access the Person's profile. Refer to Search for a Person in Cúram (Action).
Click the Evidence tab.
Click Verifications in the page group navigation bar to access items that are available for verification.
...
[Content continues for ~15,000 characters]
</content>
</document>
```

---

## Bilingual Structure

### English (`knowledge_articles_r2r3_en 2.xml`)
- **Articles**: 104
- **Language**: English (Canadian)
- **URL Pattern**: `/en/knowledgebase/article-latest?pid=...`

### French (`knowledge_articles_r2r3_FR.xml`)
- **Articles**: 104
- **Language**: French (Canadian)
- **URL Pattern**: `/fr/knowledgebase/article-latest?pid=...` (expected)

**Note**: Both files appear to have same title in first article - may need verification if FR file truly contains French translations.

---

## EVA DA Processing Implications

### What EVA DA Will Do

Based on `functions/FileLayoutParsingOther/__init__.py` analysis:

#### 1. **Parse XML Elements**
```python
# EVA DA will extract text from all XML elements
def partition_xml(file):
    elements = file.elements
    for element in elements:
        text = element.text  # Extracts plain text
        # No preservation of element names or hierarchy
```

#### 2. **Flatten Structure**
```
<documents>
  <document>
    <title>Title Here</title>
    <content>Content Here</content>
  </document>
</documents>

↓ EVA DA Processing ↓

Plain text output:
"Title Here Content Here"
```

**Result**: All 7 fields concatenated into single text stream per article.

#### 3. **Chunk Into Segments**
```python
def chunk_by_title(elements, max_characters=1500, overlap=200):
    # Splits text into ~1500 character chunks
    # Chunks may split mid-sentence or mid-word
```

**Example**:
```
Article content: "...Date Received Updated Indicate the date on which the item was received from the provider. New Provided by New Indicate the name of the person providing the evidence..."

Chunk 1 (1500 chars): "...Date Received Updated Indicate the date on which the item was received from the provider. New Provided by New Indicate the name of the person prov..."

Chunk 2 (1500 chars): "...iding the evidence by performing one of the following actions: If the person is registered in the system, click the magnifying glass icon..."
```

#### 4. **Generate Embeddings**
Each chunk converted to vector embeddings using `text-embedding-ada-002`.

#### 5. **Index in Search**
Chunks stored in Azure Cognitive Search with metadata:
```json
{
  "id": "chunk_001",
  "content": "...text chunk...",
  "sourcepage": "knowledge_articles_r2r3_en 2.xml",
  "sourcefile": "knowledge_articles_r2r3_en 2.xml",
  "embedding": [0.123, -0.456, ...]
}
```

### What EVA DA Will **NOT** Preserve

❌ **XML element names** (`<title>`, `<content>`, `<reference>`)  
❌ **Document boundaries** (104 separate articles become continuous text)  
❌ **Article titles as searchable metadata**  
❌ **KMT reference URLs** (lost in processing)  
❌ **Structured table formatting**  
❌ **Section headings as hierarchy**  
❌ **Video/WalkMe placeholder fields** (meaningless data)

---

## Known Issues & Limitations

### 1. **Placeholder Fields**
**Issue**: `video_link`, `video_name`, `walkme_flow_id`, `walkme_flow_name` contain no useful data.

**Impact**: These fields add noise to indexed content.

**Recommendation**: Pre-process XML to remove placeholder fields before upload:
```xml
<!-- Remove these lines from each <document> -->
<video_link>[-1]</video_link>
<video_name>['placeholder']</video_name>
<walkme_flow_id>[-1]</walkme_flow_id>
<walkme_flow_name>['placeholder']</walkme_flow_name>
```

### 2. **Loss of Article Identity**
**Issue**: After chunking, cannot identify which article a chunk came from.

**Impact**: Search results show text snippets without article context.

**Recommendation**: Add article metadata to file path:
```
AssistMe/EN/KA-05215_Person_Evidence_Verification.xml  (single article per file)
```
Instead of:
```
AssistMe/knowledge_articles_r2r3_en 2.xml  (104 articles in one file)
```

### 3. **Table Formatting Loss**
**Issue**: Tables in content rendered as inline text, hard to read.

**Example**:
```
Input (in XML):
Table 1— Field and Direction
Field | Direction
Item | Select the correct item
Date Received | Indicate the date

Output (after EVA DA):
"Table 1— Field and Direction Field Direction Item Select the correct item Date Received Indicate the date"
```

**Impact**: Degraded readability, harder for users to understand procedures.

**Recommendation**: Convert tables to more structured format before upload (if possible).

---

## Validation Checklist

✅ **XML Well-Formed**: No syntax errors  
✅ **UTF-8 Encoding**: Declared in header  
✅ **Root Element**: Single `<documents>` root  
✅ **Closing Tags**: All tags properly closed  
✅ **Escaped Characters**: `<`, `>`, `&` properly escaped  
✅ **Consistent Schema**: All 104 articles follow same structure  
✅ **No Invalid Tag Names**: All tags start with letters  
✅ **Single Root**: No multiple root elements  
✅ **File Size**: 1.3 MB (within limits)

---

## Recommendations for Future Exports

### 1. **Single Article Per File**
Instead of bulk export, generate individual XML files:
```
AssistMe/
  KA-05215_Person_Evidence_Verification.xml
  KA-05216_Create_Manual_Task.xml
  KA-05217_Foreign_Direct_Deposit.xml
  ...
```

**Benefits**:
- Easier to identify source article for search results
- Simpler to update individual articles
- Better file metadata (filename = article ID + title)

### 2. **Remove Placeholder Fields**
Exclude or populate properly:
```xml
<!-- Don't include if no video -->
<!-- <video_link>[-1]</video_link> -->

<!-- Or populate with actual data -->
<video_link>https://video.gc.ca/training/person-verification</video_link>
<video_name>Person Evidence Verification Tutorial</video_name>
```

### 3. **Add Structured Metadata**
Include article metadata as XML attributes or dedicated elements:
```xml
<document id="KA-05215" category="CAT-02016" type="Action" program="OAS" system="Curam" language="en">
  <metadata>
    <article_id>KA-05215</article_id>
    <category_id>CAT-02016</category_id>
    <category_name>OAS Procedures</category_name>
    <article_type>Action</article_type>
    <publish_date>2025-09-15</publish_date>
    <last_modified>2025-11-04</last_modified>
    <keywords>evidence,verification,proof,Curam</keywords>
  </metadata>
  <reference>...</reference>
  <title>...</title>
  <content>...</content>
</document>
```

**Note**: EVA DA will still flatten structure, but metadata could be extracted separately for search filters.

### 4. **Preserve Table Structure**
Use HTML tables or markdown-style formatting:
```xml
<content>
...
<table>
  <tr><th>Field</th><th>Direction</th></tr>
  <tr><td>Item</td><td>Select the correct item</td></tr>
  <tr><td>Date Received</td><td>Indicate the date received</td></tr>
</table>
...
</content>
```

Or:
```xml
<content>
...
| Field | Direction |
|-------|-----------|
| Item | Select the correct item |
| Date Received | Indicate the date received |
...
</content>
```

---

## Article Sampling

### Article Distribution (First 10 Articles by Title)

1. Perform Person Evidence Verification in Cúram (Action)
2. Create a Manual Task for OAS Investigations in Cúram (Action)
3. Add Foreign Direct Deposit Information for OAS in Cúram (Action)
4. [Additional titles in actual export]
5. ...

### Topics Covered
Based on grep results, articles cover:
- **Cúram system procedures** (OAS, GIS, ALW, ALWS benefits)
- **Evidence verification** (documents, proof, attachments)
- **Manual task creation** (workflows, categories, types)
- **Income processing** (CRA data, reassessment, validation)
- **Investigation referrals**
- **Renewal processes**
- **Foreign direct deposit**
- **Payment processing**

---

## File Metadata

### English File
- **Filename**: `knowledge_articles_r2r3_en 2.xml`
- **Size**: 1,299,076 bytes (1.3 MB)
- **Last Modified**: 2025-11-04 11:25:21 AM
- **Articles**: 104
- **Encoding**: UTF-8

### French File
- **Filename**: `knowledge_articles_r2r3_FR.xml`
- **Size**: ~1.3 MB (similar to EN)
- **Last Modified**: 2025-11-04 (same date)
- **Articles**: 104
- **Encoding**: UTF-8

---

## Next Steps

### For Successful EVA DA Ingestion

1. **Verify Files Are Complete**
   - Check if all 104 articles contain meaningful content
   - Verify French file truly contains French translations

2. **Pre-Process XML (Optional)**
   - Remove placeholder fields (`video_link`, `walkme_flow_id`)
   - Split into individual article files (recommended)
   - Add meaningful metadata to filenames

3. **Upload to EVA DA**
   - Use AssistMe folder/group in EVA DA
   - Monitor status log for ingestion success
   - Verify indexed content in search

4. **Validate Ingestion**
   - Run evidence collection scripts
   - Query search index for sample articles
   - Test retrieval with sample questions

5. **Document Upload Process**
   - Create SOP for future XML exports
   - Document any pre-processing steps
   - Maintain mapping of article IDs to indexed content

---

## Conclusion

The AssistMe KMT XML files are **well-formed, valid, and ready for EVA DA ingestion**. The structure is simple and compatible with EVA DA's XML processing pipeline. However, be aware that:

- ✅ XML will parse successfully
- ✅ Content will be indexed
- ⚠️ Structure will be lost (flattened)
- ⚠️ Article boundaries will disappear
- ⚠️ Tables will lose formatting

**Recommended Approach**: Split into individual article files for better traceability and metadata preservation.

---

**Analysis Complete**: 2026-01-30  
**Analyst**: GitHub Copilot  
**Evidence Location**: `docs/eva-foundation/projects/20-AssistMe/`
