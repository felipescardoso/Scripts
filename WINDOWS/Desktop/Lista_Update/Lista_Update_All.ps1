
#Declaração de Variáveis
$local = "$env:USERPROFILE"
$computador = "$env:computername"

#Declaração e consulta da da API
$Session = New-Object -ComObject "Microsoft.Update.Session" 
$Searcher = $Session.CreateUpdateSearcher()

$historyCount = $Searcher.GetTotalHistoryCount()

$saida = $Searcher.QueryHistory(0, $historyCount) | Select-Object Title, Date,

    @{name="Operation"; expression={switch($_.operation){

        1 {"Installation"}; 2 {"Uninstallation"}; 3 {"Other"}

}}}

#Declaração de Saída
$Arquivo = $local + "\Desktop\Lista_Update_" + $computador + ".txt"

#Saída do Arquivo
$saida | Out-File $Arquivo -Append -Width 800

#----------------------Exibe Mensagem ao final da instalação caso necessário(não usar para instalções silenciosas)-----------------
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("Coleta concluída!" , "Lista Update" , 0,"Information")