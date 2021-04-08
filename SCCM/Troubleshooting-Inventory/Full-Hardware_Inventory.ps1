<#Descrição: 
1 - Remove o objeto WMI do hardware inventory;
2 - Força o inventário de hardware Full do equipamento.

#>

$DelInvSUP = Get-WmiObject -Class "InventoryActionStatus" -ComputerName .  -Namespace "ROOT\ccm\InvAgt"  
$DelInvSUP | ForEach-Object  {
    If ($_.InventoryActionID -EQ "{00000000-0000-0000-0000-000000000001}"){
        $_ | Remove-WmiObject
    }
}

Start-Sleep -Seconds 4
Invoke-WMIMethod -ComputerName . -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"