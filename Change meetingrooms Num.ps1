#This is a script created by Michael Wang.
$Roominfo = Import-Csv "C:\Users\michael_wang\Documents\meetingrooms.csv"
foreach ($room in $Roominfo)
{
    $Num = $room.Num
    $Names = $room.Names
   $Sam = Get-ADUser -Filter {name -like $Names} | select $_.SamAccountName
    Set-ADUser $Sam -OfficePhone $Num
}