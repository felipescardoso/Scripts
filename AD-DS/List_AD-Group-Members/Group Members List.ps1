<#Descrição:
Criador por: Felipe Santos Cardoso
GitHub: https://github.com/felipescardoso

Função: 
pt_BR: Lista membros de grupos e exporta para csv.
en_US: Lists members of groups and exports to csv.
Version: 1.0 | 18/05/2019
-----------------------------------------------------------------------------------------------------------#>


cls
import-module ActiveDirectory <# Ativa componente do Powershell no RSAT #>
$wshell = New-Object -ComObject Wscript.Shell <# Classe para Mensagem #>

#Determina o caminho corrente | Determines the current path
#$caminho = [System.AppDomain]::CurrentDomain.BaseDirectory
$caminho = ".\"


#Leitura dos equipamentos | Group reading
#$grupos = Get-Content "D:\Usuarios\gnfk\Desktop\SUPORTE TIC\7 - Ferramentas\AD\Relatório - Membros_de_Grupo\Grupo.txt"
$grupos = Get-Content ($caminho + "\Grupo.txt")

#Criando arquivo de saída | Creating output file
$DataLog = (Get-Date).tostring("dd-MM-yyyy")
$CODIGO = "CODIGO"
$GRUPO = "GRUPO"
$RelatorioSaida = New-Item -type file -force ($caminho + "\Relatorio_Grupos_" +$DataLog+".csv") 
"$CODIGO; $GRUPO" | Out-File  $RelatorioSaida -Encoding ASCII -append

$grupo = ""
$contador = 0
$micro = ""
#$null = ""

#For para os Grupos
foreach ($grupo in $grupos)
{
	#$TestGroup = Get-ADGroup $grupo
	if ((Get-ADGroup $grupo) -eq $null ){
		$CODIGO = "Grupo nao existe"
		"$CODIGO; $GRUPO" | Out-File  $RelatorioSaida -Encoding ASCII -append
		}
		Else{
			
			$micros = Get-ADGroupMember -Identity $grupo
			#For para os códigos
			foreach ($micro in $micros){
				
				$CODIGO = Get-aduser $micro | Select-Object -ExpandProperty name
				$GRUPO = $grupo
				"$CODIGO; $GRUPO" | Out-File  $RelatorioSaida -Encoding ASCII -append
			}
		}
	
		
}

#Gera mensage de Conclusão | Generates completion message
$wshell.Popup("Consulta concluída. Favor verificar o relatório.",0,"Membro de Grupo",0x0)

