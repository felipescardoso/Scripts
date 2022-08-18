#Removendo Variáveis
Remove-Variable * -ErrorAction SilentlyContinue

#Biblioteca para Compactar
Add-Type -Assembly "System.IO.Compression.FileSystem" ;


$FileAttachResultado = "C:\TEMP\resultado\Resultad_Query.csv"
$FileAttachResultadoZip = "c:\temp\Upgrade.zip"

#Removendo arquivo antigo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#Remove-Item "$FileAttachResultado" -Force -ErrorAction SilentlyContinue
#Remove-Item "$FileAttachResultadoZip" -Force -ErrorAction SilentlyContinue


#EXECUTAR QUERY - Necessita do componente instalado++++++++++++++++++++++++++++++++++++++++++++++
#sqlcmd -S "SERVIDOR" -i "c:\TEMP\Query.sql" -h -1 -W -w 999 -s";" -o "c:\TEMP\Resultad_Query.csv"



#COMPACTAR TODOS OS ARQUIVOS DA PASTA+++++++++++++++
#[System.IO.Compression.ZipFile]::CreateFromDirectory("C:\TEMP\resultado\", "c:\temp\Upgrade.zip") ;

Send-MailMessage -From '<graciene.cardoso@globalhitss.com.br>' -To '<graciene.cardoso@globalhitss.com.br>','<felipe.s.cardoso@globalhitss.com.br>' -Subject 'TESTE ENVIO SMTP - POWERSHELL' -Body "Segue relatório do meu amor. NEOQEAV!" -Attachments "$FileAttachResultado" -SmtpServer 'exchange.embratelmail.com.br' -Port 587 -Encoding UTF8


