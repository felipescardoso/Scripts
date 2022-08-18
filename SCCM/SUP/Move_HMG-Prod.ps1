<# CONTROLE DE VERSÃO #######################################
    Versão 1.0
    Descricao: Alteracao dos alvos de homologacao para producao. O mesmo devera ser executado na segunda-feira da semana da 3º terça-feira.
    10/09/2020 - MJ8U
#>

Remove-Variable * -ErrorAction SilentlyContinue
Set-Location c:
#Define o nome do servidor, base para conexão e sitecode
$SQLInstance = 'RDXSRVAZ04'
$Database = 'CM_RDX'
$SiteCode = $Database.Substring(3)

$ProviderMachineName = "RDXSRVAZ04" # SMS Provider machine name

#ORIGINAL E TESTES
<#
#$Query = "select top 1 LEFT(AssignmentName,12) from vSMS_UpdateDeploymentSummary where AssignmentName like '" + "TAC " + (Get-Date).ToString('yyyyMM') + "%';"
#$Query = "SELECT TOP 1 LEFT(AssignmentName,12) FROM vSMS_UpdateDeploymentSummary WHERE AssignmentName LIKE '" + "TAC " + (Get-Date).ToString('yyyyMM') + "%' and AssignmentName not like '%Emergencial%';"
#Identificacao dos nomes dos deployes
#$Query = "SELECT TOP 1 LEFT(AssignmentName,12) FROM vSMS_UpdateDeploymentSummary WHERE CollectionName = 'SUP_HMG_BAIXA_INSTALA_NAO_REINICIA' AND AssignmentName LIKE '" + "SUP_ADR_APPS%'" + (Get-Date).ToString('yyyy-MM') + "%' OR AssignmentName LIKE '" + "SUP_ADR_WINDOWS%" + (Get-Date).ToString('yyyy-MM') + "%'`;"
#>
#Query para consulta do nome do deployment e do ID
$Query = "SELECT AssignmentID,AssignmentName `
          FROM vSMS_UpdateGroupAssignment `
          WHERE CollectionName = 'SUP_HMG_BAIXA_INSTALA_NAO_REINICIA' `
	           and (AssignmentName LIKE 'SUP_ADR_APPS%' `
		       or AssignmentName LIKE 'SUP_ADR_WINDOWS%')"
          #group by AssignmentName

$ResultadoQuery = Invoke-Sqlcmd -Query $Query -ServerInstance $SQLInstance -Database $Database

$SUGDeployNames = @($ResultadoQuery)

#-------------------------------------------------------------------

Function Conecta{
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

#Segunda antes da terceira terca-feira. Ou primeira segunda-feira apos a segunda terca-feira
Function ProducaoServidores{
#========================================================================================================================================================
#--------------------------------------------------------------PRODUCAO-------------------------------------------------------------------------------
    #========================================================================================================================================================
    #PRODUCAO "SUP_ADR_WINDOWS_SERVERS <DATA>", "SUP_ADR_WINDOWS <DATA>", "SUP_ADR_APPS ..."
    
    Write-Host "Collection de homologacao: SUP_HMG_BAIXA_INSTALA_NAO_REINICIA"
    Write-Host "Collection de producao:    SUP_PROD_BAIXA_INSTALA_NAO_REINICIA`n"
    
    $SUGDeployNames | ForEach-Object {
        $SUGDeployName = $_
        $SUGNAme = (Get-CMDeployment -CollectionName SUP_HMG_BAIXA_INSTALA_NAO_REINICIA | `
                    Where-Object AssignmentID -EQ $SUGDeployName.AssignmentID).ApplicationName #| Select-Object -Property ApplicationName
        Write-Host "Alterando o alvo abaixo para producao: "
        Write-host "SUG:" $SUGName -ForegroundColor Green
        Write-host "Deploy:" $SUGDeployName.AssignmentName -ForegroundColor Green
        Write-host "IDDeploy:" $SUGDeployName.AssignmentID -ForegroundColor Green
        #Write-Host ""
        #Set-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $SUGName -CollectionName SUP_HMG_BAIXA_INSTALA_NAO_REINICIA -DeploymentName ($SUGName + ' - Baixa-Instala-Boota-24H').tostring()
        Set-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $SUGName -CollectionName SUP_PROD_BAIXA_INSTALA_NAO_REINICIA -DeploymentName $SUGDeployName.AssignmentName
        
    }

}


#CONECTAR AO SITE ESPECÍFICO #############################################
Conecta

#PASSO DE PRODUÇÃO SERVIDORES ############################################
#ProducaoServidores

#Set-location c: