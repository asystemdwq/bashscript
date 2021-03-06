##### enable mailbox

cls
[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The script is creating new hire mailbox for the following user,  please wait patienlty!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()

$userlist = Import-Csv C:\NH\logonname.csv

foreach ($newhire in $userlist) 
{


Get-QADUser $newhire.name |select-object logonname, description,CanonicalName |fl



$userid = (Get-QADUser $newhire.name).CanonicalName
$alias = (Get-QADUser $newhire.name).logonname
$database = "EXCH-CMB-QD\STG-Proc\DB-Proc"

Enable-Mailbox -Identity $userid -Alias $alias -Database $database -confirm |out-null

Sleep 20

##### add the secondary mail address
$firstAddress = $newhire.name + "@resourcepro.com.cn"
$secondAddress = $firstAddress -replace "_", "."

$user = (Get-Mailbox $newhire.name)
$user.emailaddresses += $secondAddress
Set-Mailbox $user.name -emailaddresses $user.emailaddresses

Sleep 20
[console]::ForegroundColor = "green"
Write-Host " "
Write-Host " "
Write-Host " Added the secondary email address, please see below:"

[console]::resetcolor()

(Get-Mailbox $user.name).emailaddresses

}