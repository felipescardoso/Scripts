#Passos para alterar o tema para Petrobras no Windows 10
#$User deverá conter a chave do usuário logado

$winVer = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object -ExpandProperty ProductName
if ($winVer -eq "Windows 10 Enterprise") {
	#$User = 'MJ8U'
    $cont = 0
    $cont2 = 0
    Stop-Process -Name SystemSettings -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    Start-Process $env:LOCALAPPDATA\Microsoft\Windows\Themes\oem.theme -ErrorAction SilentlyContinue
    while(($cont -eq 0) -and ($cont2 -lt 1500)){
        if (Get-Process -Name SystemSettings -ErrorAction SilentlyContinue) {
            #Start-sleep -Milliseconds 200
            Stop-Process -Name SystemSettings -Force
            $cont = 1
            Exit 0
        } else { 
            Write-host "Nao executando. $cont2" 
            $cont2 = $cont2 + 1
        }
    }
    Exit 1
}