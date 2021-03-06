######################## PartI - create user account in AD
Add-PSSnapin  quest.activeroles.admanagement -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

Connect-QADService -Service jn-dc1 |out-null

cls
[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The script is creating new hire account from c:\NH\newhire.csv,  please wait patienlty!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()

$newhire = Import-Csv C:\NH\newhire.csv


$managerOU = $newhire[0].dept + "'s team"
####### user wihtout initials
if ($newhire[0].initials -eq "") 
{

 
 
### For TWRA
  IF (($newhire[0].team -eq "TWRA") -or($newhire[0].team -eq "ALL"))
   {
     if ($newhire[0].location -eq "Qingdao")
    {
     $QDlocation = $newhire[0].team + "-QD"
     $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name $QDlocation ).DN
     Remove-Variable QDlocation
    }
    else
    {
    $JNlocation = $newhire[0].team + "-JN"
    $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name $managerOU ).DN 
    Remove-Variable JNlocation
    }
   }
  ELSE
  {
  ### check huangdao
        if ($newhire[0].location -eq "Huangdao")
        {
         $HDlocation = $newhire[0].team + "-HD"
        $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name $managerOU ).DN
        Remove-Variable HDlocation
        }
  }
#### 
  
$FirstName = $newhire[0].firstname
$LastName = $newhire[0].lastname

$Name =  $FirstName +" " + $LastName
$logonName = $FirstName +"_" + $LastName
        ###Check if user account is exist
         if (get-qaduser -SamAccountName $logonName)
         {
            [console]::ForegroundColor = "red"
            write-host  "The user" $logonName " exists in system, please check user name again!!! "
            [console]::resetcolor()
            Remove-Variable  newhire
            Remove-Variable  logonName
            Remove-Variable  ParentContainer
            Remove-Variable FirstName
            Remove-Variable LastName
            Remove-Variable Name
            EXIT
         }

$logonscript = "logon.cmd"
$description = $newhire[0].desc
$pwd = $newhire[0].pwd
$UserPrincipalName = $logonname + "@resourcepro0.resourcepro.com"
#### create account

New-qaduser -name $name -ParentContainer $ParentContainer -description $description -DisplayName $name -firstname $FirstName -lastname $LastName -logonscript $logonscript  -samaccountname $logonname -userpassword $pwd  -UserPrincipalName $UserPrincipalName -confirm |select Name,LogonName,Description,ParentContainer|format-list


}

######### user with initials
else
{


### For TWRA
  IF ($newhire[0].team -eq "TWRA")
   {
     if ($newhire[0].location -eq "Qingdao")
    {

     $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name TWRA-QD ).DN 
 
    }
    else
    {
   $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name TWRA-JN ).DN 
    }
   }
  ELSE
  {
  ### check huangdao
        if ($newhire[0].location -eq "Huangdao")
        {
        $HDlocation = $newhire[0].team + "-HD"
        $ParentContainer = (Get-QADObject -Type 'organizationalUnit' -name $managerOU ).DN
        Remove-Variable HDlocation
        }      
  
  }
#### 


$FirstName = $newhire[0].firstname
$Initials = $newhire[0].initials
$LastName = $newhire[0].lastname

$Name =  $FirstName +" " + $Initials+"." + " "+ $LastName
$logonName =  $FirstName +"_" +$Initials +"_"+ $LastName
        ###Check if user account is exist
         if (get-qaduser -SamAccountName $logonName)
         {
            [console]::ForegroundColor = "red"
            write-host  "The user" $logonName " exists in system, please check user name again!!! "
            [console]::resetcolor()
            Remove-Variable  newhire
            Remove-Variable  logonName
            Remove-Variable  ParentContainer
            Remove-Variable FirstName
            Remove-Variable LastName
            Remove-Variable Name
            Remove-Variable Initials
            EXIT
         }
$logonscript = "logon.cmd"
$description = $newhire[0].desc
$pwd = $newhire[0].pwd
$UserPrincipalName = $logonname + "@resourcepro0.resourcepro.com"
#### create account

