### Enable account, move the user to correct OU, add the user to related security groups, distribution groups and spark group.


### Enable rehired people mailbox part
$newhire = Import-Csv C:\NH\logonname.csv


Get-QADUser $newhire[0].name |select-object logonname, description,CanonicalName |fl
$userLogonname = (Get-QADUser $newhire[0].name).logonname
Get-qaduser $userLogonname |ft name,description,dn

[console]::BackgroundColor= "red"

$Choice = Read-Host "Are you sure to enable the user" $LogonName  "? (y/n)"
[console]::ResetColor()

If ($Choice.ToLower() -eq "y")
 {

   Get-Mailbox $userLogonname   |Set-Mailbox -HiddenFromAddressListsEnabled $false

   Get-Mailbox $userLogonname  |Set-Mailbox -AcceptMessagesOnlyFrom $null

   Get-Mailbox $userLogonname  |Move-Mailbox -TargetDatabase EXCH-CMB-QD\STG-Proc\DB-Proc

  ##non process
  ###Get-Mailbox $userLogonname  |Move-Mailbox -TargetDatabase EXCH-CMB-QD\STG-Nonproc\DB-Nonproc

}
else
 {
	exit
 }
