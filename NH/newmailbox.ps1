##### enable mailbox

cls
[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The script is creating new hire mailbox for the following user,  please wait patienlty!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()

$newhire = Import-Csv C:\NH\logonname.csv


Get-QADUser $newhire[0].name |select-object logonname, description,CanonicalName |fl



$userid = (Get-QADUser $newhire[0].name).CanonicalName
$alias = (Get-QADUser $newhire[0].name).logonname
##$database = "EXCH-CMB-QD\STG-Proc\DB-Proc"
$database = "EXCH-CMB-QD\STG-NonProc\DB-NonProc"


Enable-Mailbox -Identity $userid -Alias $alias -Database $database -DomainController rspdc2 -confirm |out-null

###Sleep 15
write-host "IT IS CREATING MAIL ACCOUNT, PLEASE WAIT 5 SECONDS:"
$count =5,4,3,2,1

foreach ($i in $count)
{
 sleep 1
 write-host $i "  " -nonewline

}

##### add the secondary mail address
$firstAddress = $newhire[0].name + "@resourcepro.com.cn"
$secondAddress = $firstAddress -replace "_", "."

$user = (Get-Mailbox $newhire[0].name)
$user.emailaddresses += $secondAddress
Set-Mailbox $newhire[0].name -emailaddresses $user.emailaddresses -DomainController rspdc2

write-host " "
write-host "IT IS CREATING THE 2ND MAIL ADDRESS, PLEASE WAIT ANOTHER 5 SECONDS:"
###Sleep 15
$count =5,4,3,2,1

foreach ($i in $count)
{
 sleep 1
 write-host $i "  " -nonewline

}
[console]::ForegroundColor = "green"
Write-Host " "
Write-Host " "
Write-Host " Added the secondary email address, please see below:"

[console]::resetcolor()

(Get-Mailbox $newhire[0].name -DomainController rspdc2).emailaddresses