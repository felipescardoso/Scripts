<#
Scritp Valida se o equipamento está ligado
Criado Por: Felipe Cardoso $Trabalhando no spread$
#>
cls
<#Importar Componente do AD para o PowerShell-------------------------------------------------------------#>
Import-Module ActiveDirectory
$global:DataLog = (Get-Date).tostring("dd-MM-yyyy")
$global:HoraLog = (Get-Date).tostring("HHmmss")
<#FIM-----------------------------------------------------------------------------------------------------#>

<#FUNCÕES-----------------------------------------------------------------------------------------------------#>
function Teste-Conexao ([String]$codigo)  {
	$global:TestConexao = ""
	$global:TestConexao = Test-Connection $codigo -Count 1 -ErrorAction SilentlyContinue | Select-Object *
	
	if ($TestConexao -ne $null ){
		$codigo
		$global:IPHost = ($global:TestConexao).IPV4Address
		$global:NomeReverso = [System.Net.Dns]::gethostentry($TestConexao.IPV4Address)
		$nic_configuration = gwmi -computer $codigo  -class "win32_networkadapterconfiguration" | Where-Object {$_.defaultIPGateway -ne $null}
		$global:IP = $nic_configuration.ipaddress
		$global:MAC_Address = $nic_configuration.MACAddress
		$global:SubnetMask = $nic_configuration.ipsubnet
				
		If ($codigo -eq ($NomeReverso.HostName).Split(".")[0]) {
		    ($NomeReverso.HostName).Split(".")[0]
			$global:TestConexaoFinal = 0 #LIGADO
	    }
		Else { # #ERRO DE DNS
			$global:TestConexaoFinal = "DNS_ERRO"
			#$global:TestConexaoFinal = ($NomeReverso.HostName).Split(".")[0]
			#($NomeReverso.HostName).Split(".")[0]	
		}
		
		
	}
	Else{$global:TestConexaoFinal = 1} #DESLIGADO
	
	#Return 
}
<#FIM-----------------------------------------------------------------------------------------------------------#>

<#Determina o caminho corrente----------------------------------------------------------------------------#>
#$caminho = [System.AppDomain]::CurrentDomain.BaseDirectory#>
$caminho = "C:\Users\GNFK\Desktop\SMDI\0-Scripts\Powershell\Scripts\Ping\Ping"

<#FIM-----------------------------------------------------------------------------------------------------#>

<#Leitura dos equipamentos--------------------------------------------------------------------------------#>
$codigo = Get-Content $caminho\ping_codigos.txt
<#FIM-----------------------------------------------------------------------------------------------------#>

<#Leitura do Domínio--------------------------------------------------------------------------------------#>
$dominioad = Get-Content $caminho\dominio.txt
<#FIM-----------------------------------------------------------------------------------------------------#>

<#Cria o arquivo de saída vazio----------------------------------------------------------------------------#>
$HOSTNAME = "HOSTNAME"
$STATUS = "STATUS"
$ATIVO = "ATIVO"
$IP = "IP"
$REDE = "REDE"
$SO = "SO"
$DOMINIO = "DOMINIO"
$OU = "OU"

$ArquivoSaida = New-Item -type file -force ("$caminho\Resultado\Resultado_" + $global:DataLog +".csv")
"$HOSTNAME; $STATUS; $ATIVO; $IP; $REDE; $SO; $DOMINIO; $OU" | Out-File  $ArquivoSaida -Encoding ASCII -append
<#FIM-----------------------------------------------------------------------------------------------------#>


$contador = 0
foreach ($codigos in $codigo)
{   
$contador++

#Testar se a conta existe no AD
$checkAd = ""
IF (Get-ADComputer -Server petrobras.biz -identity $codigos){
	$checkAd = "petrobras.biz"
}
if(Get-ADComputer -Server transp.biz -identity $codigos){
	$checkAd = "transp.biz"
}Else{$checkAd = "N/A"}



#Execute caso a conta exista
if ($checkAd -ne "")
	{		
		#if (Test-Connection $codigos -Count 1 -ea 0 -Quiet)
		Teste-Conexao $codigos
		if ($global:TestConexaoFinal -eq 0)
		<#Equipamento Ligado--------------------------------------------------------------------------------------#>
			{	
			$HOSTNAME = $codigos
			$STATUS = ("Ligado - " + $global:TestConexaoFinal )
			$ATIVO = Get-ADComputer -Server $checkAd -identity $codigos  | Select-Object -ExpandProperty Enabled
			$IP = $global:IPHost
			$REDE = $global:SubnetMask
			$SO = Get-ADComputer -Server $checkAd -identity $codigos -Property OperatingSystem | Select-Object -ExpandProperty OperatingSystem
			$OU = Get-ADComputer -Server $checkAd -identity $codigos | Select-Object -ExpandProperty DistinguishedName
			#Grava os valores no arquivo de saída
			"$HOSTNAME; $STATUS; $ATIVO; $IP; $REDE; $SO; $checkAd; $OU" | Out-File  $ArquivoSaida -Encoding ASCII -append
			<#FIM - Equipamento LIgado-----------------------------------------------------------------------------------#>	
			$ATIVO = ""
			$IP = ""
			$REDE = ""
			$SO = ""
			$OU = ""
			}
			else
			<#Equipamento Desligado--------------------------------------------------------------------------------#>
			{	
			$HOSTNAME = $codigos
			$STATUS = ("Desligado - " + $global:TestConexaoFinal )
			$ATIVO = Get-ADComputer -Server $checkAd -identity $codigos  | Select-Object -ExpandProperty Enabled
			$IP = $global:IPHost
			$REDE = $global:SubnetMask
			$SO = Get-ADComputer -Server $checkAd -identity $codigos -Property OperatingSystem | Select-Object -ExpandProperty OperatingSystem
			$OU = Get-ADComputer -Server $checkAd -identity $codigos | Select-Object -ExpandProperty DistinguishedName
			#Grava os valores no arquivo de saída
			"$HOSTNAME; $STATUS; $ATIVO; $IP; $REDE; $SO; $checkAd; $OU" | Out-File  $ArquivoSaida -Encoding ASCII -append
			$ATIVO = ""
			$IP = ""
			$REDE = ""
			$SO = ""
			$OU = ""
			
			<#FIM - Equipamento Desligado-------------------------------------------------------------------------------#>	
			
			}
	}
	else
		{
		<#Equipamento Não existe-------------------------------------------------------------------------------#>	
		$HOSTNAME = $codigos
		$STATUS = ("Inexistente - " + $global:TestConexaoFinal)
		$ATIVO = "-" 
		$IP = "-"
		$REDE = "-"
		$SO = "-"
		$OU = "-"
		$DOMINIO = "-"
		#Grava os valores no arquivo de saída
		"$HOSTNAME; $STATUS; $ATIVO; $IP; $SO; $DOMINIO; $OU" | Out-File  $ArquivoSaida -Encoding ASCII -append
		$ATIVO = ""
		$IP = ""
		$REDE = ""
		$SO = ""
		$OU = ""
		<#FIM - Equipamento Não existe--------------------------------------------------------------------------#>	
		}

}


<#Gera mensage de Conclusão-------------------------------------------------------------------------------#>
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Consulta Concluída. Favor verificar o relatório.",0,"Check AD e Ping",0x40)
<#FIM - Gera mensage de Conclusão-------------------------- ---------------------------------------------------#>

