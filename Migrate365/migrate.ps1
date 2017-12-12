#This is script is created by Michael Wang. The perpose is migrate users to office 365
$userinfo = Import-csv "C:\scripts\Migrate365\userinfo.csv"
#Check user status & migrate it to office
foreach ($user in $userinfo)
{
#Import Exhcange mode
$username = "resourcepro0\mwang"
$365username = "michael_wang@resourcepro.com.cn"
$password = Get-Content C:\scripts\Migrate365\pass.txt | ConvertTo-SecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$365cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $365username, $password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://us-exch-hybrid2.resourcepro0.resourcepro.com/powershell -Credential $cred -Authentication default
Import-PSSession $Session
$name1 = $user.name1
if ($name1) {if (get-mailbox $name1) {new-moverequest -identity $name1 -Baditemlimit "200"} else {echo "$name1 is already on office365"
continue}}
#Check Move Request status
Do
{
    $status = (Get-MoveRequest | select Alias, status |Where-Object {$_.Alias -eq "$name1"}).status
    Switch ($status)

    {
        "Inprogress" {
            Write-Output "Migrate $name1 Still in progress"
        }
        "Completed"
        {
            Write-Output "Migrate $name1 job is completed, strat to migrate $name1 mailbox to o365"
            $365Session = New-pssession –configurationname Microsoft.exchange –connectionuri https://ps.outlook.com/powershell/ -credential $365cred –authentication basic –allowredirection
            Import-PSSession $365Session
        }
    }
} Until ($status -eq "Completed")


}