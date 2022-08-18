Remove-Variable * -ErrorAction SilentlyContinue
Set-Location c:
#Define o nome do servidor, base para conexão e sitecode
$SQLInstance = 'RDXSRVAZ04'
$Database = 'CM_RDX'
$SiteCode = $Database.Substring(3)
$ProviderMachineName = "RDXSRVAZ04" # SMS Provider machine name
Function Conecta {
    Set-Location c:
    
    # Customizations
    $initParams = @{}
    #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
    #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

    # Do not change anything below this line

    # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams
    Write-Host "Realizado conexão ao site $SiteCode" -ForegroundColor Cyan 
}
Conecta

#############################################
# SUP | REMOVER KB DO SOFTWARE UPDATE GROUP ################################################################################

#$TACs = "TAC 20200115"
#$KBs = "4532936","4532933","4534976","4535103","4535105","4486081","4486153","4486105","4532934","4503548","4532935","4535102","4534978","4534977","4486129","4535104"
#Set-CMSoftwareUpdateDeploymentPackage -Name $TACs -RefreshDistributionPoint

$contador = $Null
#Remove KB dos Software Update Group
foreach ($KB in $KBs){
    $contador += 1
    $CIID = Get-CMSoftwareUpdate -ArticleId $KB -Fast
    Remove-CMSoftwareUpdateFromGroup -SoftwareUpdateGroupName "$TACs" -SoftwareUpdateId $CIID.CI_ID  -Force
    write-host $TACs  "KB$KB" "-" "CI_ID" $CIID.CI_ID
    Write-Host $contador "/" $KBs.count -ForegroundColor red
} 


get-cmsoftwareupdate -


#############################################
# DISTRIBUIÇÃO | CRIAR AGENDAMENTOS  ################################################################################

$Schedule = new-cmschedule -start (Get-Date).AddMinutes(30) -Nonrecurring
$Deployment = Get-CMPackageDeployment -DeploymentId CAS00203CB
Set-CMPackageDeployment -PackageId $Deployment.PackageID -StandardProgramName $Deployment.ProgramName -CollectionId $Deployment.CollectionID -Schedule $Schedule -ScheduleEvent AsSoonAsPossible



#######################################################################################################################################
#SUP - Remover Superseded e Expired patches de SUGs e Package(com refresh)#############################################
Get-CMSoftwareUpdateGroup | Select-Object LocalizedDisplayName,NumberOfExpiredUpdates
 
Set-CMSoftwareUpdateGroup -Name "TAC 20200415_2" -ClearExpiredSoftwareUpdate #-ClearSupersededSoftwareUpdate 

Set-CMSoftwareUpdateDeploymentPackage -Name "TAC 20200415_2" -RemoveExpired -RefreshDistributionPoint #-RemoveSuperseded



#######################################################################################################################################
#Full Hardware Inventory Deleting the WMI instance #############################################
#Remover
Get-WmiObject -Namespace root\ccm\invagt -Class inventoryactionstatus | Where-Object {$_.inventoryactionid -eq "{00000000-0000-0000-0000-000000000001}"} | Remove-WmiObject

Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}" 
#LOG InventoryAgent.log