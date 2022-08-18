#https://dejanstojanovic.net/powershell/2018/january/automated-clean-up-and-archive-of-log-files-with-powershell-5/
#https://dejanstojanovic.net/powershell/2018/january/clean-up-iis-log-files-from-web-server-using-powershell/
#Editado por Herbert Carlos em 27/06/2022
<#
    #/powershell.exe -file C:\Scripts\Zip-Old-Log-Files.ps1 -logFolder C:\temp\log\ -fileAge 7 -archiveAge 30
    powershell.exe -file "C:\Users\herbert.melo\OneDrive - RADIX ENGENHARIA E DESENVOLVIMENTO DE SOFTWARE S A (ISV)\Documentos\Script -logOrigem\Compac_Clean_Logs.ps1" "C:\temp\logs2" -logDest "c:\temp\logDest\" -fileAge 5 -archiveAge 30
    powershell.exe -file C:\SCCM_TI\SCRIPT\Compac_Clean_Logs.ps1 -logOrigem "C:\inetpub\logs\LogFiles\W3SVC1" -logDest "C:\SCCM_TI\IIS_LogFiles_Zip\W3SVC1\" -fileAge 5 -archiveAge 30
    powershell.exe -file C:\SCCM_TI\SCRIPT\Compac_Clean_Logs.ps1 -logOrigem "C:\inetpub\logs\LogFiles\W3SVC561526725" -logDest "C:\SCCM_TI\IIS_LogFiles_Zip\W3SVC561526725\" -fileAge 5 -archiveAge 30
#>

#Limpar variaveis
#Remove-Variable -Name * -ErrorAction SilentlyContinue

Param(  
[Parameter(Mandatory=$true)]  
[string]$logOrigem,  
[Parameter(Mandatory=$true)]  
[string]$logDest,  
[Parameter(Mandatory=$true)]  
[int]$fileAge,  
[Parameter(Mandatory=$true)]  
[int]$archiveAge  
)  

Write-Output $psversiontable 

#Origem
#C:\inetpub\logs\LogFiles\W3SVC1
#C:\inetpub\logs\LogFiles\W3SVC561526725
#$logOrigem = "C:\temp\logs2"

#Destino
#C:\SCCM_TI\IIS_LogFiles_Zip\W3SVC1\
#C:\SCCM_TI\IIS_LogFiles_Zip\W3SVC561526725\
#$logDest = "c:\temp\logDest\"

#Quantidade de dias passados que o log deve ser mantido sem compactar
$fileAge = 5  
#Quantidade de dias passados que o zip deve ser mantido sem apagar
$archiveAge = 30  
  
$logFiles = Get-ChildItem $logOrigem -Filter *.log | Where LastWriteTime -lt  (Get-Date).AddDays(-1 * $fileAge)  
#$destinationPath = $logDest+"\"+(Get-Date -format "yyyyMMddHHmmss")+".zip"  
  
$logFilePaths = @()  
  
foreach($logFile in $logFiles){  
    $logFilePaths  = $logFile.FullName 
    $destinationPath = $logDest+$logFile.BaseName+"_"+(Get-Date -format "yyyyMMddHHmmss")+".zip"
    Compress-Archive -Path $logFilePaths -DestinationPath $destinationPath  -CompressionLevel Optimal  
    Remove-Item –path $logFilePaths 
}   
  
$archiveFiles = Get-ChildItem $logDest -Filter *.zip | Where LastWriteTime -lt  (Get-Date).AddDays(-1 * $archiveAge)  
  
foreach($archiveFile in $archiveFiles){  
    Remove-Item –path $archiveFile.FullName  
}  


#Comandos para criar a tarefa agendada
<#
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-file C:\SCCM_TI\SCRIPT\Compac_Clean_Logs.ps1 -logOrigem "C:\inetpub\logs\LogFiles\W3SVC1" -logDest "C:\SCCM_TI\IIS_LogFiles_Zip\W3SVC1\" -fileAge 5 -archiveAge 30'
    $trigger = New-ScheduledTaskTrigger -DaysOfWeek Monday -Weekly -At 14:00:00 
    $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest #-GroupId "BUILTIN\Administrators" -RunLevel Highest  
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "IIS Compac_Clean_Logs1" -Description "Compactar e limpar os logs do IIS" -TaskPath RADIX
#>