


$newhire = Import-Csv C:\NH\newhire.csv

####### Function Check[]

#### Check the user name is available in AD

$FirstName = $newhire[0].firstname
$Initials = $newhire[0].initials
$LastName = $newhire[0].lastname
$logonName = $FirstName +"_" + $LastName
$ADTeamGroup = "rsp.group." + $newhire[0].team
$MailTeamGroup = "a.rsp.team." + $newhire[0].team




Function CheckName
{

  IF (Get-QADUser $logonName) 
  {
     Write-host "The user name exists in system, please check input name info!"
     Exit
  
  }

}
$logonName
CheckName

Function CheckOU
{
  IF ((Get-QADObject -Type 'organizationalUnit' -name $newhire[0].team) -eq "")
  {
     Write-host "The team does not exists in system, please check input team info!"
     Exit
  
  }

}



Function CheckGroup
{
  IF ((Get-QADGroup -name $ADTeamGroup -eq "") -and (Get-QADGroup -name $MailTeamGroup -eq ""))
  {
     Write-host "The script cannot create user for the team, the team group doesnot have a standard name, please check input team info and create the user manually!"
     Exit
  
  }

}


#### 
Remove-Variable newhire
Remove-Variable logonName
Remove-Variable ADTeamGroup
Remove-Variable MailTeamGroup
Remove-Variable FirstName
Remove-Variable LastName
