$staging = "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios\ipa_staging"
$payload = Join-Path $staging "Payload"
if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force -Path $payload | Out-Null
Copy-Item -Recurse "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios\ANUSI.app" (Join-Path $payload "ANUSI.app")

$zipPath = "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios\Anusi.zip"
$ipaPath = "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios\Anusi.ipa"

if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
if (Test-Path $ipaPath) { Remove-Item -Force $ipaPath }

Compress-Archive -Path $payload -DestinationPath $zipPath -CompressionLevel Optimal
Rename-Item -Path $zipPath -NewName "Anusi.ipa"
Remove-Item -Recurse -Force $staging

$ipaItem = Get-Item $ipaPath
Write-Output "SUCCESS: Generated Anusi.ipa ($($ipaItem.Length) bytes)"
