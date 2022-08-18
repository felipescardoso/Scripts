CLS
$micro = Get-Content env:computername
$modelo = wmic csproduct get name
$Arquivo = "C:\temp\Lista_Processos_" + $micro + $modelo +".txt"

Get-Process -Name * | ft processname, description | Out-File $Arquivo