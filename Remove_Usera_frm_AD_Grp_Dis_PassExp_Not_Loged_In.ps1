# Import required modules
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline -Credential (Get-Credential)

# Define the security group
$securityGroup = "YourSecurityGroupName"

# Get all members of the security group
$groupMembers = Get-ADGroupMember -Identity $securityGroup | Where-Object { $_.objectClass -eq "user" }

# Filter users based on your criteria
$filteredUsers = $groupMembers | Where-Object {
    (Get-ADUser -Identity $_.SamAccountName -Properties Enabled, PasswordExpired, LastLogonDate) -and
    $_.Enabled -eq $false -and
    $_.PasswordExpired -eq $true -and
    $_.LastLogonDate -lt (Get-Date).AddDays(-180) -and
    (Get-Mailbox -Identity $_.SamAccountName).AutomaticRepliesEnabled -eq $false
}

# Remove filtered users from the security group
foreach ($user in $filteredUsers) {
    Remove-ADGroupMember -Identity $securityGroup -Members $user.SamAccountName -Confirm:$false
}
