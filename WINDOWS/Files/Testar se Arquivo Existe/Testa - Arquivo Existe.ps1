cls
$Teste = Test-Path C:\Windows\SysWOW64\dsa1.msc
if ($Teste -eq "True")
{
	Write-Host "Existe"
}
Else
{
	Write-Host "Nao Existe"
}
