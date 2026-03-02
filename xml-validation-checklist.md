# XML Validation Checklist for EVA DA

## Overview

This document provides a deterministic checklist of requirements that XML files must satisfy to successfully pass through EVA DA's `partition_xml` ingestion pipeline.

**Based on**: Code analysis of FileLayoutParsingOther and unstructured.io partition_xml behavior

---

## ✅ Required: XML Must Be Well-Formed

### 1. Valid XML Declaration (if present)

**Rule**: If XML declaration exists, it must be valid

✅ **Valid**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
```

✅ **Valid** (no declaration):
```xml
<documents>
  <document>...</document>
</documents>
```

❌ **Invalid**:
```xml
<?xml version="1.0" encoding="UTF-8"
<documents>...</documents>
```

**Why**: Missing closing `?>` causes parse error

---

### 2. Single Root Element

**Rule**: XML must have exactly one root element

✅ **Valid**:
```xml
<documents>
  <document>...</document>
  <document>...</document>
</documents>
```

❌ **Invalid**:
```xml
<document>...</document>
<document>...</document>
```

**Why**: Multiple root elements violate XML specification

---

### 3. Properly Nested Tags

**Rule**: All tags must be properly opened and closed

✅ **Valid**:
```xml
<document>
  <title>Title</title>
  <content>
    <paragraph>Text</paragraph>
  </content>
</document>
```

❌ **Invalid**:
```xml
<document>
  <title>Title
  <content>Text</content>
</document>
```

**Why**: Unclosed `<title>` tag causes parse error

---

### 4. Valid Tag Names

**Rule**: Tag names must follow XML naming rules

**XML Naming Rules**:
- Must start with letter or underscore (not number or symbol)
- Can contain letters, digits, hyphens, underscores, periods
- Cannot contain spaces
- Cannot start with "xml" (case-insensitive)
- Case-sensitive

✅ **Valid**:
```xml
<document>
<document-id>
<_private>
<item_123>
```

❌ **Invalid**:
```xml
<1document>         <!-- Starts with number -->
<document id>       <!-- Contains space -->
<document/id>       <!-- Invalid character '/' -->
<xml-document>      <!-- Starts with 'xml' -->
```

---

### 5. Escaped Special Characters

**Rule**: Special XML characters must be escaped in text content

**Required Escapes**:
- `<` → `&lt;`
- `>` → `&gt;`
- `&` → `&amp;`
- `"` → `&quot;` (in attributes)
- `'` → `&apos;` (in attributes)

✅ **Valid**:
```xml
<content>Price &lt; $100 &amp; quantity &gt; 5</content>
```

❌ **Invalid**:
```xml
<content>Price < $100 & quantity > 5</content>
```

**Why**: Unescaped characters break XML parsing

---

### 6. Balanced Quotes in Attributes (if used)

**Rule**: Attribute values must be quoted and balanced

✅ **Valid**:
```xml
<document id="123" type="article">
<document id='123' type='article'>
```

❌ **Invalid**:
```xml
<document id=123>
<document id="123>
```

---

## ✅ Required: Encoding

### 7. UTF-8 Encoding

**Rule**: File must be UTF-8 encoded OR declare encoding in XML declaration

✅ **Valid**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<documents>...</documents>
```

✅ **Valid** (UTF-8 without BOM, no declaration):
```xml
<documents>...</documents>
```

❌ **Invalid**:
- UTF-16 file without encoding declaration
- Latin-1 file with UTF-8 declaration

**Why**: Python's XML parser defaults to UTF-8

---

## ⚠️ Recommendations (Not Strictly Required)

### 8. No Namespaces

**Rule**: While `partition_xml` can handle namespaces, simpler is better

✅ **Recommended**:
```xml
<documents>
  <document>...</document>
</documents>
```

⚠️ **Works but not ideal**:
```xml
<ns:documents xmlns:ns="http://example.com/ns">
  <ns:document>...</ns:document>
</ns:documents>
```

**Why**: Namespace handling can be unpredictable; simpler XML is more reliable

---

### 9. No Schema References

**Rule**: EVA DA does not validate against schemas

✅ **Recommended**:
```xml
<documents>
  <document>...</document>
</documents>
```

⚠️ **Ignored (but harmless)**:
```xml
<documents xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://example.com/schema document.xsd">
  <document>...</document>
</documents>
```

**Why**: Schema validation not performed; references are ignored

---

### 10. Extractable Text Content

**Rule**: Elements should contain meaningful text

✅ **Good**:
```xml
<document>
  <title>Knowledge Article 123</title>
  <content>This is the article content...</content>
