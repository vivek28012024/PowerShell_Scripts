# Import required modules
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline -Credential (Get-Credential)

# Function to get user details
function Get-UserDetails {
    param ($user)
    $adUser = Get-ADUser -Identity $user.SamAccountName -Properties DisplayName, SamAccountName, Enabled, Title, Department, Manager, EmailAddress, LastLogonDate, Info
    $managerName = if ($adUser.Manager) { (Get-ADUser -Identity $adUser.Manager).DisplayName } else { "" }
    [PSCustomObject]@{
        Name           = $adUser.DisplayName
        SamName        = $adUser.SamAccountName
        AccountStatus  = if ($adUser.Enabled) { "Enabled" } else { "Disabled" }
        Title          = $adUser.Title
        Department     = $adUser.Department
        Manager        = $managerName
        Email          = $adUser.EmailAddress
        LastLogOnTime  = $adUser.LastLogonDate
        Notes          = $adUser.Info
    }
}

# Function to get members of a security group recursively
function Get-GroupMembersRecursively {
    param ($group)
    $members = @()
    $groupMembers = Get-ADGroupMember -Identity $group | Where-Object { $_.objectClass -eq "user" -or $_.objectClass -eq "group" }

    foreach ($member in $groupMembers) {
        if ($member.objectClass -eq "user") {
            $members += Get-UserDetails -user $member
        } elseif ($member.objectClass -eq "group") {
            $members += Get-GroupMembersRecursively -group $member.DistinguishedName
        }
    }
    return $members
}

# Define the main security group
$securityGroup = "YourSecurityGroupName"

# Get all members of the main security group recursively
$allMembers = Get-GroupMembersRecursively -group $securityGroup

# Export the user details to a CSV file
$allMembers | Export-Csv -Path "C:\Path\To\NestedSecurityGroupUsers.csv" -NoTypeInformation

Write-Host "User details have been exported to C:\Path\To\NestedSecurityGroupUsers.csv"
