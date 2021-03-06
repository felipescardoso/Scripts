
function Initialize-Script {
	param ([Boolean]$CreatePublicFolder = $true)

	#Define os valores iniciais das variáveis globais
	$global:objShell = New-Object -ComObject WScript.Shell
	$global:ComputersystemObj = Get-WmiObject -Namespace root\CIMV2 -Class Win32_ComputerSystem
	$global:DataLog = (Get-Date).tostring("dd-MM-yyyy")
	$global:HoraLog = (Get-Date).tostring("HHmmss")
	$global:Computername = $Env:COMPUTERNAME
	$global:TEMP = "$Env:HOMEDRIVE\TEMP"
	$global:programfiles = "$Env:programfiles"
	$global:programfilesx86 = "$Env:programfiles (x86)"
	$global:Software = "$SoftwareName $SoftwareVersion"
	#$global:LogFileLocal = ("$Env:WINDIR\logs\" + $SoftwareName + "_" + $SoftwareVersion + ".log") #Local em C:\windows\logs\software_versao.log
	$global:LogFileLocal = ("$global:ScriptPath\Logs\" + "COLLECTION_INSERT-Membros-DIRECT-SAIDA" + "_" + $global:DataLog + "_" + $global:HoraLog +".csv")
    Set-Location c:\
}

function Gravar-Log ([String]$LOG_txt) {
$global:HoraLog = (Get-Date).tostring("HH:mm:ss")# Atualização da hora para uso no LOG
Add-Content -Path $global:LogFileLocal -Value "$global:DataLog - $global:HoraLog ; $LOG_txt" -Force
}

Function SCCMConectar {
#Função para conexão ao CAS
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "CAS:" # Set the current location to be the site code.

}

function Get-ScriptDirectory {
    if ($psise) {
        Split-Path $psise.CurrentFile.FullPath
    }
    else {
        $global:PSScriptRoot
    }
}


Initialize-Script

#Arquivo de entrada
#$global:ScriptPath = Get-ScriptDirectory
$global:ScriptPath = ".\"
$codigos = Get-Content -Path ($global:ScriptPath + "\COLLECTION_INSERT-Membros-DIRECT-INPUT.txt")
$CodTotal = $codigos.Count
$Cont = 0


$CollectionNameDestino = "Imagem Corporativa Windows 10 - Upgrade"
$CollectionNameGet = "All Workstation"


#Cria o arquivo de log
Add-Content -Path $global:LogFileLocal -Value "EVOL;DATA/HORA;HOSTNAME;COLLECTION;STATUS" -Force


#CONECTAR CAS
SCCMConectar

foreach ($objeto in $codigos) {
	$Cont++	
    
    #Testa se o objeto existe no SCCM
	$TesteObjeto = Get-CMDevice -CollectionName $CollectionNameGet -name $Objeto
    if ($TesteObjeto -ne $NULL ) {
        
        #Testa se o Objeto já existe no Destino
        $TestObjetoDestino = Get-CMCollectionMember -CollectionName $CollectionNameDestino | Select-Object name | Where-Object {$_.name -eq "$objeto"}	
        if ($TestObjetoDestino -eq $NULL ) {
            Add-CMDeviceCollectionDirectMembershipRule -CollectionName $CollectionNameDestino -ResourceId $TesteObjeto.ResourceID
            Gravar-Log -LOG_txt "$Cont-$CodTotal;$Objeto;$CollectionNameDestino;INCLUIDO"

            }else{Gravar-Log -LOG_txt "$Cont-$CodTotal;$Objeto;$CollectionNameDestino;JA INCLUIDO"}
        

    }else{Gravar-Log -LOG_txt "$Cont-$CodTotal;$Objeto;$CollectionNameDestino;NAO LOCALIZADO"}

	Start-Sleep -Seconds 2
	
}
Gravar-Log -LOG_txt "FIM------------------------------------"









