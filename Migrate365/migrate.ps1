#This is script is created by Michael Wang. The perpose is migrate users to office 365
$userinfo = Import-csv "C:\Migrate365\userinfo.csv"
#Import Exhcange mode
$username = "resourcepro0\mwang"
$passwrod = "Init_8852"
$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username, $passwrod
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://us-exch-hybrid2.resourcepro0.resourcepro.com/powershell -Credential $cred -Authentication default
Import-PSSession $Session
#Check user status & migrate it to office
foreach ($user in $userinfo)
{
$name1 = $user.name1
if ($name1) {if (get-mailbox $name1) {new-moverequest -identity $name1 -Baditemlimit "200"} else {echo "$name1 is already on office365"}}
#Check Move Request status
if ($name1) {get-moverequest $name1}
}
