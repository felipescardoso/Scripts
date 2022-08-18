
function Initialize-Script {
	param ([Boolean]$CreatePublicFolder = $true)
	<#
		Inicia variáveis e faz quaisquer ações que se façam necessárias ao início do script.
		Essa função foi pensada para ser a primeira a ser executada em todo script, de forma que prepare o ambiente para a execução.
		Deve-se colocar variáveis globais aqui e evitar colocar funções específicas, estas devem ser postas no corpo principal do script.

		Parâmetros:
			@Optional, @Boolean: $CheckPublicFolder : Definido como Default: $true iniciamente para realizar a verificação e criação da pasta criada em C:\User\Public, somente deve ser alterado para $false caso o pacote seja para
			o Portal Aplicações Petrobras, pois o arquivo ponteiro já irá realizar essa verificação.
		
		Retorno:
			[SEM RETORNO]
	#>

	
		
	#Define os valores iniciais das variáveis globais
	$global:objShell = New-Object -ComObject WScript.Shell
	$global:ComputersystemObj = Get-WmiObject -Namespace root\CIMV2 -Class Win32_ComputerSystem
	$global:ScriptPath = [System.AppDomain]::CurrentDomain.BaseDirectory
	$global:DataLog = (Get-Date).tostring("dd-MM-yyyy")
	$global:HoraLog = (Get-Date).tostring("HHmmss")
	$global:userkey = """$Username"""
	$global:Computername = $Env:COMPUTERNAME
	
	#DEFINA AQUI O NOME DO SOFTWARE
	$global:SoftwareName = "TESTE-ENVIO"

	#DEFINA AQUI A VERSÃO DO SOFTWARE
	$global:SoftwareVersion = "1.0"

	#DEFINA AQUI O ID DO SOFTWARE (NO CASO DE SER USADO NO APLICAÇÕES PETROBRAS)
	#$global:appID = 15732

	$global:Software = "$SoftwareName $SoftwareVersion"
	$global:SoftwarePublicFolder = "C:\Users\Public\" + $Software.Replace(" ", "_")
	#$global:LogFileLocal = ("$Env:WINDIR\logs\" + $SoftwareName + "_" + $SoftwareVersion + "_" + $DataLog + ".log") #Local em C:\windows\logs\software_versao.log
	$global:LogFileLocal = ("C:\TEMP\" + $SoftwareName + "_" + $SoftwareVersion + "_" + $DataLog + ".log") #Local em C:\windows\logs\software_versao.log
	
    if ($CreatePublicFolder) {
		#Cria um diretório em 'C:\Users\Public\' para colocar arquivos temporários locais em caso de necessidade, antes verifica se o diretório já existe e nesse caso o exclui
		If (Test-Path $SoftwarePublicFolder) {
			Remove-Item -Path $SoftwarePublicFolder -Force -Recurse -ErrorAction SilentlyContinue 
			Start-Sleep -Seconds 1
		}
		
		New-Item -Type Directory -Force -Path $SoftwarePublicFolder
		Start-Sleep -Seconds 1
	}
	#Copia os arquivos necessários para fazer a verificação de software corporativo no Aplicações Petrobras
	
}

function Gravar-Log ([String]$LOG_txt) {
<#Exemplo de execução:
Gravar-Log -LOG_txt "Atualizacao realizada"
#>

$global:HoraLog = (Get-Date).tostring("HH:mm:ss")# Atualização da hora para uso no LOG
Add-Content -Path $global:LogFileLocal -Value "$global:DataLog - $global:HoraLog : $LOG_txt" -Force -Encoding Unicode
}

Initialize-Script

Gravar-Log -LOG_txt "EXECUTADO COM SUCESSO"

