param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$PrometheusUrl = "http://localhost:19090",
    [string]$OutputDir = "c:\backendgo\project3",
    [int]$Runs = 3,
    [int]$GapSeconds = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Runs -lt 3) {
    throw "Runs must be at least 3 to compute median reliably."
}

$week2Script = "c:\backendgo\project3\scripts\run-week2-drill.ps1"
if (-not (Test-Path $week2Script)) {
    throw "Missing script: $week2Script"
}

function Get-Median {
    param([double[]]$Values)
    $sorted = $Values | Sort-Object
    $count = $sorted.Count
    if ($count -eq 0) { return -1 }
    if ($count % 2 -eq 1) {
        return [math]::Round($sorted[[int][math]::Floor($count / 2)], 2)
    }
    $left = $sorted[($count / 2) - 1]
    $right = $sorted[$count / 2]
    return [math]::Round((($left + $right) / 2.0), 2)
}

$results = @()

for ($i = 1; $i -le $Runs; $i++) {
    $runOutFile = Join-Path $OutputDir ("week3-drill-run-{0}.json" -f $i)
    Write-Host "[Week3 Drill] Run $i/$Runs"

    & $week2Script -BaseUrl $BaseUrl -PrometheusUrl $PrometheusUrl -OutFile $runOutFile

    if (-not (Test-Path $runOutFile)) {
        throw "Run output not found: $runOutFile"
    }

    $json = Get-Content -Path $runOutFile -Raw | ConvertFrom-Json
    $latency = ($json.scenarios | Where-Object { $_.scenario -eq "latency-spike" } | Select-Object -First 1)
    $error = ($json.scenarios | Where-Object { $_.scenario -eq "error-spike" } | Select-Object -First 1)

    $results += [pscustomobject]@{
        run = $i
        measuredAt = $json.measuredAt
        latencyTtdSeconds = [double]$latency.ttdSeconds
        errorTtdSeconds = [double]$error.ttdSeconds
        source = $runOutFile
    }

    if ($i -lt $Runs) {
        Start-Sleep -Seconds $GapSeconds
    }
}

$latencyValues = @($results | ForEach-Object { [double]$_.latencyTtdSeconds })
$errorValues = @($results | ForEach-Object { [double]$_.errorTtdSeconds })

$summary = [pscustomobject]@{
    measuredAt = (Get-Date).ToString("o")
    runs = $Runs
    latencyMedianTtdSeconds = Get-Median -Values $latencyValues
    errorMedianTtdSeconds = Get-Median -Values $errorValues
    runResults = $results
}

$summaryFile = Join-Path $OutputDir "week3-drill-series-result.json"
$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $summaryFile -Encoding UTF8

Write-Host "Saved summary: $summaryFile"
$results | Format-Table -AutoSize | Out-String | Write-Host
Write-Host ("Latency median TTD: {0}s" -f $summary.latencyMedianTtdSeconds)
Write-Host ("Error median TTD: {0}s" -f $summary.errorMedianTtdSeconds)
