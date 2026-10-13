param(
    [string]$InputFile = 'android/app/google-services.json',
    [string]$OutputFile = 'firebase-config.json'
)
$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath $InputFile -Raw -Encoding UTF8 | ConvertFrom-Json
$client = @($config.client | Where-Object { $_.client_info.android_client_info.package_name -eq 'com.example.campus_assistant' }) | Select-Object -First 1
if ($null -eq $client) { throw 'No Android client matching com.example.campus_assistant was found.' }
$oauth = @($client.oauth_client | Where-Object { $_.client_type -eq 3 }) | Select-Object -First 1
$values = [ordered]@{
    FIREBASE_PROJECT_ID = [string]$config.project_info.project_id
    FIREBASE_SENDER_ID = [string]$config.project_info.project_number
    FIREBASE_APP_ID = [string]$client.client_info.mobilesdk_app_id
    FIREBASE_API_KEY = [string]$client.api_key[0].current_key
}
foreach ($item in $values.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($item.Value)) { throw ('Missing Firebase field: ' + $item.Key) }
}
if ($null -ne $oauth) { $values['GOOGLE_SERVER_CLIENT_ID'] = [string]$oauth.client_id }
else { Write-Warning 'Google web client ID is absent. Enable Google in Firebase and download the updated google-services.json.' }
$destination = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputFile))
[System.IO.File]::WriteAllText($destination, ($values | ConvertTo-Json), (New-Object System.Text.UTF8Encoding($false)))
Write-Output ('Created local configuration: ' + $destination)
