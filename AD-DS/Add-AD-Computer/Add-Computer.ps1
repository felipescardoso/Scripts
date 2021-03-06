<#Descrição:
Criador por: Felipe Santos Cardoso
GitHub: https://github.com/felipescardoso
Função: Incluir equipamento no AD. | Include equipment in AD
Version: 1.5	| 18/05/2019
#>

#Permitir execução | Allow execution
[Environment]::SetEnvironmentVariable("SEE_MASK_NOZONECHECKS","1","Machine")

#Objeto pop-up
$wshell = New-Object -ComObject Wscript.Shell

#Definir o script path (local de execução do script) | save the script path
#$caminho = [System.AppDomain]::CurrentDomain.BaseDirectory 
$caminho = ".\"

#Arquivo de configuração (nome do domínio, OU) | Configuration file (domain name, OU)
$arquivo = "$caminho\config.ini"

#Identificar o usuário logado e  conta | Identify the logged-in user and account
$ComputersystemObj = Get-WmiObject -ComputerName localhost -Class Win32_computersystem
$usuario = $ComputersystemObj.UserName
$Conta = $ComputersystemObj.Name

#Identificar Domínio no arquivo conf.ini | Identify Domain in conf.ini file
$dominiofull = Get-ChildItem $arquivo | Select-String -Pattern dominioAD
$dominio1,$dominio2 = $dominiofull -split "AD:"
$dominio = $dominio2

#Identificar Controlador de domínio no arquivo conf.ini | Identify Domain Controller in conf.ini file
$servidorfull = Get-ChildItem $arquivo | Select-String -Pattern servidorAD
$servidor1,$servidor2 = $servidorfull -split "AD:"
if ($servidorfull = ""){
	$exec = "1"
}
	else{
		$servidor1,$servidor2 = $servidorfull -split "AD:"
		$servidor = $servidor2
		}

#Identificar OU no arquivo conf.ini | identify OU in the conf.ini file
$OUfull = Get-ChildItem $arquivo | Select-String -Pattern ouAD
$ou1,$ou2 = $OUfull -split "AD:"
$OU = $ou2

if ($exec = "1"){
#Inclui o objeto no domínio padrão | Includes the object in the default domain
Add-Computer -DomainName $dominio -OUPath $OU -PassThru -Credential $usuario
}
	else{
	#Inclui o objeto no domínio específico | #Includes the object in the specific domain
	Add-Computer -DomainName $dominio -server "$dominio\$servidor" -OUPath $OU -PassThru -Credential $usuario
	}
#Popup de conclusão | PopUP finish
$wshell.Popup("Conta $Conta incluída. Reinicie o equipamento",0,"Add-Computer 1.5",0x40)