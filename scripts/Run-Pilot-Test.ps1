# EVA-FEATURE: F20-03
# EVA-STORY: F20-03-001
# EVA-STORY: F20-03-002
# EVA-STORY: F20-03-003
# EVA-STORY: F20-03-004
# EVA-STORY: F20-04-001
# EVA-STORY: F20-04-002
# EVA-STORY: F20-05-001
# EVA-STORY: F20-05-002
# EVA-STORY: F20-06-001
# EVA-STORY: F20-06-002
# EVA-STORY: F20-06-003
# EVA-STORY: F20-07-001
# EVA-STORY: F20-07-002
# EVA-STORY: F20-07-003
# EVA-STORY: F20-09-001
<#
.SYNOPSIS
    Execute pilot test on 4 sample KMT articles
.DESCRIPTION
    Tests extraction patterns on representative articles from each system:
    - ITRDS: KA-01215 (Simulation of the Death Benefit)
    - CPMS: KA-01347 (Add or Override a Voluntary Tax Withhold)  
    - PWS: KA-01135 (Assign a Work Item)
    - Curam: KA-05215 (Perform Person Evidence Verification)
.EXAMPLE
    .\Run-Pilot-Test.ps1
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipFrench,
    
    [Parameter(Mandatory=$false)]
    [int]$DelaySeconds = 1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$projectRoot = Split-Path $PSScriptRoot -Parent
$pilotOutputDir = Join-Path $projectRoot "output\pilot"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  KMT XML Generation - PILOT TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Create pilot output directory
if (-not (Test-Path $pilotOutputDir)) {
    New-Item -ItemType Directory -Path $pilotOutputDir -Force | Out-Null
    Write-Host "[INFO] Created pilot output directory: $pilotOutputDir" -ForegroundColor Cyan
}

# Test articles
$pilotArticles = @(
    @{ PID = "KA-01215"; System = "ITRDS"; Title = "Simulation of the Death Benefit" }
    @{ PID = "KA-01347"; System = "CPMS"; Title = "Add or Override a Voluntary Tax Withhold" }
    @{ PID = "KA-01135"; System = "PWS"; Title = "Assign a Work Item" }
    @{ PID = "KA-05215"; System = "Curam"; Title = "Perform Person Evidence Verification" }
)

Write-Host "Pilot Test Articles:" -ForegroundColor Yellow
foreach ($article in $pilotArticles) {
    Write-Host "  - $($article.PID) [$($article.System)]: $($article.Title)" -ForegroundColor White
}
Write-Host ""

$allTestsPassed = $true

# Test 1: Fetch English Articles
Write-Host "[TEST 1] Fetching English articles..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\Fetch-KMT-Articles-Full.ps1" `
        -Language "en" `
        -OutputFile "$pilotOutputDir\pilot-articles-en.json" `
        -PilotMode `
        -DelaySeconds $DelaySeconds
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[PASS] English articles fetched successfully`n" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] English fetch failed with exit code: $LASTEXITCODE`n" -ForegroundColor Red
        $allTestsPassed = $false
    }
} catch {
    Write-Host "[FAIL] English fetch error: $($_.Exception.Message)`n" -ForegroundColor Red
    $allTestsPassed = $false
}

# Test 2: Fetch French Articles (optional)
if (-not $SkipFrench) {
    Write-Host "[TEST 2] Fetching French articles..." -ForegroundColor Yellow
    try {
        & "$PSScriptRoot\Fetch-KMT-Articles-Full.ps1" `
            -Language "fr" `
            -OutputFile "$pilotOutputDir\pilot-articles-fr.json" `
            -PilotMode `
            -DelaySeconds $DelaySeconds
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[PASS] French articles fetched successfully`n" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] French fetch failed with exit code: $LASTEXITCODE`n" -ForegroundColor Red
            $allTestsPassed = $false
        }
    } catch {
        Write-Host "[FAIL] French fetch error: $($_.Exception.Message)`n" -ForegroundColor Red
        $allTestsPassed = $false
    }
} else {
    Write-Host "[SKIP] French articles skipped`n" -ForegroundColor Gray
}

# Test 3: Validate Extraction Quality
Write-Host "[TEST 3] Validating extraction quality..." -ForegroundColor Yellow

$enData = Get-Content "$pilotOutputDir\pilot-articles-en.json" -Encoding UTF8 | ConvertFrom-Json

