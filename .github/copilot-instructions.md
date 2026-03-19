<!-- eva-project-authority -->

# GitHub Copilot Instructions -- 20-assistme

**Project**: AssistMe XML ingestion evidence system  
**Path**: C:\eva-foundry\20-assistme\

## Start Here

1. Complete workspace bootstrap first.
2. Query the live project record:
	```powershell
	Invoke-RestMethod "$($session.base)/model/projects/20-assistme"
	```
3. Read local docs in this order:
	- README.md
	- PLAN.md
	- STATUS.md
	- ACCEPTANCE.md
	- docs/evidence/
	- tools/evidence/

## Project Role

This repo is an evidence-backed investigation workspace for proving how EVA Domain Assistant ingests XML and why specific XML inputs fail. Favor direct evidence from Azure resources, logs, indexed content, and code analysis over assumptions or speculative root causes.

## Working Rules

- Keep documentation, scripts, and collected outputs aligned.
- Preserve the distinction between source evidence, generated reports, and final conclusions.
- New conclusions must point back to observable evidence or code paths.
- If you change a script in tools/evidence/, update the corresponding documentation in docs/evidence/.
- Use timestamp-prefixed filenames for new evidence outputs.

## Validation

- Run only the evidence collection scripts you change or depend on.
- Treat authentication, connectivity, or Azure access failures as environmental unless the task is specifically about fixing them.
- Update STATUS.md when the investigation scope, evidence baseline, or known findings change.

## Traceability

Use project story tags when traceability is required:

```text
EVA-STORY: F20-06-001
EVA-FEATURE: F20-06
```

Use Project 48 audit tooling when the change affects governed delivery quality.

## Boundaries

- Do not replace evidence-backed findings with generalized template prose.
- Do not rewrite collected outputs under docs/evidence/out/ unless the task explicitly requires regeneration.
- Do not hardcode live platform facts that should be queried from Azure or the data model.
