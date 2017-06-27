$userinfo = Import-Csv "C:\licenses\userlist.csv"
$username = "Michael_Wang@resourcepro.com.cn"
$password = cat C:\Licenses\pass.txt | ConvertTo-SecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
Connect-MsolService -Credential $cred
foreach ($users in $userinfo)
{
    $user = $users.Name
    $Add = $users.Add
    $Remove = $users.Remove
    if ($user)
    {
        Set-MsolUserLicense -UserPrincipalName $user -RemoveLicenses "resourcepro:$($Remove)"
        if ($Add)
        {set-msoluserLicense -UserPrincipalName $user -AddLicenses "resourcepro:$($Add)"}
    }
}