New-qaduser -name $name -ParentContainer $ParentContainer -description $description -DisplayName $name -firstname $FirstName -Initials $Initials -lastname $LastName -logonscript $logonscript  -samaccountname $logonname -userpassword $pwd -UserPrincipalName $UserPrincipalName -confirm |select Name,LogonName,Description,ParentContainer|format-list

}


Set-qaduser $logonName -UserMustChangePassword 1 |out-null

##### add user to group

$MailCityGroup = "a.rsp." + $newhire[0].location

###For TWRA
 IF ($newhire[0].team -eq "TWRA")
 {
   $ADTeamGroup = "rsp.group.twr"
 } 
 ELSE
 {
 $ADTeamGroup = "rsp.group." + $newhire[0].team
 }
#### for all and php
    if (($newhire[0].team -eq "PHP") -OR ($newhire[0].team -eq "ALL") -OR ($newhire[0].team -eq "TWRA"))
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
          ### Default mail group format
          $MailTeamGroup = "a.rsp.team." + $newhire[0].team
    }
        

$SparkGroup = "a.spark." + $newhire[0].dept

Add-qadgroupmember .rsp.all -member $logonname |out-null
Add-qadgroupmember $MailCityGroup -member $logonname |out-null
Add-qadgroupmember $sparkgroup -member $logonname |out-null
Add-qadgroupmember $ADTeamGroup -member $logonname |out-null
Add-qadgroupmember $MailTeamGroup -member $logonname |out-null















#### Do sleep until system found new created user account
##Do {sleep 1}
##until (Get-QADUser $logonName)


############################# PartII - create user mailbox in Exchange


##### enable mailbox


[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The script is creating new hire mailbox for the following user,  please wait patienlty!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()

sleep 16

Get-QADUser $logonName |select-object logonname,description,CanonicalName |fl


$userid = (Get-QADUser $logonName).CanonicalName
$alias = (Get-QADUser $logonName).logonname

if ($newhire[0].location -eq "Qingdao") 
   {$database = "EXCH-CMB-QD\STG-Proc\DB-Proc"}
else
   {$database = "EXCH-CMB-QD\STG-ProcJN\DB-ProcJN"} 


Enable-Mailbox -Identity $userid -Alias $alias -Database $database -DomainController jn-dc1 -confirm |out-null

###Sleep 10
write-host "IT IS CREATING MAIL ACCOUNT, PLEASE WAIT 7 SECONDS:"
$count =7,6,5,4,3,2,1

foreach ($i in $count)
{
 sleep 1
 write-host $i "   " -nonewline

}

##### add the secondary mail address
$firstAddress = $logonName + "@resourcepro.com.cn"
$secondAddress = $firstAddress -replace "_", "."

$user = (Get-Mailbox $logonName -DomainController jn-dc1)
$user.emailaddresses += $secondAddress
Set-Mailbox $logonName -emailaddresses $user.emailaddresses -DomainController jn-dc1

###Sleep 10
write-host " "
write-host "IT IS CREATING THE 2ND MAIL ADDRESS, PLEASE WAIT ANOTHER 7 SECONDS:"
$count =7,6,5,4,3,2,1

foreach ($i in $count)
{
 sleep 1
 write-host $i "   " -nonewline

}
[console]::ForegroundColor = "green"
Write-Host " "
Write-Host " "
Write-Host " Added the secondary email address, please see below:"

[console]::resetcolor()

(Get-Mailbox $logonName -DomainController jn-dc1).emailaddresses













######################### PartIII - create user personal folder in file server

[console]::ForegroundColor = "magenta"
Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
Write-Host " The script is creating personal folder for the following user,  please wait patienlty!!!"
Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
[console]::resetcolor()



[console]::backgroundColor = "blue"
Write-Host " The newhire logon name is:" $logonName
[console]::resetcolor()


#### close y drive without confirm
net use y: /delete /y

net use y: \\rsp-fs-qd\Personal
####### rem create user folder  

Y:

md $logonName


####### rem close inheritance  
icacls  $logonName /inheritance:d

#### rem remove "Authenticated Users" 
icacls $logonName /remove "Authenticated Users"


##### rem add user and grant modify permission 
$nhcolon = $logonName + ":"

icacls $logonName /grant $nhcolon`(OI`)`(CI`)M

c:
























############################ Part IV - Output newhire info to file
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

Remove-Variable $managerOU






