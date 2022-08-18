


$Ipaddress=  Read-host  "Digite o host que deseja verificar"
$Port= Read-host  "Agora Digite a Porta que deseja verificar"
 
$t = New-Object Net.Sockets.TcpClient
$t.Connect($Ipaddress,$Port)
    if($t.Connected)
    {
        " A Porta $Port esta habilitada em $(Get-Date)"
    }
    else
    {
        "Porta $Port esta inativa, não foi possivel conectar a porta em $(Get-Date) "
   }