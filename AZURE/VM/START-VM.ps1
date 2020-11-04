#Script para iniciar a VM e conectar via RDP
#versão: 1.2

#Necessário o Módelo AzureRM
#Install-Module -Name AzureRM -AllowClobber
Remove-Variable * -ErrorAction SilentlyContinue

#Login-AzAccount
Login-AzureRmAccount

Write-Host "Lista dos Resouce Grups" -ForegroundColor Green
Write-Host "RG001" -ForegroundColor Green
Write-Host "-----------------------------------" -ForegroundColor Green
#$RGName = "RG-SEDE"#<< Resorce Group Name

$RGName = Read-Host "Informe o RG"
$ALLVM = Get-AzureRmVM -ResourceGroupName $RGName | Select-Object *

Write-Host "-----------------------------------" -ForegroundColor Green
Write-Host "Lista das VMs do RG:"  -ForegroundColor Green
Write-Host $ALLVM.Name -ForegroundColor Cyan
Write-Host " "

$VMStart = Read-Host "Iniciar todas VM ? (y)"

if ($VMStart -ne "y"){

    #Declaring variables
    Write-Host "LISTA DOS SERVIDORES APROVISIONADOS PARA RG-SEDE" -ForegroundColor Green
    Write-Host "S001DC01" -ForegroundColor Green
    Write-Host "++++++++++++++++++++++++++++++" -ForegroundColor Green
    $VMName = Read-Host "Informe o Servidor"
    $RGNameIPPublic = $VMName + "-ip"

    #Start VM
    Write-Host "Iniciando VM: " $VMName -ForegroundColor Green
    start-azurermvm -ResourceGroupName $RGName -Name $VMName -ErrorAction SilentlyContinue -InformationAction SilentlyContinue | ft Status,StartTime,EndTime,Error
    $StatusVMRunning = Get-AzureRmVM -ResourceGroupName $RGName -Status | Select-Object ResourceGroupName,Name,Location, @{ label = “VMStatus”; Expression = { $_.PowerState } } 



    #Waiting for the VM to start
    do {
    $cont++
    start-sleep -Milliseconds 1000
    $StatusVMRunning = Get-AzureRmVM -ResourceGroupName $RGName -Status | Select-Object ResourceGroupName,Name,Location, @{ label = “VMStatus”; Expression = { $_.PowerState } } 
    start-sleep -Milliseconds 1000
    Write-Host "Aguardando VM Iniciar: Tentativa " $cont  -ForegroundColor Cyan

    }until ($StatusVMRunning.VMStatus -eq "VM running")
    Write-Host "VM Iniciado com sucesso " $VMName -ForegroundColor Cyan


    

    #Get public IP address
    Start-Sleep -Seconds 5
    $publicIp = Get-AzureRmPublicIpAddress -ResourceGroupName $RGName -Name $RGNameIPPublic
    $IPMSTSC = ($publicIp.IpAddress)
    
    #Start RDP
    Start-Process c:\windows\system32\mstsc.exe -ArgumentList "/V:$IPMSTSC"

    #stop-azurermvm -ResourceGroupName $RGName -Name $VMName
}

    else{
        
        foreach($VMfor in $ALLVM ){
            $VMName = $VMfor.name
            #Start VM
            Write-Host "Iniciando VM: " $VMName -ForegroundColor Green
            start-azurermvm -ResourceGroupName $RGName -Name $VMName -ErrorAction SilentlyContinue -InformationAction SilentlyContinue | ft Status,StartTime,EndTime,Error
            $StatusVMRunning = Get-AzureRmVM -ResourceGroupName $RGName -Status | Select-Object ResourceGroupName,Name,Location, @{ label = “VMStatus”; Expression = { $_.PowerState } } 
            


            #Waiting for the VM to start
            do {
            $cont++
            start-sleep -Milliseconds 1000
            $StatusVMRunning = Get-AzureRmVM -ResourceGroupName $RGName -Status | Select-Object ResourceGroupName,Name,Location, @{ label = “VMStatus”; Expression = { $_.PowerState } } 
            start-sleep -Milliseconds 1000
            Write-Host "Aguardando VM Iniciar: Tentativa " $cont  -ForegroundColor Cyan

            }until ($StatusVMRunning.VMStatus -eq "VM running")
            Write-Host "VM Iniciado com sucesso " $VMName -ForegroundColor Cyan


            $VMStartRDP = Read-Host "$VMName - Deseja iniciar o RDP ? (y)"
            if ($VMStartRDP -eq "y"){
                #Get public IP address
                Start-Sleep -Seconds 10
                $RGNameIPPublic = $VMName + "-ip"
                $publicIp = Get-AzureRmPublicIpAddress -ResourceGroupName $RGName -Name $RGNameIPPublic
                $IPMSTSC = ($publicIp.IpAddress)


                #Start RDP
                Start-Process c:\windows\system32\mstsc.exe -ArgumentList "/V:$IPMSTSC"
            }

        }
    }

