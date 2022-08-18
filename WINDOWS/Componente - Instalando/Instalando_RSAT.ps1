$wshell = New-Object -ComObject Wscript.Shell

<#Testa se o RSAT está instalado--------------------------------------------------------------------------#>
$Teste = Test-Path C:\Windows\SysWOW64
<#FIM - Testa se o RSAT está instalado--------------------------------------------------------------------#>

if ($Teste -eq "True")
{
	Set-ExecutionPolicy Unrestricted <#Liberar a executação de Scripts em PowerShell#>
	Start-Process -FilePath "c:\Windows\System32\Dism.exe" -ArgumentList " /online /enable-feature /featurename:RemoteServerAdministrationTools /featurename:RemoteServerAdministrationTools-Roles /featurename:RemoteServerAdministrationTools-Roles-AD /featurename:RemoteServerAdministrationTools-Roles-AD-DS /featurename:RemoteServerAdministrationTools-Roles-AD-DS-SnapIns /featurename:RemoteServerAdministrationTools-Roles-AD-Powershell /featurename:RemoteServerAdministrationTools-Roles-AD-DS-AdministrativeCenter" -Wait  <#Ativa os Componentes do Powershell do RSAT#>
}
Else
{
	$wshell.Popup("RSAT não Instalado ou Ativado!",0,"Ativação do Componente AD - RSAT",0x0)
}
	$wshell.Popup("Componente Ativado",0,"Ativação do Componente AD - RSAT",0x0)