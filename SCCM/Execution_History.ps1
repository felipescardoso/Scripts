<#VARIAVEIS-----------------------------------------------------------------------------------------------------#>
$NETPing = New-Object system.Net.NetworkInformation.Ping
$global:DataLog = (Get-Date).tostring("dd-MM-yyyy")
$global:HoraLog = (Get-Date).tostring("HHmmss")
$global:Computername = $Env:COMPUTERNAME
#$caminho = [System.AppDomain]::CurrentDomain.BaseDirectory#>
$global:caminho = "\\infra\infra-tic\SMDI\INTERNO\Solicitacoes\Distribuicao\2019\AIP\V1.32_04.07.2019\Tratamento_Falhou\Tratamento"
$global:Lista = Get-Content $caminho\Lista_1.txt
$global:pacote = "CAS00557"
<#FIM-----------------------------------------------------------------------------------------------------------#>

<#FUNCÕES-----------------------------------------------------------------------------------------------------#>
function Teste-Conexao ([String]$codigo) {
	$global:TestConexao = ""
	$global:TestConexao = Test-Connection $codigo -Count 1 -ErrorAction SilentlyContinue | Select-Object *
	
	if ($TestConexao -ne $null ){
		$codigo
		$global:IPHost = ($global:TestConexao).IPV4Address
		#$global:NomeReverso = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$IPHost' and Timeout=1000" | Select-Object -Property *
		#$global:NomeReverso
		
		$global:NomeReverso = [System.Net.Dns]::gethostentry($TestConexao.IPV4Address)
				
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


<#Cria o arquivo de saída vazio----------------------------------------------------------------------------#>
$HOSTNAME = "HOSTNAME"
$STATUS = "LIGADO/DESLIGADO"
$NOMEPACOTE = "PACOTE"
$EXECUTION_HISTORY = "EXECUTION_HISTORY"
$ArquivoSaida = New-Item -type file -force $caminho\Resultado\Resultado.csv
"$HOSTNAME; $STATUS; $NOMEPACOTE; $EXECUTION_HISTORY" | Out-File  $ArquivoSaida -Encoding ASCII -append
<#FIM-----------------------------------------------------------------------------------------------------#>


foreach ($desktop in $Lista) {
	Teste-Conexao $desktop
	
	if ($TestConexaoFinal -eq 0){
		Invoke-Command -ComputerName $desktop {
			if (Test-Path -Path ("HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System\" + $pacote)){
				$PacotePath = Get-ChildItem -Path ("HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System\CAS00557") | Select-Object *
				$ExecHistory = Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System\CAS00557\" + ($PacotePath).PSChildName) | Select-Object *
				$ExecHistoryFinal = ($ExecHistory).SuccessOrFailureCode
			}
			Else{$ExecHistory = "Ausente"}
		}
		$HOSTNAME = $desktop
		$STATUS = $TestConexaoFinal
		$NOMEPACOTE = $global:pacote
		$EXECUTION_HISTORY = $ExecHistoryFinal
		
	}
	else{
		$HOSTNAME = $desktop
		$STATUS = $TestConexaoFinal
		$NOMEPACOTE = $global:pacote
		$EXECUTION_HISTORY = "OFFLINE/DNS_ERRO"
	
	}
	
	"$HOSTNAME; $STATUS; $NOMEPACOTE; $EXECUTION_HISTORY" | Out-File  $ArquivoSaida -Encoding ASCII -append
}









<#

foreach ($desktop in $Lista) {
	Teste-Conexao $desktop
	

}

if ($TestConexao -ne $null ){
    Invoke-Command -ComputerName $global:Hostname {Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History' | Select-Object }
}
else{Write-Host "Desligado"}

cls
$global:pacote = "CAS00557"
if (Test-Path -Path ("HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System\" + $pacote)){
	$PacotePath = Get-ChildItem -Path ("HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System\" + $pacote) | Select-Object *
	$ExecHistory = Get-ItemProperty -Path ("HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\Execution History\System\CAS00557\b8ab8716-9859-11e9-8ddf-641c676b910b") | Select-Object *
	($ExecHistory).SuccessOrFailureCode
}
#>