</document>
```

⚠️ **Poor** (but valid):
```xml
<document>
  <title></title>
  <content></content>
</document>
```

**Why**: Empty elements produce empty chunks; no searchable content

---

## 🔍 Comparison: Working AssistMe XML vs. New XML

### AssistMe XML Structure (Known Working)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<documents>
  <document>
    <id>123</id>
    <title>Article Title</title>
    <content>Article content here...</content>
    <language>en</language>
  </document>
  <document>
    <id>124</id>
    <title>Another Article</title>
    <content>More content...</content>
    <language>en</language>
  </document>
</documents>
```

**Key Characteristics**:
- ✅ Valid XML declaration with UTF-8 encoding
- ✅ Single root element: `<documents>`
- ✅ Multiple child `<document>` elements
- ✅ Simple tag names (no namespaces)
- ✅ No schema references
- ✅ Extractable text in `<title>` and `<content>`

---

### Common Failure Patterns

#### ❌ Pattern 1: Invalid Tag Names

```xml
<1_document>...</1_document>           <!-- Starts with number -->
<document-123-id>...</document-123-id> <!-- Should work, but hyphen at start/end risky -->
```

#### ❌ Pattern 2: Unescaped Characters

```xml
<title>Article: Benefits & Risks < $100</title>
<!-- Should be: Benefits &amp; Risks &lt; $100 -->
```

#### ❌ Pattern 3: Unclosed Tags

```xml
<document>
  <title>Article Title
  <content>Content here</content>
</document>
```

#### ❌ Pattern 4: Multiple Root Elements

```xml
<document>...</document>
<document>...</document>
```

#### ❌ Pattern 5: Encoding Mismatch

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- But file is actually UTF-16 or Latin-1 -->
```

---

## 📋 Pre-Upload Validation Checklist

Before uploading XML to EVA DA, verify:

- [ ] **XML is well-formed**: Use XML validator (xmllint, online validator)
- [ ] **Single root element**: Only one top-level element
- [ ] **Valid tag names**: No spaces, no leading numbers, no invalid characters
- [ ] **Proper encoding**: UTF-8 encoded file with matching declaration
- [ ] **Escaped special characters**: `<`, `>`, `&` properly escaped in text
- [ ] **Balanced tags**: All opening tags have matching closing tags
- [ ] **No illegal characters**: Check for control characters, invalid Unicode
- [ ] **Extractable content**: Elements contain meaningful text (not all empty)

---

## 🛠️ Validation Tools

### PowerShell: Validate XML Syntax

```powershell
# Test if XML is well-formed
[xml]$xml = Get-Content "path\to\file.xml"
Write-Host "✓ XML is well-formed"
```

### Python: Validate with xml.etree

```python
import xml.etree.ElementTree as ET

try:
    tree = ET.parse("path/to/file.xml")
    print("✓ XML is well-formed")
except ET.ParseError as e:
    print(f"❌ XML parse error: {e}")
```

### Online Validators

- [XML Validator](https://www.xmlvalidation.com/)
- [W3C XML Validator](https://validator.w3.org/)

---

## 📊 Diagnostic Steps for Failed XML

If your XML file fails ingestion:

1. **Check Status Log** (Cosmos DB):
   ```
   Run: python tools/evidence/query_statuslog_for_assistme.py
   Look for: ERROR state, error_message field
   ```

2. **Validate XML Locally**:
   ```powershell
   [xml]$xml = Get-Content "your-file.xml"
   ```

3. **Compare Structure**:
   - Compare your XML root element to AssistMe's `<documents>`
   - Check tag naming conventions
   - Verify encoding declaration matches file encoding

4. **Test with Minimal XML**:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <documents>
     <document>
       <title>Test</title>
       <content>Test content</content>
     </document>
   </documents>
   ```

5. **Review App Insights Logs**:
   ```
   Run: python tools/evidence/appinsights_trace_assistme_ingestion.py
   Look for: Exception traces, parse errors
   ```

---

## 📚 References

- **EVA DA XML Processing**: [xml-output-contract.md](./xml-output-contract.md)
- **Evidence Scripts**: [tools/evidence/README.md](../../tools/evidence/README.md)
- **AssistMe Ingestion Proof**: [assistme-xml-ingestion-proof.md](./assistme-xml-ingestion-proof.md)
- **W3C XML Specification**: https://www.w3.org/TR/xml/
- **Unstructured.io partition_xml**: https://unstructured-io.github.io/unstructured/bricks.html#partition-xml
