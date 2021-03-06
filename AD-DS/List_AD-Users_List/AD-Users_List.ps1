<#Descrição:
Criador por: Felipe Santos Cardoso
GitHub: https://github.com/felipescardoso

Função: 
pt_BR:Lista as contas do Domínio ou OU específica e exporta para um arquivo csv.
en_US:Lists the accounts of the Domain or specific OU and exports to a csv file.
Version: 1.0 | 18/05/2019
#>


import-module ActiveDirectory
#$ScriptPath = [System.AppDomain]::CurrentDomain.BaseDirectory
$ScriptPath = ".\"
$wshell = New-Object -ComObject Wscript.Shell # Classe para Mensagem | Message Class
$DataLog = (Get-Date).tostring("dd-MM-yyyy")
$dominio = Get-Content $ScriptPath\dominio.txt
$Searchbase = Get-Content $ScriptPath\ou.txt

#Parametro para consulta | Parametro for consultation
$ADUserParams=@{
'Server' = $dominio
'Searchbase' = $Searchbase
'Searchscope'= 'Subtree'
'Filter' = '*'
'Properties' = '*'
}

#Parametro para o arquivo de saída | Parameter for output file
$SelectParams=@{
'Property' = 'SAMAccountname', 'CN','Enabled' , 'title', 'DisplayName', 'DistinguishedName','UserPrincipalName'
}

$arquivo_saida = "$ScriptPath\Users_list_$DataLog.csv"
get-aduser @ADUserParams | select-object @SelectParams | export-csv $arquivo_saida
$wshell.Popup("Coleta de usuarios $dominio concluída!",0,"GetUser",0x40)