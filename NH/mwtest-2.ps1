#######Part-I Create User Account in AD
Add-PSSnapin quest.activeroles.admanagement -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Admin -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

Connect-QADService -Service jn-dc1 |out-null

cls
[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The script is create new hire account from c:\NH\newhire.csv, please wait patiently!!!"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
[console]::resetcolor()

$newhire = Import-Csv C:\NH\newhire.csv

$managerOU = $newhire[0].dept + "'s team"

#######User withou initials
if ($newhire[0].initials -eq "")
{
    $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name $managerOU ).DN
    $FirstName = $newhire[0].firstname
    $LastName = $newhire[0].lastname
    $Name = $FirstName +" " + $LastName
    $LogonName = $FirstName +"_" + $LastName
    #####Check if User Account is Exist
    if (get-qaduser -SamAccountName $LogonName)
    {
        [console]::ForegroundColor = "red"
        write-host "The user" $LogonName " exists in system, please check user name again!!!"
        [console]::resetcolor()
        Remove-Variable newhire
        Remove-Variable LogonName
        Remove-Variable ParentContainer
        Remove-Variable FirstName
        Remove-Variable LastName
        Remove-Variable Name
        EXIT
      }
      
     $LogonScript = "logon.cmd"
     $Description = $newhire[0].desc
     $Pwd = $newhire[0].pwd
     $UserPrincipalName = $LogonName + "@resourcepro0.resourcepro.com"
####Create Account
New-QADUser -name $Name -ParentContainer $ParentContainer -description $Description -DisplayName $Name -firstname $FirstName -lastname $LastName -logonscript $LogonScript -samaccountname $LogonName -userpassword $Pwd -UserPrincipalName $UserPrincipalName -confirm |select Name,LogonName,Description,ParenContainer|format-list
}
######User with initials
else
{
    $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name $managerOU ).DN
    $FirstName = $newhire[0].firstname
    $Initials = $newhire[0].initials
    $LastName = $newhire[0].lastname
    $Name = $FirstName +" " + $Initials+"." + " "+ $LastName
    $LogonName = $FirstName +"_" + $Initials +"_"+ $LastName
    #####Check if user account is exist
        if (Get-QADUser -SamAccountName $LogonName)
        {
            [console]::ForegroundColor = "red"
            write-host "The User" $LogonName " exists in system, please check user name again!!!"
            [console]::resetcolor()
            Remove-Variable newhire
            Remove-Variable LogonName
            Remove-Variable ParentContainer
            Remove-Variable FirstName
            Remove-Variable Lastname
            Remove-Variable Name
            Remove-Variable Initials
            EXIT
          }
      $LogonScript = "logon.cmd"
      $Description = $newhire[0].desc
      $Pwd = $newhire[0].pwd
      $UserPrincipalName = $LogonName + "@resourcepro0.resourcepro.com"
######Create Account
New-QADUser -Name $Name -ParentContainer $ParentContainer -Description $Description -DisplayName $Name -FirstName $FirstName -Initials $Initials -LastName $LastName -logonscript $LogonScript -samaccountname $LogonName -userpassword $Pwd -UserPrincipalname $UserPrincipalName -confirm |select Name,LogonName,Description,ParentContainer|format-list
}

Set-QADUser $LogonName -UserMustChangePassword 1 |out-null

######Add User to Group
$MailCityGroup = "a.rsp." + $newhire[0].location
if($newhire[0].team -eq "ALL")
{
    $ADTeamGroup = "rsp.group.alliant"
}
else
{
    $ADTeamGroup = "rsp.group." + $newhire[0].team
}

######For ALL and PHP
if (($newhire[0].team -eq "PHP") -OR ($newhire[0].team -eq "ALL"))
{
    if ($newhire[0].location -eq "Qingdao")
        {
        $MailTeamGroup = "a.rsp.team." + $newhire[0].team + ".QD"
        }
    else
        {
        $MailTeamGroup = "a.rsp.team." + $newhire[0].team + ".JN"
        }
 }
 else
 {
    #####Default mail group
    $MailTeamGroup = "a.rsp.team." + $newhire[0].team
 }
 
$SparkGroup = "a.spark." + $newhire[0].dept

Add-qadgroupmember .rsp.all -member $LogonName |out-null
Add-qadgroupmember $MailCityGroup -member $LogonName |out-null
Add-qadgroupmember $SparkGroup -member $LogonName |out-null
Add-qadgroupmember $ADTeamGroup -member $LogonName |out-null
Add-qadgroupmember $MailTeamGroup -member $LogonName |out-null

#####Do sleep until system found new created user account

#############################Part-II Create User Mailbox in Exchange

###Enable Mailbox

