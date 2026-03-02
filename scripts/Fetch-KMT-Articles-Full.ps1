<#
.SYNOPSIS
    Fetch full article content from KMT knowledge base
.DESCRIPTION
    Retrieves complete article content including HTML body, metadata, and related information
    Handles ESDC internal SSL certificates using Invoke-WebRequest
.PARAMETER InventoryFile
    Path to KMT-DATABASE-INVENTORY-COMPLETE.json
.PARAMETER Language
    Language to fetch: "en" or "fr"
.PARAMETER OutputFile
    Path to output JSON file
.PARAMETER DelaySeconds
    Delay between requests (default: 1 second)
.PARAMETER PilotMode
    If specified, only fetches 4 pilot test articles
.PARAMETER ArticlePIDs
    Optional array of specific PIDs to fetch (overrides inventory)
.EXAMPLE
    .\Fetch-KMT-Articles-Full.ps1 -InventoryFile "..\KMT-DATABASE-INVENTORY-COMPLETE.json" -Language "en" -OutputFile "..\output\raw-json\kmt-articles-raw-en.json"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$InventoryFile = "..\KMT-DATABASE-INVENTORY-COMPLETE.json",
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("en", "fr")]
    [string]$Language,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$false)]
    [int]$DelaySeconds = 1,
    
    [Parameter(Mandatory=$false)]
    [switch]$PilotMode,
    
    [Parameter(Mandatory=$false)]
    [string[]]$ArticlePIDs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$baseUrlEn = "https://kmt-ogc.service.gc.ca/knowledgebase/article-latest"
$baseUrlFr = "https://kmt-ogc.service.gc.ca/fr/knowledgebase/article-latest"
$baseUrl = if ($Language -eq "fr") { $baseUrlFr } else { $baseUrlEn }

# Pilot test articles (one from each system)
$pilotPIDs = @("KA-01215", "KA-01347", "KA-01135", "KA-05215")

# Results tracking
$fetchedArticles = @()
$failedArticles = @()
$totalArticles = 0
$successCount = 0
$failCount = 0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  KMT Article Content Fetcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Language: $Language" -ForegroundColor White
Write-Host "Output: $OutputFile" -ForegroundColor White
Write-Host "Delay: $DelaySeconds second(s)" -ForegroundColor White
if ($PilotMode) {
    Write-Host "Mode: PILOT TEST (4 articles)" -ForegroundColor Yellow
}
Write-Host "========================================`n" -ForegroundColor Cyan

# Load article list
if ($ArticlePIDs) {
    $articleList = $ArticlePIDs
    Write-Host "[INFO] Using provided article PIDs: $($ArticlePIDs.Count) articles" -ForegroundColor Cyan
} elseif ($PilotMode) {
    $articleList = $pilotPIDs
    Write-Host "[INFO] Pilot mode - testing 4 articles" -ForegroundColor Yellow
} else {
    if (-not (Test-Path $InventoryFile)) {
        Write-Host "[ERROR] Inventory file not found: $InventoryFile" -ForegroundColor Red
        exit 1
    }
    
    $inventory = Get-Content $InventoryFile -Encoding UTF8 | ConvertFrom-Json
    $articleList = $inventory.unique_articles | Select-Object -ExpandProperty pid
    Write-Host "[INFO] Loaded $($articleList.Count) articles from inventory" -ForegroundColor Cyan
}

$totalArticles = $articleList.Count

# Function to extract article content
function Extract-ArticleContent {
    param(
        [string]$HtmlContent,
        [string]$ArticlePID,
        [string]$Url
    )
    
    $article = @{
        pid = $ArticlePID
        url = $Url
        fetch_timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        title = ""
        summary = ""
        content = ""
        categories = @()
        tags = @()
        date_created = ""
        date_modified = ""
        author = ""
        raw_html_length = $HtmlContent.Length
    }
    
    # Extract title (multiple patterns)
    if ($HtmlContent -match '<h1[^>]*class="[^"]*article-title[^"]*"[^>]*>([^<]+)</h1>') {
        $article.title = $matches[1].Trim()
    } elseif ($HtmlContent -match '<h1[^>]*>([^<]+)</h1>') {
        $article.title = $matches[1].Trim()
    } elseif ($HtmlContent -match '<title>([^<]+)</title>') {
        $article.title = $matches[1].Trim() -replace ' \| KMT.*$', ''
    }
    
    # Extract summary (meta description or first paragraph)
    if ($HtmlContent -match '<meta\s+name="description"\s+content="([^"]+)"') {
        $article.summary = $matches[1].Trim()
    } elseif ($HtmlContent -match '<div[^>]*class="[^"]*article-summary[^"]*"[^>]*>([^<]+)</div>') {
        $article.summary = $matches[1].Trim()
    } elseif ($HtmlContent -match '<p[^>]*>([^<]{50,200})</p>') {
        $article.summary = $matches[1].Substring(0, [Math]::Min(200, $matches[1].Length)).Trim()
    }
    
    # Extract main content (try multiple selectors)
    if ($HtmlContent -match '<div[^>]*class="[^"]*article-body[^"]*"[^>]*>(.*?)</div>\s*</div>') {
        $article.content = $matches[1].Trim()
    } elseif ($HtmlContent -match '<article[^>]*>(.*?)</article>') {
        $article.content = $matches[1].Trim()
    } elseif ($HtmlContent -match '<div[^>]*class="[^"]*content[^"]*"[^>]*>(.*?)</div>\s*<div[^>]*class="[^"]*sidebar') {
        $article.content = $matches[1].Trim()
    }
    
    # Extract categories (from breadcrumb)
    $breadcrumbMatches = [regex]::Matches($HtmlContent, '<a[^>]*href="/category/\?id=CAT-[^"]*"[^>]*>([^<]+)</a>')
    if ($breadcrumbMatches.Count -gt 0) {
        $article.categories = @($breadcrumbMatches | ForEach-Object { $_.Groups[1].Value.Trim() })
    }
    
    # Extract tags
    $tagMatches = [regex]::Matches($HtmlContent, '<span[^>]*class="[^"]*tag[^"]*"[^>]*>([^<]+)</span>')
    if ($tagMatches.Count -gt 0) {
        $article.tags = @($tagMatches | ForEach-Object { $_.Groups[1].Value.Trim() })
    }
    
    # Extract dates
    if ($HtmlContent -match 'data-created="([^"]+)"') {
        $article.date_created = $matches[1]
    } elseif ($HtmlContent -match 'Created:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})') {
        $article.date_created = $matches[1]
    }
    
    if ($HtmlContent -match 'data-modified="([^"]+)"') {
        $article.date_modified = $matches[1]
    } elseif ($HtmlContent -match 'Modified:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})') {
        $article.date_modified = $matches[1]
    }
    
    # Extract author
    if ($HtmlContent -match '<meta\s+name="author"\s+content="([^"]+)"') {
        $article.author = $matches[1].Trim()
    } elseif ($HtmlContent -match 'Author:\s*([^<]+)<') {
        $article.author = $matches[1].Trim()
    }
    
    return $article
}

