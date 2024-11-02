# Define the security group name
$securityGroup = "YourSecurityGroupName"

# Initialize an array to store the user details
$userDetails = @()

# Get all members of the security group
$groupMembers = Get-ADGroupMember -Identity $securityGroup | Where-Object { $_.objectClass -eq "user" }

# Loop through each user and get the required details
foreach ($user in $groupMembers) {
    $adUser = Get-ADUser -Identity $user.SamAccountName -Properties DisplayName, SamAccountName, Enabled, Title, Department, Manager, EmailAddress, LastLogonDate, Info

    # Store the details in a custom object
    $userDetails += [PSCustomObject]@{
        Name            = $adUser.DisplayName
        SamName         = $adUser.SamAccountName
        AccountStatus   = if ($adUser.Enabled) { "Enabled" } else { "Disabled" }
        Title           = $adUser.Title
        Department      = $adUser.Department
        Manager         = (Get-ADUser -Identity $adUser.Manager).DisplayName
        Email           = $adUser.EmailAddress
        LastLogOnTime   = $adUser.LastLogonDate
        Notes           = $adUser.Info
    }
}

# Export the user details to a CSV file
$userDetails | Export-Csv -Path "C:\Path\To\SecurityGroupUsers.csv" -NoTypeInformation

Write-Host "User details have been exported to C:\Path\To\SecurityGroupUsers.csv"
