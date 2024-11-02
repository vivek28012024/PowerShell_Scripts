# Define the path to the text file containing the usernames
$userListPath = "C:\Path\To\Usernames.txt"

# Read the usernames from the file
$usernames = Get-Content -Path $userListPath

# Initialize an array to store the user details
$userDetails = @()

# Loop through each username and get the user department from Active Directory
foreach ($username in $usernames) {
    $user = Get-ADUser -Identity $username -Properties Department
    $userDetails += [PSCustomObject]@{
        Username    = $username
        Department  = $user.Department
    }
}

# Export the user details to a CSV file
$userDetails | Export-Csv -Path "C:\Path\To\UserDepartments.csv" -NoTypeInformation

Write-Host "User departments have been exported to C:\Path\To\UserDepartments.csv"
