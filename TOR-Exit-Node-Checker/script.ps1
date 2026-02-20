param(
    [switch]$DebugMode
)

$TOR_EXIT_NODES_URL = "https://check.torproject.org/exit-addresses"

function Success($text) {
    Write-Host "[+] $text" -ForegroundColor Green
}

function Failure($text) {
    Write-Host "[✘] $text" -ForegroundColor Red
    exit
}

function Info($text) {
    Write-Host "[*] $text" -ForegroundColor Blue
}

function Dbg($text) {
    if ($DebugMode) {
        Write-Host "[#] $text" -ForegroundColor DarkGray
    }
}

function Status($url) {
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Method Get
        if ($response.StatusCode -eq 200) {
            Info "Host is reachable"
        }
        else {
            Failure "Host not reachable"
        }
    }
    catch {
        Failure "Host not reachable"
    }
}

function Get-TorExitIPs {
    try {
        $content = Invoke-RestMethod -Uri $TOR_EXIT_NODES_URL -Method Get

        $exitIPs = @()

        foreach ($line in $content -split "`n") {
            if ($line -match "^ExitAddress\s+(\d+\.\d+\.\d+\.\d+)") {
                $exitIPs += $matches[1]
            }
        }

        return $exitIPs
    }
    catch {
        Failure "Failed to fetch Tor exit nodes"
    }
}



# =========================
# Main Execution
# =========================

Info "Starting Tor Exit Node Enumeration Script"

Status $TOR_EXIT_NODES_URL

$ips = Get-TorExitIPs

Success "Found $($ips.Count) Tor exit IPs"

Info "Displaying the first 10 Tor exit IPs:"
$ips | Select-Object -First 10
