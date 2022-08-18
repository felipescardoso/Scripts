#Descrição: Script para coletar informações sobrea as tarefas de manutenção.


If ($env:COMPUTERNAME -eq 'S6006AS1430') {
    $SQLInstance = 'S6006CL49'
    $Database = 'CM_CAS'
    $SiteCode = $Database.Substring(3)
}
Elseif ($env:COMPUTERNAME -eq 'S602DAS313') {
    $SQLInstance = 'S602DAS313'
    $Database = 'CM_DSP'
    $SiteCode = $Database.Substring(3)
}
ElseIf ($env:COMPUTERNAME -eq 'SAUSCCM01') {
    $SQLInstance = 'SAUSCCM01'
    $Database = 'CM_CAU'
    $SiteCode = $Database.Substring(3)
}
ElseIf ($env:COMPUTERNAME -eq 'NPAA5970') {
    $SQLInstance = 'NPAA5970'
    $Database = 'CM_TES'
    $SiteCode = $Database.Substring(3)
}

$ProviderMachineName = $env:COMPUTERNAME # SMS Provider machine name

Write-Host "Equipamento $ProviderMachineName identificado" -ForegroundColor Green

$initParams = @{ }
if ((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
Set-Location "$($SiteCode):\" @initParams



#########################################################################################
#FUNÇÕES

#Função para data e hora
Function Data-Hora {
    $global:Datafinal = (Get-Date).tostring("dd-MM-yyyy") + "_" + (Get-Date).tostring("HH.mm.ss")
}

#Função para coletar Tarefas de manutenção ativas
Function GetTasks{
    $Tratadasg = @()
    $Tasksg = Get-CMSiteMaintenanceTask | where Enabled -eq $true
    foreach($Taskg IN $Tasksg){
        $Tratadasg += New-Object -TypeName psobject -Property @{SiteCode = $Taskg.SiteCode; TaskName = $Taskg.TaskName}
        $Taskg | Out-File -Append "G:\BACKUP\TarefasAtivadasDetalhadasPos.txt"
    }
    $Output = $Tratadasg | ConvertTo-CSV  -NoTypeInformation
    Add-Content -Path "G:\BACKUP\TarefasAtivadasDetalhadasPos.csv" -Value $Output
    Copy-Item -Path "G:\BACKUP\TarefasAtivadasDetalhadasPos.csv" -Destination ("G:\BACKUP\TarefasAtivadasDetalhadasPos_"+ $global:Datafinal + ".csv")
}

#Função para coletar DESATIVAR as Tarefas de manutenção
Function DisableTasks{
    $Tratadasd = @()
    $Tasksd = Get-CMSiteMaintenanceTask | where Enabled -eq $true
    foreach($Taskd IN $Tasksd){
        Set-CMSiteMaintenanceTask -Name $Taskd.TaskName -SiteCode $Taskd.SiteCode -Enabled $false
        Write-host "Desativando a tarefa " ($Taskd.TaskName).tostring()
    }
}

#Função para coletar ATIVAR as Tarefas de manutenção, com base no backup realizado pela GetTask
Function Enabletasks{
    $Tratadase = @()
    $Taskse = Import-Csv -Path "G:\BACKUP\TarefasAtivadasDetalhadasPos.csv"
    foreach($Taske IN $Taskse){
        Set-CMSiteMaintenanceTask -Name $Taske.TaskName -SiteCode $Taske.SiteCode -Enabled $true
        Write-host "Ativando a tarefa " ($Taske.TaskName).tostring()
    }
}



GetTasks

#DisableTasks

#Enabletasks