$extractionTests = @(
    @{ Name = "All articles fetched"; Expected = 4; Actual = $enData.articles.Count }
    @{ Name = "All have titles"; Expected = 4; Actual = ($enData.articles | Where-Object { $_.title -and $_.title.Length -gt 0 }).Count }
    @{ Name = "All have content (>100 chars)"; Expected = 4; Actual = ($enData.articles | Where-Object { $_.content -and $_.content.Length -gt 100 }).Count }
    @{ Name = "Success rate >= 95%"; Expected = $true; Actual = ($enData.metadata.success_rate -ge 95) }
)

foreach ($test in $extractionTests) {
    if ($test.Expected -eq $test.Actual) {
        Write-Host "  [PASS] $($test.Name): $($test.Actual)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($test.Name): Expected $($test.Expected), Got $($test.Actual)" -ForegroundColor Red
        $allTestsPassed = $false
    }
}
Write-Host ""

# Test 4: Check Bilingual Pairing (if French fetched)
if (-not $SkipFrench -and (Test-Path "$pilotOutputDir\pilot-articles-fr.json")) {
    Write-Host "[TEST 4] Validating bilingual pairing..." -ForegroundColor Yellow
    
    $frData = Get-Content "$pilotOutputDir\pilot-articles-fr.json" -Encoding UTF8 | ConvertFrom-Json
    
    $bilingualTests = @(
        @{ Name = "Same article count (EN/FR)"; Expected = $enData.articles.Count; Actual = $frData.articles.Count }
        @{ Name = "Same PIDs (EN/FR)"; Expected = $true; Actual = (Compare-Object -ReferenceObject ($enData.articles.pid | Sort-Object) -DifferenceObject ($frData.articles.pid | Sort-Object)).Count -eq 0 }
    )
    
    foreach ($test in $bilingualTests) {
        if ($test.Expected -eq $test.Actual) {
            Write-Host "  [PASS] $($test.Name)" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $($test.Name): Expected $($test.Expected), Got $($test.Actual)" -ForegroundColor Red
            $allTestsPassed = $false
        }
    }
    
    # Check for proper translation (content length difference)
    Write-Host "`n  Bilingual Content Check:" -ForegroundColor Cyan
    for ($i = 0; $i -lt [Math]::Min($enData.articles.Count, $frData.articles.Count); $i++) {
        $enArticle = $enData.articles[$i]
        $frArticle = $frData.articles | Where-Object { $_.pid -eq $enArticle.pid }
        
        if ($frArticle) {
            $enLength = $enArticle.content.Length
            $frLength = $frArticle.content.Length
            $diff = [Math]::Abs($enLength - $frLength)
            $diffPercent = if ($enLength -gt 0) { [Math]::Round(($diff / $enLength) * 100, 1) } else { 0 }
            
            # Allow 50% variance (some translations are longer/shorter)
            if ($diffPercent -le 50 -and $frLength -gt 100) {
                Write-Host "    $($enArticle.pid): EN=$enLength chars, FR=$frLength chars, Diff=$diffPercent%" -ForegroundColor Gray
            } else {
                Write-Host "    $($enArticle.pid): [WARN] Large difference - EN=$enLength chars, FR=$frLength chars, Diff=$diffPercent%" -ForegroundColor Yellow
            }
        }
    }
    Write-Host ""
}

# Display sample content
Write-Host "[SAMPLE] First article content preview:" -ForegroundColor Yellow
if ($enData.articles.Count -gt 0) {
    $sample = $enData.articles[0]
    Write-Host "  PID: $($sample.pid)" -ForegroundColor White
    Write-Host "  Title: $($sample.title)" -ForegroundColor White
    Write-Host "  Summary: $($sample.summary.Substring(0, [Math]::Min(100, $sample.summary.Length)))..." -ForegroundColor Gray
    Write-Host "  Content Length: $($sample.content.Length) characters" -ForegroundColor Gray
    Write-Host "  Categories: $($sample.categories -join ', ')" -ForegroundColor Gray
    Write-Host "  Tags: $($sample.tags -join ', ')" -ForegroundColor Gray
    Write-Host ""
}

# Final Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PILOT TEST RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($allTestsPassed) {
    Write-Host "Status: [PASS] All tests passed" -ForegroundColor Green
    Write-Host "`nDecision: GO - Proceed with full execution" -ForegroundColor Green
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "  1. Review pilot output files in: $pilotOutputDir" -ForegroundColor White
    Write-Host "  2. Run full execution: .\scripts\Generate-Complete-KMT-XML.ps1 -Language both" -ForegroundColor White
} else {
    Write-Host "Status: [FAIL] Some tests failed" -ForegroundColor Red
    Write-Host "`nDecision: NO-GO - Address issues before full execution" -ForegroundColor Red
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Review failed articles in pilot output JSON" -ForegroundColor White
    Write-Host "  2. Check extraction patterns in Fetch-KMT-Articles-Full.ps1" -ForegroundColor White
    Write-Host "  3. Verify network connectivity to kmt-ogc.service.gc.ca" -ForegroundColor White
}

