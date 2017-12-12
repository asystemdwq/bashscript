#This is script is created by Michael Wang. The perpose is migrate users to office 365
$userinfo = Import-csv "C:\scripts\Migrate365\userinfo.csv"
#Import Exhcange mode
$username = "resourcepro0\mwang"
$365username = "michael_wang@resourcepro.com.cn"
$password = Get-Content C:\scripts\Migrate365\pass.txt | ConvertTo-SecureString
$365cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($365username, $password)
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$Session = New-pssession –configurationname Microsoft.exchange –connectionuri https://ps.outlook.com/powershell/ -credential $365cred –authentication basic –allowredirection
Import-PSSession $Session
#Check user status & migrate it to office
foreach ($user in $userinfo)
{
$name1 = $user.name1
New-moverequest –identity $name1 –remote –remotehostname rsp-us-mx1.resourcepro.com.cn –remotecredential $cred –targetdeliverydomain resourcepro.mail.onmicrosoft.com -BadItemLimit 200
}