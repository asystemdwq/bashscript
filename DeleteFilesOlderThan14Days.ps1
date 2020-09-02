$Folder = "E:\"

#Delete files older than 6 months
Get-ChildItem $Folder -Recurse -Force -ea 0 |
? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-14)} |
ForEach-Object {
   filter timestamp {"$(Get-Date -Format o): $_"}
   $_ | del -Force
   $_.FullName | timestamp | Out-File C:\log\deletedlog.txt -Append
}
