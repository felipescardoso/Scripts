
#Servidor de SMTP
$Servidor = 'smtp.office365.com'

#Porta SMTP utilizada 25 ou 587
$Porta = '587'

#Usuário e senha do e-mail remetente
$Usuario =  'felipe@sscardoso.com.br' #Inserir o e-mail
$Password =  'SENHA' # Inserir a senha
$secpasswd = ConvertTo-SecureString "$Password" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("$Usuario", $secpasswd)

#Remetente e destinatário
$Origem = 'felipe@sscardoso.com.br'
$Destino =  'felipescardoso@live.com'

#Detalhes do e-mail
$Assunto = 'E-MAIL - TESTE DE ENVIO | FIM DA TAREFA AGENDADA'
$Anexo =  "C:\log.txt"
$CorpoEmail = "Corpo do e-mail"

     
#pausa estratégica     
Start-Sleep 2

#Envio
Send-MailMessage -From $Origem -To $Destino -Subject $Assunto -Body $CorpoEmail -Attachments $Anexo -SmtpServer $Servidor -Credential $cred -UseSsl -Port $Porta