[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The Script is Creating New Hire Mailbox for the Following User, Please wait patienlty!!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()

sleep 16
Get-QADUser $LogonName |select-object logonname,description,CanonicalName |fl

$userid = (Get-QADUser $logonName).CanonicalName
$alias = (Get-QADUser $logonName).logonname

if ($newhire[0].location -eq "Qingdao")
    {$database = "EXCH-CMB-QD\STG-Proc\DB-Proc"}
else
    {$database = "EXCH-CMB-QD\STG-ProcJN\DB-ProcJN"}

Enable-Mailbox -Identity $userid -Alias $alias -Database $database -DomainController jn-dc1 -confirm |out-null

###Sleep 10
Write-Host "IT IS CREATING MAIL ACCOUNT, PLEASE WAIT 7 SECONDS:"
$count =7,6,5,4,3,2,1
foreach($i in $count)
{
    sleep 1
    Write-Host $i "     " -nonewline
}

######Add the secondary mail address
$firstAddress = $LogonName + "@resourcepro.com.cn"
$secondAddress = $firstAddress -replace "_", "."
$user = (Get-Mailbox $LogonName -DomainController jn-dc1)
$user.emailaddresses += $secondAddress
Set-Mailbox $LogonName -emailaddresses $user.emailaddresses -DomainController jn-dc1

#####Sleep 10

Write-Host " "
Write-Host "IT IS CREATING THE 2ND MAIL ADDRESS, PLEASE WAIT ANOTHER 7 SECONDS:"
$count =7,6,5,4,3,2,1

foreach ($i in $count)
{
    sleep 1
    write-host $i "    " -nonewline
}
[console]::ForegroundColor = "green"
Write-Host " "
Write-Host " "
Write-Host "Added the secondary email address, please see below:"

[console]::resetcolor()
(Get-Mailbox $LogonName -DomainController jn-dc1).emailaddresses


###################Part-III Create User Personal Folder in File Server

[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host "The script is creating personal folder for the following user, please wait patienlty!!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()

[console]::backgroundColor = "blue"
Write-Host "The newhire logon name is:" $LogonName
[console]::resetcolor()

### Close Y drive without confirm
net use y: /delete /y
net use y: \\rsp-fs-qd\Personal
### rem create user folder
Y:
md $LogonName
### rem close inheritance
icacls $LogonName /inheritance:d

### rem remove "Authenticated Users"
icacls $LogonName /remove "Authenticated Users"

### rem add user and grant modify permission
$nhcolon = $LogonName + ":"
icacls $LogonName /grant $nhcolon`(OI`)`(CI`)M
c:



##################Part-IV Output Newhire Info to File
[console]::backgroundColor = "blue"
Write-Host "The script is writing user info to a txt file, please wait"
Write-host "-----------------------------------------"
[console]::resetcolor()

#### get input user info:
echo "input user info:" >C:\NH\1.txt
echo "---------------" >>C:\NH\1.txt
$newhire[0] |ft >>C:\NH\1.txt


##### created user Info 
Get-QADUser $logonName |fl logonname,description,@{name="OU Location";expression={$_.ParentContainerDN}} >>C:\NH\1.txt


#### output logoname with password to 2.txt
$lninfo = "LogonName: " + $logonName
$pwinfo = "Password:  " + $pwd 
echo $lninfo  >C:\NH\2.txt
echo $pwinfo >>C:\NH\2.txt

### get mailaddresses
echo "mail addresses:" >>C:\NH\1.txt
echo "---------------" >>C:\NH\1.txt
(Get-QADUser $logonName).ProxyAddresses |findstr /i smtp   >>C:\NH\1.txt


#### get-memberof
Get-QADMemberOf $logonName |select-object @{name="Memberof";expression={$_.Name}} >>C:\NH\1.txt



#### Get access personal folder
net use y: /delete /y
net use y: \\rsp-fs-qd\Personal
(get-acl Y:\$logonName) | Select @{Name=”Personal folder”;Expression={convert-path $_.pspath }}  >>C:\NH\1.txt
(get-acl Y:\$logonName).access |select IdentityReference,FileSystemRights,IsInherited    >>C:\NH\1.txt
C:


#### all new user info output to total.txt
cat C:\NH\1.txt >>C:\NH\total.txt

#### all new user logon info with password output to totaluserpwd.txt
echo "        " >>C:\NH\lnpwd.txt
cat C:\NH\2.txt >>C:\NH\lnpwd.txt







########################## Part V - clear variables

Remove-Variable  newhire
Remove-Variable  ParentContainer
Remove-Variable FirstName
Remove-Variable LastName
Remove-Variable Name
Remove-Variable logonName
Remove-Variable logonscript
Remove-Variable description
Remove-Variable pwd
Remove-Variable UserPrincipalName
###Remove-Variable Initials
Remove-Variable MailCityGroup
Remove-Variable ADTeamGroup
Remove-Variable MailTeamGroup
Remove-Variable SparkGroup
Remove-Variable nhcolon
Remove-Variable userid
Remove-Variable alias
Remove-Variable database
Remove-Variable firstAddress
Remove-Variable secondAddress
Remove-Variable user
Remove-Variable pwinfo
Remove-Variable lninfo
