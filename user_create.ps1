# Import the Active Directory module
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms

# Define roles and their corresponding AD groups
$roles = @{
    'Standard User' = 'group1', 'group2'
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'New User Creation'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

# Add first name label and text box
$firstNameLabel = New-Object System.Windows.Forms.Label
$firstNameLabel.Location = New-Object System.Drawing.Point(10,20)
$firstNameLabel.Size = New-Object System.Drawing.Size(280,20)
$firstNameLabel.Text = 'First Name:'
$form.Controls.Add($firstNameLabel)

$firstNameTextBox = New-Object System.Windows.Forms.TextBox
$firstNameTextBox.Location = New-Object System.Drawing.Point(10,40)
$firstNameTextBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($firstNameTextBox)

# Add last name label and text box
$lastNameLabel = New-Object System.Windows.Forms.Label
$lastNameLabel.Location = New-Object System.Drawing.Point(10,70)
$lastNameLabel.Size = New-Object System.Drawing.Size(280,20)
$lastNameLabel.Text = 'Last Name:'
$form.Controls.Add($lastNameLabel)

$lastNameTextBox = New-Object System.Windows.Forms.TextBox
$lastNameTextBox.Location = New-Object System.Drawing.Point(10,90)
$lastNameTextBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($lastNameTextBox)

# Add role label and combo box
$roleLabel = New-Object System.Windows.Forms.Label
$roleLabel.Location = New-Object System.Drawing.Point(10,120)
$roleLabel.Size = New-Object System.Drawing.Size(280,20)
$roleLabel.Text = 'Role:'
$form.Controls.Add($roleLabel)

$roleComboBox = New-Object System.Windows.Forms.ComboBox
$roleComboBox.Location = New-Object System.Drawing.Point(10,140)
$roleComboBox.Size = New-Object System.Drawing.Size(260,20)
$roles.Keys | ForEach-Object { $roleComboBox.Items.Add($_) }
$form.Controls.Add($roleComboBox)

# Add submit button
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Location = New-Object System.Drawing.Point(10,170)
$submitButton.Size = New-Object System.Drawing.Size(260,20)
$submitButton.Text = 'Create User'
$submitButton.Add_Click({
    $firstName = $firstNameTextBox.Text
    $lastName = $lastNameTextBox.Text
    $username = $firstName.Substring(0,1) + $lastName
    $i = 2
    while (Get-ADUser -Filter { SamAccountName -eq $username }) {
        $username = $username + $i
        $i++
    }
    $UserPassword = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force
    $UserProperties = @{
        SamAccountName = $username
        UserPrincipalName = "$username@domain.com"
        Name = "$firstName $lastName"
        GivenName = $firstName
        Surname = $lastName
        Enabled = $True
        AccountPassword = $UserPassword
        ChangePasswordAtLogon = $False
        PasswordNeverExpires = $True
        Path = "OU=Users,DC=domain,DC=com" #specify the correct Organizational Unit (OU)
    }
    $newUser = New-ADUser @UserProperties -PassThru
    $role = $roleComboBox.SelectedItem
    if ($role) {
        $groups = $roles[$role]
        foreach ($group in $groups) {
            Add-ADGroupMember -Identity $group -Members $newUser
        }
    }
})
$form.Controls.Add($submitButton)

# Show the form
$form.ShowDialog()
