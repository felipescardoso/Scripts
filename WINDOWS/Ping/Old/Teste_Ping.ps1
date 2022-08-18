<#
Scritp Valida se o equipamento está ligado
#>
cls

$wshell = New-Object -ComObject Wscript.Shell

<#Testa se o RSAT está instalado--------------------------------------------------------------------------#>
$Teste = Test-Path C:\Windows\SysWOW64
<#FIM - Testa se o RSAT está instalado--------------------------------------------------------------------#>

if ($Teste -eq "True")
{

	<#Determina o caminho corrente----------------------------------------------------------------------------#>
	<#$caminho = [System.AppDomain]::CurrentDomain.BaseDirectory#>
	$caminho = "D:\Usuarios\gnfk\Desktop\SUPORTE TIC\2 - Script\PowerShell\Ping"
	<#FIM-----------------------------------------------------------------------------------------------------#>

	<#Leitura dos equipamentos--------------------------------------------------------------------------------#>
	$servers = Get-Content $caminho\ping_codigos.txt
	<#FIM-----------------------------------------------------------------------------------------------------#>

	<#Importar Componente do AD para o PowerShell-------------------------------------------------------------#>
	Import-Module ActiveDirectory
	<#FIM-----------------------------------------------------------------------------------------------------#>


	$collection = $()
	foreach ($server in $servers)
	{    
		$status = @{ "1-Codigo" = $server }
		<#Testar se o equipamento está ligado - PING----------------------------------------------------------#>
		if (Test-Connection $server -Count 1 -ea 0 -Quiet)
		{	
			$status["Resultado"] = "Ligado"    
		}     
		else
		{	
			$status["Resultado"] = "Desligado"
		}
		<#FIM -Testar se o equipamento está ligado - PING------------------------------------------------------#>	
		
		<#Testar em qual Domínio e OU a conta está ------------------------------------------------------------#>
		try 
		{
			get-ADComputer -Server petrobras.biz $server -ErrorAction stop | Out-Null
			$ou =  Get-ADComputer -Server petrobras.biz -identity $server -properties 'DistinguishedName'
			$status["AD"] = "Petrobras.biz"
			$status["OU"] = $OU
				
		}    
		catch 
		{    
			try
			{
			get-ADComputer -Server "transp.biz" $server -ErrorAction stop | Out-Null
			$ou =  Get-ADComputer -Server transp.biz -identity $server -properties 'DistinguishedName'
			$status["AD"] = "Transp.biz"
			$status["OU"] = $OU
			}
			catch
			{
			$status["AD"] = "Fora do Dominio"    
			$status["OU"] = "Fora do Dominio"
			}
			
		}
		<#FIM - Testar em qual Domínio e OU a conta está ---------------------------------------------------#>
		
		<#Gera o Arquivo e Grava as informações--------- ---------------------------------------------------#>
		New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
		$collection += $serverStatus
		$collection | export-csv $caminho\Resultado.csv -NoTypeInformation
		<#FIM - Gera o Arquivo e Grava as informações--------------------------------------------------------#>
	}
}
Else
{
	$wshell.Popup("RSAT não Instalado ou Ativado!",0,"Check AD e Ping",0x0)
}

	<#Gera mensage de Conclusão-------------------------- ---------------------------------------------------#>
	$wshell.Popup("Consulta Concluída. Favor verificar o relatório.",0,"Check AD e Ping",0x0)
	<#FIM - Gera mensage de Conclusão-------------------------- ---------------------------------------------------#>