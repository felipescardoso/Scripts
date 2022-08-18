<#OBSEVAÇÕES#######################################
Test-Connection mvasgnfk00 -Count 1 -Quiet
Get-Service -ComputerName mvasgnfk00 -Name "wuauserv" | Select-Object Name,Status | Where-Object {$_.Name -eq "wuauserv"}
#>

$Scriptpath = "C:\Users\GNFK\Desktop\SMDI\0-Scripts\Powershell\Scripts\Desktop\Lista_Processos\"

$Listas = Get-Content $Scriptpath\lista.txt
New-Item -type file -force $Scriptpath\Resultado.log

ForEach ($Desktop in $Listas) {

    #Write-Host $Desktop
    $TestServico = Get-Process -ComputerName ES00009172 -Name "AzInfoProtection" | Select-Object ProcessName
    
    "$Desktop; $TestServico" | Out-File $Scriptpath\Resultado.log -Encoding ascii -Append

}




