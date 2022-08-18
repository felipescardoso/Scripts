<#
Scritp Valida se o equipamento está ligado
Criado Por: Felipe Cardoso $Trabalhando no spread$
#>

<#Importar Componente do AD para o PowerShell-------------------------------------------------------------#>
Import-Module ActiveDirectory
<#FIM-----------------------------------------------------------------------------------------------------#>



<#Determina o caminho corrente----------------------------------------------------------------------------#>
$caminho = [System.AppDomain]::CurrentDomain.BaseDirectory#>
#$caminho = "D:\Usuarios\gnfk\Desktop\SUPORTE TIC\2 - Script\PowerShell\Ping\Ping"
<#FIM-----------------------------------------------------------------------------------------------------#>

<#Leitura dos equipamentos--------------------------------------------------------------------------------#>
$servers = Get-Content $caminho\ping_codigos.txt
<#FIM-----------------------------------------------------------------------------------------------------#>

<#Leitura do Domínio--------------------------------------------------------------------------------------#>
$domínio = Get-Content $caminho\dominio.txt
<#FIM-----------------------------------------------------------------------------------------------------#>


$collection = $()
foreach ($server in $servers)
{    
	$status = @{ "1-Codigo" = $server }
	
	<#Testar se o equipamento está ligado - PING----------------------------------------------------------#>
	if (Test-Connection $server -Count 1 -ea 0 -Quiet)
	{	
		$status["Resultado"] = "Ligado" 
		
		<#Testar em qual Domínio e OU a conta está -------------------------------------------------------#>
				
	}     
	else
	{	
		$status["Resultado"] = "Desligado"
	}
	<#FIM -Testar se o equipamento está ligado - PING------------------------------------------------------#>	
	
	try
	{
		get-ADComputer -Server $domínio $server -ErrorAction stop | Out-Null
		$ou =  Get-ADComputer -Server $domínio -identity $server -properties 'DistinguishedName'
		$status["AD"] = $domínio
		$status["OU"] = $OU
	}
		catch
		{
			$status["AD"] = "Fora do Dominio"    
			$status["OU"] = "Fora do Dominio"
		}
	
		
	<#Gera o Arquivo e Grava as informações--------- ---------------------------------------------------#>
	New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
	$collection += $serverStatus
	$collection | export-csv $caminho\Resultado.csv -NoTypeInformation
	<#FIM - Gera o Arquivo e Grava as informações--------------------------------------------------------#>
}


<#Gera mensage de Conclusão-------------------------- ---------------------------------------------------#>
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Consulta Concluída. Favor verificar o relatório.",0,"Check AD e Ping",0x0)
<#FIM - Gera mensage de Conclusão-------------------------- ---------------------------------------------------#>