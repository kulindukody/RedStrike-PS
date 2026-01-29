$FolderPath = "C:\FolderName"

# Create directory if it does not exist
if (-not (Test-Path $FolderPath)) {
    New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
}

# Get current ACL
$Acl = Get-Acl $FolderPath

# Disable inheritance and remove inherited rules
$Acl.SetAccessRuleProtection($true, $false)

# Create deny rule (folder + files + subfolders)
$DenyRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Everyone",
    "ListDirectory,ReadData,ReadAndExecute",
    "ContainerInherit,ObjectInherit",
    "None",
    "Deny"
)

# Add deny rule
$Acl.AddAccessRule($DenyRule)

# Apply ACL
Set-Acl $FolderPath $Acl

# Shutdown (no arguments = shows shutdown UI / depends on context)
shutdown.exe