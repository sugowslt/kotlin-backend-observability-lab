param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$PrometheusUrl = "http://localhost:19090",
    [string]$OutFile = "c:\backendgo\project3\week2-drill-result.json",
    [int]$LatencySeconds = 120,
    [int]$LatencyConcurrency = 30,
    [int]$LatencyDelayMs = 600,
    [int]$ErrorSeconds = 90,
    [int]$ErrorConcurrency = 20,
    [int]$ErrorDelayMs = 0,
    [int]$QueryTimeoutSec = 240,
    [int]$PollSec = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-FireAndForget {
    param(
        [int]$Seconds,
        [int]$Concurrency,
        [string]$Mode,
        [int]$DelayMs = 0,
        [bool]$ForceError = $false
    )

    $jobs = @()
    for ($worker = 1; $worker -le $Concurrency; $worker++) {
        $jobs += Start-Job -ScriptBlock {
            param($Seconds, $BaseUrl, $Worker, $Mode, $DelayMs, $ForceError)
            $endAt = [DateTime]::UtcNow.AddSeconds($Seconds)
            while ([DateTime]::UtcNow -lt $endAt) {
                $bodyObj = @{
                    eventType = if ($Mode -eq "LATENCY") { "LATENCY_DRILL" } else { "ERROR_DRILL" }
                    payload = "drill-payload-$Worker"
                    delayMs = $DelayMs
                    forceError = $ForceError
                }
                $body = $bodyObj | ConvertTo-Json -Compress
                try {
                    $headers = @{ "X-Traffic-Type" = "drill" }
                    Invoke-RestMethod -Uri "$BaseUrl/api/v1/ops/events" -Method Post -ContentType "application/json" -Headers $headers -Body $body -TimeoutSec 10 | Out-Null
                }
                catch {
                }
            }
        } -ArgumentList $Seconds, $BaseUrl, $worker, $Mode, $DelayMs, $ForceError
    }

    return $jobs
}

function Wait-ConditionTrue {
    param(
        [string]$PrometheusUrl,
        [string]$Query,
        [int]$TimeoutSec = 300,
        [int]$PollSec = 5
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        $encodedQuery = [System.Uri]::EscapeDataString($Query)
        $url = "$PrometheusUrl/api/v1/query?query=$encodedQuery"
        $resp = Invoke-RestMethod -Uri $url -Method Get
        $result = @($resp.data.result)
        if ($result.Count -gt 0) {
            $v = [double]$result[0].value[1]
            if ($v -gt 0) {
                return [math]::Round($sw.Elapsed.TotalSeconds, 2)
            }
        }
        Start-Sleep -Seconds $PollSec
    }

    return -1
}

$scenarios = @()

Write-Host "[Scenario A] Latency spike drill"
$latencyQuery = "max_over_time(http_server_requests_seconds_max{uri='/api/v1/ops/events',traffic_type='drill'}[1m]) > 0.2"
$latencyJobs = Invoke-FireAndForget -Seconds $LatencySeconds -Concurrency $LatencyConcurrency -Mode "LATENCY" -DelayMs $LatencyDelayMs -ForceError $false
$latencyTtd = Wait-ConditionTrue -PrometheusUrl $PrometheusUrl -Query $latencyQuery -TimeoutSec $QueryTimeoutSec -PollSec $PollSec
Wait-Job -Job $latencyJobs | Out-Null
$latencyJobs | Receive-Job | Out-Null
$latencyJobs | Remove-Job -Force | Out-Null

$scenarios += [pscustomobject]@{
    scenario = "latency-spike"
    condition = "p95 > 200ms"
    ttdSeconds = $latencyTtd
}

Start-Sleep -Seconds 10

Write-Host "[Scenario B] Error spike drill"
$errorQuery = "(sum(rate(http_server_requests_seconds_count{uri='/api/v1/ops/events',traffic_type='drill',status='500'}[1m])) / clamp_min(sum(rate(http_server_requests_seconds_count{uri='/api/v1/ops/events',traffic_type='drill'}[1m])), 1)) > 0.01"
$errorJobs = Invoke-FireAndForget -Seconds $ErrorSeconds -Concurrency $ErrorConcurrency -Mode "ERROR" -DelayMs $ErrorDelayMs -ForceError $true
$errorTtd = Wait-ConditionTrue -PrometheusUrl $PrometheusUrl -Query $errorQuery -TimeoutSec $QueryTimeoutSec -PollSec $PollSec
Wait-Job -Job $errorJobs | Out-Null
$errorJobs | Receive-Job | Out-Null
$errorJobs | Remove-Job -Force | Out-Null

$scenarios += [pscustomobject]@{
    scenario = "error-spike"
    condition = "500 error rate > 1%"
    ttdSeconds = $errorTtd
}

$result = [pscustomobject]@{
    measuredAt = (Get-Date).ToString("o")
    scenarios = $scenarios
}

$result | ConvertTo-Json -Depth 6 | Set-Content -Path $OutFile -Encoding UTF8
Write-Host "Saved: $OutFile"
$scenarios | Format-Table -AutoSize | Out-String | Write-Host
