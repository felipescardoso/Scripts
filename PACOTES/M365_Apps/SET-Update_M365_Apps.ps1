Remove-Variable -Name * -Force -ErrorAction SilentlyContinue

#https://learn.microsoft.com/pt-br/deployoffice/office-deployment-tool-configuration-options#officemgmtcom-attribute-part-of-add-element
#Set-ItemProperty -path $key1 -Name 'OfficeMgmtCOM' -Value 'True'
#Set-ItemProperty -path $key2 -Name 'OfficeMgmtCOM' -Value '1'


$key1 = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
$key2 = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officeupdate'

$Test1 = Get-ItemProperty -path $key1 -Name 'OfficeMgmtCOM' -ErrorAction SilentlyContinue
if ($Test1 -ne $null) {Set-ItemProperty -path $key1 -Name 'OfficeMgmtCOM' -Value 'False' }

$Test2 = Get-ItemProperty -path $key2 -Name 'OfficeMgmtCOM' -ErrorAction SilentlyContinue
if ($Test2 -ne $null) {Set-ItemProperty -path $key2 -Name 'OfficeMgmtCOM' -Value '0' }

