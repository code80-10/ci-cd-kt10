param(
    [string]$JenkinsUrl = 'http://localhost:8080',
    [string]$JobName = 'kt10-pipeline',
    [string]$Mode = 'REST_API'
)

$ErrorActionPreference = 'Stop'
$username = Read-Host 'Jenkins username [admin]'
if ([string]::IsNullOrWhiteSpace($username)) {
    $username = 'admin'
}

$secureToken = Read-Host 'Jenkins API token' -AsSecureString
$credential = [pscredential]::new($username, $secureToken)
$plainToken = $credential.GetNetworkCredential().Password
$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${plainToken}"))
$headers = @{ Authorization = "Basic $basic" }
$plainToken = $null

$triggerUrl = "$JenkinsUrl/job/$JobName/buildWithParameters?MODE=$([uri]::EscapeDataString($Mode))"
$response = Invoke-WebRequest -Uri $triggerUrl -Method Post -Headers $headers -UseBasicParsing
$queueUrl = $response.Headers.Location.TrimEnd('/')

do {
    Start-Sleep -Seconds 1
    $queue = Invoke-RestMethod -Uri "$queueUrl/api/json" -Headers $headers
} until ($queue.executable.number)

$buildNumber = [int]$queue.executable.number
$buildUrl = "$JenkinsUrl/job/$JobName/$buildNumber"
do {
    Start-Sleep -Seconds 1
    $build = Invoke-RestMethod -Uri "$buildUrl/api/json" -Headers $headers
} while ($build.building)

$actualMode = ($build.actions | ForEach-Object { $_.parameters } | Where-Object { $_.name -eq 'MODE' }).value
$lines = @(
    "HTTP_STATUS=$($response.StatusCode)"
    "QUEUE_URL=$queueUrl"
    "BUILD_NUMBER=$buildNumber"
    "MODE=$actualMode"
    "RESULT=$($build.result)"
)

$evidencePath = Join-Path $PSScriptRoot '..\evidence\rest-build.txt'
$lines | Set-Content -Path $evidencePath -Encoding UTF8
$lines
