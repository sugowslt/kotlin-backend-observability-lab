param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$PrometheusUrl = "http://localhost:19090",
    [string]$OutFile = "",
    [int]$DurationSeconds = 180,
    [int]$RequestIntervalMs = 1000,
    [int]$PollSeconds = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptRoot
if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = Join-Path $projectRoot "normal-traffic-false-positive-result.json"
}

$headers = @{ "X-Traffic-Type" = "normal" }
$startedAt = Get-Date
$endAt = $startedAt.AddSeconds($DurationSeconds)
$polls = @()
$requestCount = 0

while ((Get-Date) -lt $endAt) {
    $body = @{
        eventType = "NORMAL_TRAFFIC_CHECK"
        payload = "normal-payload-$requestCount"
        delayMs = 0
        forceError = $false
    } | ConvertTo-Json -Compress

    Invoke-RestMethod -Uri "$BaseUrl/api/v1/ops/events" -Method Post -ContentType "application/json" -Headers $headers -Body $body -TimeoutSec 10 | Out-Null
    $requestCount++

    $alertsResp = Invoke-RestMethod -Uri "$PrometheusUrl/api/v1/alerts" -Method Get
    $projectAlerts = @($alertsResp.data.alerts | Where-Object {
        $_.labels.alertname -in @('Project3HighLatencyP95', 'Project3HighErrorRate') -and $_.state -eq 'firing'
    })

    $polls += [pscustomobject]@{
        checkedAt = (Get-Date).ToString('o')
        firingAlerts = @($projectAlerts | ForEach-Object { $_.labels.alertname })
        firingCount = @($projectAlerts).Count
    }

    Start-Sleep -Milliseconds $RequestIntervalMs
    if ($PollSeconds -gt 0) {
        Start-Sleep -Seconds $PollSeconds
    }
}

$firingEvents = @($polls | Where-Object { $_.firingCount -gt 0 })
$result = [pscustomobject]@{
    measuredAt = (Get-Date).ToString('o')
    startedAt = $startedAt.ToString('o')
    durationSeconds = $DurationSeconds
    requestIntervalMs = $RequestIntervalMs
    requestCount = $requestCount
    pollCount = @($polls).Count
    falsePositiveCount = @($firingEvents).Count
    falsePositiveRate = if (@($polls).Count -gt 0) { [math]::Round((@($firingEvents).Count / @($polls).Count), 4) } else { 0 }
    polls = $polls
}

$result | ConvertTo-Json -Depth 8 | Set-Content -Path $OutFile -Encoding UTF8
Write-Host "Saved: $OutFile"
Write-Host ("Requests: {0}, Polls: {1}, False positives: {2}" -f $requestCount, @($polls).Count, @($firingEvents).Count)
