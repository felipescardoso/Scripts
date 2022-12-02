Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

Install-Module ORCA -Scope CurrentUser

Import-Module ORCA -Scope Local

Get-ORCAReport


####
Install-Module -Name CAMP -Scope CurrentUser

Get-CAMPReport
