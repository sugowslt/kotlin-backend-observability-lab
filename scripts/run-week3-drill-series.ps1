param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$PrometheusUrl = "http://localhost:19090",
    [string]$OutputDir = "",
    [string]$ResultPrefix = "week3-drill",
    [int]$Runs = 3,
    [int]$GapSeconds = 10,
    [int]$CooldownSeconds = 120,
    [int]$BaselineTimeoutSec = 180,
    [int]$BaselineStablePolls = 2,
    [int]$LatencySeconds = 70,
    [int]$LatencyConcurrency = 12,
    [int]$LatencyDelayMs = 500,
    [int]$ErrorSeconds = 60,
    [int]$ErrorConcurrency = 10,
    [int]$ErrorDelayMs = 0,
    [int]$QueryTimeoutSec = 180,
    [int]$PollSec = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = $projectRoot
}

if ($Runs -lt 3) {
    throw "Runs must be at least 3 to compute median reliably."
}

if ($BaselineStablePolls -lt 1) {
    throw "BaselineStablePolls must be at least 1."
}

$week2Script = Join-Path $scriptRoot "run-week2-drill.ps1"
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

function Test-ConditionPositive {
    param(
        [string]$PrometheusUrl,
        [string]$Query
    )

    $encodedQuery = [System.Uri]::EscapeDataString($Query)
    $url = "$PrometheusUrl/api/v1/query?query=$encodedQuery"
    $resp = Invoke-RestMethod -Uri $url -Method Get
    $result = @($resp.data.result)
    if ($result.Count -eq 0) {
        return $false
    }

    $value = [double]$result[0].value[1]
    return ($value -gt 0)
}

function Wait-BaselineRecovery {
    param(
        [string]$PrometheusUrl,
        [string[]]$Queries,
        [int]$TimeoutSec,
        [int]$PollSec,
        [int]$StablePolls
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $stableCount = 0

    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        $allClear = $true

        foreach ($q in $Queries) {
            if (Test-ConditionPositive -PrometheusUrl $PrometheusUrl -Query $q) {
                $allClear = $false
                break
            }
        }

        if ($allClear) {
            $stableCount++
            if ($stableCount -ge $StablePolls) {
                return [pscustomobject]@{
                    recovered = $true
                    waitedSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
                }
            }
        }
        else {
            $stableCount = 0
        }

        Start-Sleep -Seconds $PollSec
    }

    return [pscustomobject]@{
        recovered = $false
        waitedSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
    }
}

$results = @()

$latencyQuery = "histogram_quantile(0.95, sum by (le) (rate(http_server_requests_seconds_bucket{uri='/api/v1/ops/events',method='POST',traffic_type='drill'}[1m]))) > 0.25"
$errorQuery = "(sum(rate(http_server_requests_seconds_count{uri='/api/v1/ops/events',method='POST',traffic_type='drill',status=~'5..'}[1m])) / clamp_min(sum(rate(http_server_requests_seconds_count{uri='/api/v1/ops/events',method='POST',traffic_type='drill'}[1m])), 0.001)) > 0.02"

for ($i = 1; $i -le $Runs; $i++) {
    $runOutFile = Join-Path $OutputDir ("{0}-run-{1}.json" -f $ResultPrefix, $i)
    Write-Host "[Week3 Drill] Run $i/$Runs"

    if ($i -gt 1 -and $CooldownSeconds -gt 0) {
        Write-Host "[Week3 Drill] Cooldown ${CooldownSeconds}s before next run"
        Start-Sleep -Seconds $CooldownSeconds
    }

    if ($GapSeconds -gt 0) {
        Start-Sleep -Seconds $GapSeconds
    }

    $baseline = Wait-BaselineRecovery -PrometheusUrl $PrometheusUrl -Queries @($latencyQuery, $errorQuery) -TimeoutSec $BaselineTimeoutSec -PollSec $PollSec -StablePolls $BaselineStablePolls
    if (-not $baseline.recovered) {
        Write-Warning "Baseline not fully recovered within ${BaselineTimeoutSec}s. Continuing run $i."
    }
    else {
        Write-Host "[Week3 Drill] Baseline recovered in $($baseline.waitedSeconds)s"
    }

    & $week2Script -BaseUrl $BaseUrl -PrometheusUrl $PrometheusUrl -OutFile $runOutFile `
        -LatencySeconds $LatencySeconds -LatencyConcurrency $LatencyConcurrency -LatencyDelayMs $LatencyDelayMs `
        -ErrorSeconds $ErrorSeconds -ErrorConcurrency $ErrorConcurrency -ErrorDelayMs $ErrorDelayMs `
        -QueryTimeoutSec $QueryTimeoutSec -PollSec $PollSec

    if (-not (Test-Path $runOutFile)) {
        throw "Run output not found: $runOutFile"
    }

    $json = Get-Content -Path $runOutFile -Raw | ConvertFrom-Json
    $latency = ($json.scenarios | Where-Object { $_.scenario -eq "latency-spike" } | Select-Object -First 1)
    $error = ($json.scenarios | Where-Object { $_.scenario -eq "error-spike" } | Select-Object -First 1)

    $results += [pscustomobject]@{
        run = $i
        measuredAt = $json.measuredAt
        baselineRecovered = [bool]$baseline.recovered
        baselineWaitSeconds = [double]$baseline.waitedSeconds
        latencyTtdSeconds = [double]$latency.ttdSeconds
        errorTtdSeconds = [double]$error.ttdSeconds
        source = $runOutFile
    }
}

$latencyValues = @($results | ForEach-Object { [double]$_.latencyTtdSeconds })
$errorValues = @($results | ForEach-Object { [double]$_.errorTtdSeconds })

$summary = [pscustomobject]@{
    measuredAt = (Get-Date).ToString("o")
    runs = $Runs
    config = [pscustomobject]@{
        cooldownSeconds = $CooldownSeconds
        baselineTimeoutSec = $BaselineTimeoutSec
        baselineStablePolls = $BaselineStablePolls
        gapSeconds = $GapSeconds
    }
    latencyMedianTtdSeconds = Get-Median -Values $latencyValues
    errorMedianTtdSeconds = Get-Median -Values $errorValues
    runResults = $results
}

$summaryFile = Join-Path $OutputDir ("{0}-series-result.json" -f $ResultPrefix)
$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $summaryFile -Encoding UTF8

Write-Host "Saved summary: $summaryFile"
$results | Format-Table -AutoSize | Out-String | Write-Host
Write-Host ("Latency median TTD: {0}s" -f $summary.latencyMedianTtdSeconds)
Write-Host ("Error median TTD: {0}s" -f $summary.errorMedianTtdSeconds)
