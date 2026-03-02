# Quick Reference: Evidence Collection

## 🚀 Run All Scripts

```powershell
# From repo root (EVA-JP-v1.2/)
python tools\evidence\discover_group_resources.py
python tools\evidence\query_statuslog_for_assistme.py
python tools\evidence\appinsights_trace_assistme_ingestion.py
python tools\evidence\search_index_probe.py
```

## 📂 Check Outputs

```powershell
cd docs\evidence\out
ls *_YYYYMMDD_HHMMSS.md  # Markdown reports
ls *_YYYYMMDD_HHMMSS.json  # JSON data
```

## 🔍 Key Files to Review

1. **Status Log Results**: `assistme_statuslog_*.md`
   - Look for: `"state": "Error"`, `"error_message": "..."`

2. **Search Index Results**: `search_index_assistme_*.md`
   - Look for: Indexed documents for AssistMe files

3. **App Insights Results**: `appinsights_assistme_*.md`
   - Look for: Exception traces, parse errors

## ✅ Validate Your XML

```powershell
# Test if XML is well-formed
[xml]$xml = Get-Content "your-file.xml"
```

## 📋 XML Checklist

- [ ] Single root element
- [ ] Valid tag names (no leading numbers)
- [ ] UTF-8 encoding declared
- [ ] Special chars escaped (`<` → `&lt;`)
- [ ] All tags closed properly

## 📖 Documentation

- **Main Report**: `docs/evidence/assistme-xml-ingestion-proof.md` (fill in evidence)
- **Code Analysis**: `docs/evidence/xml-output-contract.md`
- **Validation Guide**: `docs/evidence/xml-validation-checklist.md`
- **Full README**: `docs/evidence/README.md`

## 🆘 Troubleshooting

**Authentication Error**: Run `az login`  
**No Results**: Adjust date ranges in scripts  
**Missing Env Vars**: Check `app/backend/backend.env`

## 🎯 Goal

Prove with evidence:
1. ✅ How AssistMe XML was ingested
2. ✅ What EVA DA does with XML
3. ✅ Why your new XML fails

**No assumptions. Only evidence.**
