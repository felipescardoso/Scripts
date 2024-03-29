#define a versão dos arquivos aplicados com base dna data do arquivo background1024x768.jpg
$Versao = Get-Item .\background1024x768.jpg
$Versao = $Versao.LastWriteTime.ToString('dd.MM.yyyy.hhmm')

#Verifica o Sistema Operacional
$winVer = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object -ExpandProperty ProductName

if ($winVer -eq "Windows 10 Enterprise") {    
    #Cria policies via registro
	If((Test-Path 'HKLM:\Software\Policies\Microsoft\Windows\Personalization') -eq $false ) { New-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\Personalization' -force -ea SilentlyContinue } 

	#Habilita a Policy
	Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Personalization' -Name 'NoLockScreen' -Value 0 -ea SilentlyContinue 
	Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Personalization' -Name 'LockScreenImage' -Value 'C:\Windows\System32\oobe\info\backgrounds\backgroundDefault.jpg' -ea SilentlyContinue
	Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Personalization' -Name 'NoChangingLockScreen' -Value 1 -ea SilentlyContinue 
	
	#Recupera o proprietario e Apaga cache das imagens antigas da tela de bloqueio
    TAKEOWN /F "C:\ProgramData\Microsoft\Windows\SystemData" /A /R
    Remove-Item "C:\ProgramData\Microsoft\Windows\SystemData\S-1-5-18\ReadOnly\LockScreen_P\*.*"
    
    #Obtem a resolucao do monitor primario para tentar definir o arquivo backgroundDefault.jpg coma  resolucao adequada.
    $W = (Get-CimInstance -ClassName CIM_VideoController).CurrentHorizontalResolution
    $H = (Get-CimInstance -ClassName CIM_VideoController).CurrentVerticalResolution
    $resolution = "Background"+$W+"x"+$H+".jpg"
    if (($W -eq $null) -or ($H -eq $null) ) {
        #Nao precisou deste tratamento pois o mesmo e relizado mais a frente
        #$resolution = "background1920x1200.jpg"
    }    
}
else {   
    #Obtem a resolucao do monitor primario para tentar definir o arquivo backgroundDefault.jpg coma  resolucao adequada.
    $res = Get-WmiObject -Class Win32_DesktopMonitor | where {$_.DeviceID -eq "DesktopMonitor1"}
    $W = $res.ScreenWidth
    $H = $res.ScreenHeight
    $resolution = "Background"+$W+"x"+$H+".jpg"
    
    if (($W -eq $null) -or ($H -eq $null) ) {
        #Nao precisou deste tratamento pois o mesmo e relizado mais a frente
        #$resolution = "background1920x1200.jpg"
    }
}

#Remove espacos, caso haja no nome do arquivo
$resolution = $resolution -replace (' ', '')
Write-Output $resolution

#Apaga o conteúdo da pasta
remove-item C:\Windows\System32\oobe\info\backgrounds\*.jpg
Start-Sleep -s 2

#Copia todos os arquivos
copy-item *.jpg C:\Windows\System32\oobe\info\backgrounds\ -force
Start-Sleep -s 2

#Apaga o arquivo, caso exista no pacote de arquivos recebido
If(Test-Path C:\Windows\System32\oobe\info\backgrounds\backgroundDefault.jpg){
    Remove-Item C:\Windows\System32\oobe\info\backgrounds\backgroundDefault.jpg
}
Start-Sleep -s 2

#Copia o arquivo de resolução 1024x768 para ser utilizado em equipamento que não possua imagem específica
If(Test-Path C:\Windows\System32\oobe\info\backgrounds\$Resolution){
    Copy-Item C:\Windows\System32\oobe\info\backgrounds\$Resolution C:\Windows\System32\oobe\info\backgrounds\backgroundDefault.jpg
}
Else{
    Copy-Item C:\Windows\System32\oobe\info\backgrounds\background1024x768.jpg C:\Windows\System32\oobe\info\backgrounds\backgroundDefault.jpg
}

#Após a cópia obtem o tamanho ocupado em disco para registro no Adicionar/Remover Programas
$Size = Get-ChildItem "C:\Windows\System32\oobe\info" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum

#Define o caminho da chave de registro a ser criada para inventário futuro
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LockScreenPetrobras"

#Cria a chave caso não exista e preenche os valores com seus respectivos dados.
If(Test-Path $registryPath){}Else{New-Item -Path $registryPath}
New-ItemProperty -Path $registryPath -Name DisplayName -Value "LockScreen Petrobras" -Type "String" -force | out-null
New-ItemProperty -Path $registryPath -Name UninstallString -Value "c:\\Windows\\System32\\oobe\\info\\backgrounds" -Type "String"  -force | out-null
New-ItemProperty -Path $registryPath -Name InstallLocation -Value "c:\\Windows\\System32\\oobe\\info\\backgrounds" -Type "String"  -force | out-null
New-ItemProperty -Path $registryPath -Name DisplayVersion -Value $Versao -Type "String"  -force | out-null
New-ItemProperty -Path $registryPath -Name Publisher -Value "SMDI" -Type "String" -force | out-null
New-ItemProperty -Path $registryPath -Name InstallDate -Value (Get-Date -format "yyyyMMdd") -Type "String" -force | out-null
New-ItemProperty -Path $registryPath -Name DisplayIcon -Value "C:\WINDOWS\system32\imageres.dll,67" -Type "String" -force | out-null
New-ItemProperty -Path $registryPath -Name EstimatedSize -Value ($Size.Sum / 1024) -Type "DWORD" -force | out-null