# Function to fetch single article
function Fetch-Article {
    param(
        [string]$ArticlePID
    )
    
    $url = "${baseUrl}?pid=${ArticlePID}"
    
    try {
        Write-Host "[$successCount/$totalArticles] Fetching $ArticlePID..." -NoNewline
        
        # Fetch with retry logic
        $maxRetries = 3
        $retryCount = 0
        $success = $false
        $response = $null
        
        while (-not $success -and $retryCount -lt $maxRetries) {
            try {
                $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
                $success = $true
            } catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Host " [RETRY $retryCount/$maxRetries]" -NoNewline -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                } else {
                    throw $_
                }
            }
        }
        
        # Extract content
        $article = Extract-ArticleContent -HtmlContent $response.Content -ArticlePID $ArticlePID -Url $url
        
        # Validate extraction
        $hasTitle = $article.title -and $article.title.Length -gt 0
        $hasContent = $article.content -and $article.content.Length -gt 100
        
        if ($hasTitle -and $hasContent) {
            Write-Host " [PASS]" -ForegroundColor Green
            Write-Host "       Title: $($article.title.Substring(0, [Math]::Min(60, $article.title.Length)))..." -ForegroundColor Gray
            Write-Host "       Content: $($article.content.Length) chars" -ForegroundColor Gray
            
            $script:successCount++
            return $article
        } else {
            Write-Host " [WARN] Incomplete extraction" -ForegroundColor Yellow
            Write-Host "       Title: $hasTitle, Content: $hasContent ($($article.content.Length) chars)" -ForegroundColor Gray
            
            $script:failedArticles += @{
                pid = $ArticlePID
                url = $url
                reason = "Incomplete extraction: Title=$hasTitle, Content=$hasContent"
            }
            $script:failCount++
            return $article  # Return anyway for debugging
        }
        
    } catch {
        Write-Host " [FAIL]" -ForegroundColor Red
        Write-Host "       Error: $($_.Exception.Message)" -ForegroundColor Gray
        
        $script:failedArticles += @{
            pid = $ArticlePID
            url = $url
            reason = $_.Exception.Message
            error_type = $_.Exception.GetType().Name
        }
        $script:failCount++
        return $null
    }
}

# Main fetching loop
$startTime = Get-Date

foreach ($articlePid in $articleList) {
    $article = Fetch-Article -ArticlePID $articlePid
    
    if ($article) {
        $fetchedArticles += $article
    }
    
    # Rate limiting
    if ($DelaySeconds -gt 0) {
        Start-Sleep -Seconds $DelaySeconds
    }
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

# Create output directory if needed
$outputDir = Split-Path $OutputFile -Parent
if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Save results
$output = @{
    metadata = @{
        generated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        language = $Language
        total_articles = $totalArticles
        success_count = $successCount
        fail_count = $failCount
        success_rate = if ($totalArticles -gt 0) { [Math]::Round(($successCount / $totalArticles) * 100, 2) } else { 0 }
        execution_time_seconds = [Math]::Round($duration, 2)
        pilot_mode = $PilotMode.IsPresent
    }
    articles = $fetchedArticles
    failed_articles = $failedArticles
}

$output | ConvertTo-Json -Depth 10 | Set-Content $OutputFile -Encoding UTF8

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Fetch Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Articles: $totalArticles" -ForegroundColor White
Write-Host "Successful: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "White" })
Write-Host "Success Rate: $($output.metadata.success_rate)%" -ForegroundColor $(if ($output.metadata.success_rate -ge 95) { "Green" } elseif ($output.metadata.success_rate -ge 80) { "Yellow" } else { "Red" })
Write-Host "Execution Time: $([Math]::Round($duration, 2)) seconds" -ForegroundColor White
Write-Host "Output File: $OutputFile" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

if ($failCount -gt 0) {
    Write-Host "[WARN] $failCount articles failed to fetch. See failed_articles in output JSON." -ForegroundColor Yellow
}

# Return exit code
if ($output.metadata.success_rate -ge 95) {
    exit 0
} else {
    exit 1
}
