# EVA DA Evidence Capture Test - Results Summary
**Test Date**: 2026-01-24 00:06:00
**Test Environment**: Local Development
**Backend URL**: http://localhost:5000
**Frontend URL**: http://localhost:5173
**Test Operator**: Manual observation

## Test Files Summary

| File | Type | Size | Queue | Handler | Status |
|------|------|------|-------|---------|--------|| test_example.pdf | PDF | 21647 bytes | pdf_submit_queue | FileFormRecSubmissionPDF | [MANUAL CHECK] |
| test_example.xml | XML | 795 bytes | non_pdf_submit_queue | FileLayoutParsingOther | [MANUAL CHECK] |
| tiny.json | JSON | 19 bytes | non_pdf_submit_queue | FileLayoutParsingOther | [MANUAL CHECK] |
| test_example.md | MD | 341 bytes | non_pdf_submit_queue | FileLayoutParsingOther | [MANUAL CHECK] |

## Evidence Checklist

### test_example.pdf
- [ ] Handler selection logged (FileUploadedEtrigger -> pdf_submit_queue)
- [ ] Azure Document Intelligence API call confirmed
- [ ] OCR polling completion logged
- [ ] Multi-page text extraction confirmed
- [ ] Page number array populated (pages: [1, 2, ...])
- [ ] Chunk count documented (expected: multiple for multi-page)
- [ ] Each chunk ~1500 characters
- [ ] Index update confirmed
- [ ] Retrieval test: page numbers visible in citation
- [ ] Retrieval test: page numbers NOT in LLM prompt

### test_example.xml
- [ ] Handler selection logged (FileUploadedEtrigger -> non_pdf_submit_queue)
- [ ] Parsing method confirmed (partition_xml from unstructured library)
- [ ] XML structure flattening confirmed (tags/hierarchy lost)
- [ ] Text extraction length documented
- [ ] Chunk count documented
- [ ] Index update confirmed
- [ ] Retrieval test: XML elements not queryable
- [ ] Retrieval test: only flat text searchable

### tiny.json
- [ ] Handler selection logged (FileUploadedEtrigger -> non_pdf_submit_queue)
- [ ] Parsing method confirmed (partition_text NOT partition_json)
- [ ] JSON schema loss confirmed (keys/values treated as plain text)
- [ ] Single chunk expected (small file)
- [ ] Index update confirmed
- [ ] Retrieval test: JSON keys not queryable
- [ ] Retrieval test: only flat text searchable

### test_example.md
- [ ] Handler selection logged (FileUploadedEtrigger -> non_pdf_submit_queue)
- [ ] Parsing method confirmed (partition_md from unstructured library)
- [ ] Markdown formatting partially preserved
- [ ] Text extraction length documented
- [ ] Chunk count documented
- [ ] Index update confirmed
- [ ] Retrieval test: Markdown headings not filterable
- [ ] Retrieval test: text content searchable

## Key Findings to Document

1. **Fixed Chunking Confirmation**:
   - CHUNK_TARGET_SIZE environment variable: [VALUE FROM LOGS]
   - Actual chunk size used: [CONFIRM 1500 from logs]
   - Evidence of hardcoded value: [LOG EXCERPT]

2. **Structure Loss Confirmation**:
   - XML elements lost: [EXAMPLE BEFORE/AFTER]
   - JSON schema lost: [EXAMPLE BEFORE/AFTER]
   - Impact on queryability: [DESCRIBE]

3. **Metadata Blindness Confirmation**:
   - LLM sees: content + source_path
   - LLM does NOT see: pages, tags, chunk_file
   - Page numbers added: [AFTER/DURING generation - CONFIRM]

4. **Retrieval Behavior**:
   - Search index fields returned: [LIST ALL]
   - Fields visible to LLM: [LIST CONFIRMED]
   - Fields in citation_lookup only: [LIST CONFIRMED]

## Next Steps

1. Update main pipeline analysis document with actual evidence
2. Replace all [PENDING] entries with [CONFIRMED] or [FAILED]
3. Add log excerpts as code blocks for traceability
4. Create recommendations based on observed behavior
5. Archive test logs in: C:\Users\marco.presta\OneDrive - ESDC EDSC\Documents\AICOE\EVA-JP-v1.2\docs\evidence\capture-logs

## Test Artifacts Location

- Test files: C:\Users\marco.presta\OneDrive - ESDC EDSC\Documents\AICOE\EVA-JP-v1.2\tests\test_data
- Backend logs: [CAPTURE LOCATION]
- Frontend screenshots: [CAPTURE LOCATION]
- This summary: C:\Users\marco.presta\OneDrive - ESDC EDSC\Documents\AICOE\EVA-JP-v1.2\docs\evidence\capture-logs\evidence_capture_summary_20260123_223739.md

---
**Report Status**: TEMPLATE - Requires manual completion
**Completion Instructions**: Fill in all [ ] checkboxes and [VALUE] placeholders with actual evidence
