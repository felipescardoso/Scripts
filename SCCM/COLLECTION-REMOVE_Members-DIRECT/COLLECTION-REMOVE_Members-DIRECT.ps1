
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
	$global:LogFileLocal = ("$global:ScriptPath\" + "COLLECTION-REMOVE_Members_OUTPUT" + "_" + $global:DataLog + ".log")
}

function Gravar-Log ([String]$LOG_txt) {
$global:HoraLog = (Get-Date).tostring("HH:mm:ss")# Atualização da hora para uso no LOG
Add-Content -Path $global:LogFileLocal -Value "$global:DataLog - $global:HoraLog ; $LOG_txt" -Force
}

#Função para conexão ao CAS
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
Set-Location "CAS:" # Set the current location to be the site code.
Initialize-Script

#Arquivo de entrada
$global:ScriptPath = ".\"
$codigos = Get-Content $ScriptPath\COLLECTION-REMOVE_Members_INPUT.txt

#Collection name
$CollectionName = "Imagem Corporativa Windows 10 - Upgrade - Required ASAP"

#Cria o arquivo de log
Add-Content -Path $global:LogFileLocal -Value "DATA/HORA;HOSTNAME;COLLECTION;STATUS" -Force

foreach ($objeto in $codigos) {
	
	#Testa se o objeto está na collection
	$TesteObjeto = Get-CMDevice -CollectionName $CollectionName -name $Objeto
	if ($TesteObjeto -ne $NULL ) {
	  
	    Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $CollectionName -ResourceName $Objeto -Force
		Gravar-Log -LOG_txt "$Objeto;$CollectionName;REMOVIDO"

	}
	   else{
	        Gravar-Log -LOG_txt "$Objeto;$CollectionName;NAO LOCALIZADO"

			
	}
	Start-Sleep -Seconds 2
	
}
Gravar-Log -LOG_txt "FIM------------------------------------"









