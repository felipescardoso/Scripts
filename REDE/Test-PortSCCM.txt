$portas = "80","135","443","445","10123","8530","8531"
Write-Host 'Teste de comunicacao com o U19SCCM1MTZ.sotreq.net' -BackgroundColor DarkGreen
foreach ($porta in $portas){
    Test-NetConnection U19SCCM1MTZ.sotreq.net -Port $porta -WarningAction SilentlyContinue | Select-Object SourceAddress,RemoteAddress,RemotePort,TcpTestSucceeded
}
