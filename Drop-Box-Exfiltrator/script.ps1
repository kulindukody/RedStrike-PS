function DropBox-Upload {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("f")]
        [string]$SourceFilePath
    )

    begin {
        $DropBoxAccessToken = ""

        if (-not $DropBoxAccessToken -or $DropBoxAccessToken -like "PASTE_*") {
            throw "Dropbox access token is not set."
        }

        function Has-Cyrillic($text) {
            [regex]::IsMatch($text, '[\p{IsCyrillic}]')
        }

        function Get-RandomFileName($extension) {
            ([System.IO.Path]::GetRandomFileName() -replace '\.', '') + $extension
        }
    }

    process {
        # Resolve absolute path (important)
        try {
            $resolvedPath = (Resolve-Path -Path $SourceFilePath -ErrorAction Stop).Path
        } catch {
            throw "File not found: $SourceFilePath"
        }

        $fileName   = Split-Path $resolvedPath -Leaf
        $targetPath = $resolvedPath
        if (Has-Cyrillic $fileName) {
            $ext        = [System.IO.Path]::GetExtension($fileName)
            $randomName = Get-RandomFileName $ext
            $publicDir  = 'C:\Users\Public\Documents'
            $newPath    = Join-Path $publicDir $randomName

            Copy-Item -Path $resolvedPath -Destination $newPath -Force
            $targetPath = $newPath
            $fileName   = $randomName
        }
        $dropboxArg = @{
            path       = "/$fileName"
            mode       = "add"
            autorename = $true
            mute       = $false
        } | ConvertTo-Json -Compress

        $headers = @{
            "Authorization"   = "Bearer $DropBoxAccessToken"
            "Dropbox-API-Arg" = $dropboxArg
            "Content-Type"    = "application/octet-stream"
        }

        Invoke-RestMethod `
            -Uri "https://content.dropboxapi.com/2/files/upload" `
            -Method Post `
            -Headers $headers `
            -InFile $targetPath
        if ($targetPath -ne $resolvedPath) {
            Remove-Item -Path $targetPath -Force
        }
    }
}