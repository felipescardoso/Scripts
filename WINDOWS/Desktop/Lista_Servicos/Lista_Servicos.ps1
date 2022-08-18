<#OBSEVAÇÕES#######################################
Test-Connection mvasgnfk00 -Count 1 -Quiet
Get-Service -ComputerName mvasgnfk00 -Name "wuauserv" | Select-Object Name,Status | Where-Object {$_.Name -eq "wuauserv"}
#>

$Scriptpath = "C:\Users\GNFK\Desktop\SMDI\0-Scripts\Powershell\Scripts\Desktop\Lista_Servicos\"

$Listas = Get-Content $Scriptpath\lista.txt
New-Item -type file -force $Scriptpath\Resultado.log
"HOSTNAME; STATUS" | Out-File $Scriptpath\Resultado.txt -Encoding ascii -Append -Force

ForEach ($Desktop in $Listas) {

    #Write-Host $Desktop
    $TestServico = Get-Service -ComputerName $Desktop -Name "wuauserv" | Select-Object Status
    
    #Add-Content -$Scriptpath\Resultado.txt 
    "$Desktop; $TestServico" | Out-File $Scriptpath\Resultado.LOG -Encoding ascii -Append -Force

}