Write-Host "========================================`n" -ForegroundColor Cyan

# Create pilot test results file
$resultsFile = Join-Path $pilotOutputDir "PILOT-TEST-RESULTS.md"
$results = @"
# Pilot Test Results - KMT XML Generation

**Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Tester**: Automated Script
**Environment**: $(hostname)

## Test Articles
- ITRDS: KA-01215 (Simulation of the Death Benefit)
- CPMS: KA-01347 (Add or Override a Voluntary Tax Withhold)
- PWS: KA-01135 (Assign a Work Item)
- Curam: KA-05215 (Perform Person Evidence Verification)

## Results

### Fetch Phase
- [$(if ($enData.metadata.success_count -eq 4) { 'x' } else { ' ' })] All 4 articles fetched successfully (EN)
- [$(if (-not $SkipFrench -and $frData.metadata.success_count -eq 4) { 'x' } elseif ($SkipFrench) { '-' } else { ' ' })] All 4 articles fetched successfully (FR)
- [$(if ($enData.failed_articles.Count -eq 0) { 'x' } else { ' ' })] No SSL certificate errors
- [$(if ($enData.metadata.execution_time_seconds -lt 10) { 'x' } else { ' ' })] Network latency acceptable (<10s for 4 articles)

### Extraction Phase
- [$(if (($enData.articles | Where-Object { $_.title }).Count -eq 4) { 'x' } else { ' ' })] Title extracted correctly (4/4)
- [$(if (($enData.articles | Where-Object { $_.summary }).Count -ge 3) { 'x' } else { ' ' })] Summary extracted correctly (3+/4)
- [$(if (($enData.articles | Where-Object { $_.content.Length -gt 100 }).Count -eq 4) { 'x' } else { ' ' })] Body content extracted correctly (4/4)
- [$(if (($enData.articles | Where-Object { $_.categories.Count -gt 0 }).Count -ge 3) { 'x' } else { ' ' })] Categories extracted (3+/4)

### Quality Metrics
- **Success Rate (EN)**: $($enData.metadata.success_rate)%
$(if (-not $SkipFrench) { "- **Success Rate (FR)**: $($frData.metadata.success_rate)%" })
- **Execution Time (EN)**: $($enData.metadata.execution_time_seconds) seconds
$(if (-not $SkipFrench) { "- **Execution Time (FR)**: $($frData.metadata.execution_time_seconds) seconds" })

### Bilingual Pairing
$(if (-not $SkipFrench) {
@"
- [$(if ($enData.articles.Count -eq $frData.articles.Count) { 'x' } else { ' ' })] EN and FR articles have same count
- [$(if ((Compare-Object -ReferenceObject ($enData.articles.pid | Sort-Object) -DifferenceObject ($frData.articles.pid | Sort-Object)).Count -eq 0) { 'x' } else { ' ' })] PIDs match between EN and FR
"@
} else { "- [SKIPPED] French articles not fetched" })

## Issues Found
$(if ($enData.failed_articles.Count -gt 0) {
    "### English Fetch Failures:`n" + ($enData.failed_articles | ForEach-Object { "- $($_.pid): $($_.reason)" } | Out-String)
} else {
    "No issues found - all articles fetched successfully"
})

## Go/No-Go Decision
- [$(if ($allTestsPassed) { 'x' } else { ' ' })] **GO** - Proceed with full execution
- [$(if (-not $allTestsPassed) { 'x' } else { ' ' })] **NO-GO** - Address issues before full execution

**Decision Rationale**: $(if ($allTestsPassed) {
    "All pilot tests passed successfully. Extraction patterns work correctly across different systems."
} else {
    "Some tests failed. Review extraction patterns and network connectivity before proceeding."
})

## Output Files
- English: ``$pilotOutputDir\pilot-articles-en.json``
$(if (-not $SkipFrench) { "- French: ``$pilotOutputDir\pilot-articles-fr.json``" })
- Results: ``$resultsFile``

---

*Generated by Run-Pilot-Test.ps1 on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")*
"@

$results | Set-Content $resultsFile -Encoding UTF8
Write-Host "[INFO] Pilot test results saved to: $resultsFile`n" -ForegroundColor Cyan

# Return appropriate exit code
if ($allTestsPassed) {
    exit 0
} else {
    exit 1
}
