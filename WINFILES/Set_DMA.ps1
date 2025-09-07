$filePath = "C:\Windows\System32\IntegratedServicesRegionPolicySet.json"
takeown /F $filePath /A
icacls $filePath /grant "Administrator:F" /T
$content = Get-Content -Path $filePath -Raw
$updatedContent = $content -replace '"YT"', '"YT" , "GB"'
Set-Content -Path $filePath -Value $updatedContent -Force


takeown /f "C:\Windows\System32\IntegratedServicesRegionPolicySet.json"
icacls "C:\Windows\System32\IntegratedServicesRegionPolicySet.json" /grant "Username:(F)"
