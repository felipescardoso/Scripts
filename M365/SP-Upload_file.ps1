Install-Module -Name PnP.PowerShell -AllowPrerelease

#Config Variables
$SiteURL = "https://familiacardoso.sharepoint.com/sites/ORG"
$SourceFilePath ="C:\@TI\Teste_SP.xlsx"
$DestinationPath = "/Documents" #Relative Path of the Library
  
#Get Credentials to connect
$Cred = Get-Credential
  
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -Credentials $Cred
      
#powershell pnp to upload file to sharepoint online
Add-PnPFile -Path $SourceFilePath -Folder $DestinationPath