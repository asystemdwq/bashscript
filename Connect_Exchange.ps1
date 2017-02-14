$username = "resourcepro0\mwang"
$passwrod = ConvertTo-SecureString "Init_8852"
$cred = new-object -typename System.Management.Automation.PSCredential -ArgumentList $username, $passwrod
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://us-exch-hybrid2.resourcepro0.resourcepro.com/powershell -Credential $cred -Authentication default
Import-PSSession $Session