$NOME = "FILA"
$SERVIDOR = "SERVIDOR"
$DRIVER = "DRIVER"
$ERRO_FILA = "ERRO FILA"
$ArquivoSaida = New-Item -type file -force d:\Usuarios\gnfk\Documents\_TEMP\test.csv
"$NOME; $SERVIDOR; $DRIVER" | Out-File  $ArquivoSaida -Encoding ASCII -append

$FILAS = Get-Content d:\Usuarios\gnfk\Documents\_TEMP\FILAS.txt

$FILA = ""
 
$contador = 0
  
foreach ($FILA in $FILAS)
{
	$contador++
	$NOME = Get-Printer -ComputerName sptbrps02 -Name $FILA | Select-Object -ExpandProperty name 
	$SERVIDOR = Get-Printer -ComputerName sptbrps02 -Name $FILA | Select-Object -ExpandProperty ComputerName
	$DRIVER = Get-Printer -ComputerName sptbrps02 -Name $FILA | Select-Object -ExpandProperty DriverName

	"$NOME; $SERVIDOR; $DRIVER" | Out-File  $ArquivoSaida -Encoding ASCII -append

	Write-Progress -Activity "Executando as config." -CurrentOperation $FILA -PercentComplete (($contador /$FILAS.Count) * 100)
	Start-Sleep -Seconds 2
}