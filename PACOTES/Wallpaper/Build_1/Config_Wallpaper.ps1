<#
Dados do Pacote
Descrição: Atualização do papel de parede dos perfis. Realizado testes no Windows 7 e Windows 10
        Ao final, no Windows 10, é necessario executar os passos abaixo no perfil do usuario atualmente "logado". Este execução se encontra
        no arquivo "Tema_Petrobras_Perfil_Windows10.ps1" que é chamado através do "Invoke-PSScriptAsUserBR.ps1" que é executado no perfil atualmente logado.
        #Passos para alterar o tema para Petrobras
        #$User deverá conter a chave do usuário logado
        $cont = 0
        Stop-Process -Name SystemSettings -Force -ErrorAction SilentlyContinue
        Start-Sleep 2
        Start-Process C:\Users\$User\AppData\Local\Microsoft\Windows\Themes\oem.theme
        while($cont -eq 0){
            if (Get-Process -Name SystemSettings -ErrorAction SilentlyContinue) {
                #Start-sleep -Milliseconds 200
                Stop-Process -Name SystemSettings -Force
                $cont = 1
            } else { Write-host "Nao executando" }
        }
Software: 
Versão: 

Autor: 
Modificado por: Herbert Carlos - MJ8U
Data da Criação: 01/01/2018
Last Modified: 22/01/2019

Versão do pacote:  2
		
#>

#Variaveis para o LOG
$global:DataLog = (Get-Date).tostring("dd-MM-yyyy")
$global:HoraLog = (Get-Date).tostring("HH:mm:ss")
$global:Computername = $Env:COMPUTERNAME
$Temp = $env:TEMP
$global:ComputersystemObj = Get-WmiObject -Namespace root\CIMV2 -Class Win32_ComputerSystem

#Funções
function Gravar-Log ([String]$LOG_txt) {
    <#Exemplo de execução:
    Gravar-Log -LOG_txt "Atualizacao realizada"
    #>

    $LOG = (("C:\Windows\Logs\") + ($global:SoftwareName)+ ("_") + ($global:SoftwareVersion) + (".log"))
    $global:HoraLog = (Get-Date).tostring("HH:mm:ss")# Atualização da hora para uso no LOG
    Add-Content -Path $LOG -Value "$global:DataLog - $global:HoraLog : $LOG_txt" -Force -Encoding Unicode
}

function Get-Username {
	<#
		Retorna a chave do usuário atualmente logado no Sistema Operacional.

		Parâmetros:
			[SEM PARÂMETROS]
		
		Retorno:
			Retorna uma STRING contendo a chave do usuário atualmente logado no Sistema Operacional.
	#>
	
	$Ret = ""
	$tmp_username = $ComputersystemObj.username
	
	If($tmp_username){
		$Ret = $tmp_username.Substring($tmp_username.Length - 4).ToUpper()
	}

	Return $Ret
}

# Test-RegistryValue from: https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
function Test-RegistryValue {

	param(

		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]$Path,

		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]$Name
	)

	try {
		Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Name -ErrorAction Stop | Out-Null
		return $true
	}

	catch {
		return $false
	}
}

# ConvertFrom-Hexa from: https://social.technet.microsoft.com/Forums/windowsserver/en-US/5c4755ee-6fac-40f4-9210-95d50cdbb501/registry-regbinary-to-string?forum=winserverpowershell
function ConvertFrom-Hexa {

    $hexstring=(Get-ItemProperty "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" | Select -ExpandProperty TranscodedImageCache) -join ','
	($hexstring.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries) | ?{$_ -gt '0'} | ForEach{[char][int]"$($_)"}) -join ''

}

# RefreshWallpaper from: https://kelleymd.wordpress.com/2015/01/10/update-wallpaper-image/
function RefreshWallpaper ($wallpaper){
    #use C# code to call an immediate refresh on the screensaver image. The style is not changed here (strech, tile etc…)
    # so whatever was set before will remain.
    # SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE)

    Write-Output "The path passed into RefreshWallpaper is: $wallpaper"
    Gravar-Log -LOG_txt "Executando um RefreshWallpaper: $wallpaper"

Add-Type @”
	using System;
	using System.Runtime.InteropServices;
	using Microsoft.Win32;

	namespace Wallpaper
	{
		public class UpdateImage
		{
			[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        
			private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);

			public static void Refresh(string path) 
			{
				SystemParametersInfo( 20, 0, path, 0x01 | 0x02 ); 
			}
		}
	}
“@

    Write-Output "The wallpaper being refreshed is: $wallpaper"
    
    [Wallpaper.UpdateImage]::Refresh($wallpaper)

    #Esta condição foi criada para uso no Windows 10
	if ($winVer -eq "Windows 10 Enterprise") {
        Write-Output "Post Wallpaper refresh TranscodeImagecache value: $(ConvertFrom-Hexa)"
        Gravar-Log -LOG_txt "Atualizado a chave de registro referente ao TranscodeImageCache: $(ConvertFrom-Hexa)"
    }
}

# Update-Registry - Adjust required values within the registry
function Update-Registry {
	Gravar-Log -LOG_txt "Atualizado as chaves de registros do perfil"
    #Esta condição foi criada para uso no Windows 10
	if ($winVer -eq "Windows 10 Enterprise") {
        # Encoding statement from: https://stackoverflow.com/a/18092826
        $bytes = [Text.Encoding]::Unicode.GetBytes("C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"); $bytes += 0,0,0
	    #$bytes = [Text.Encoding]::Unicode.GetBytes("$DestinationFolderPath\$DestinationWallpaperFileNamePetro"); $bytes += 0,0,0
        Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name TranscodedImageCache -Value ($bytes)
	}
    Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name Wallpaper -Value "C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"
	#Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name Wallpaper -Value "$DestinationFolderPath\$DestinationWallpaperFileNamePetro"
    Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name TileWallpaper -Value "0"
	#Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name WallpaperStyle -Value "2" -Force

    if ($winVer -eq "Windows 10 Enterprise"){
        Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name WallpaperStyle -Value "2" -Force #Ampliar 2
    }
    else {
        Set-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop" -Name WallpaperStyle -Value "10" -Force #Preencher 10
    }	

    #Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Checksum -Value $filesWallpaperHash.Hash
    
    #Esta condição foi criada para uso no Windows 10
	if ($winVer -eq "Windows 10 Enterprise") {
	    Write-Output "Post Update-Registry TranscodeImageCache value: $(ConvertFrom-Hexa)"
        Gravar-Log -LOG_txt "Atualizado a chave de registro referente ao TranscodeImageCache: $(ConvertFrom-Hexa)"
    }
}

function Update-Wallpaper {

    Write-Output "The wallpaper currently in use is: $CurrentWallpaperPath"
    Gravar-Log -LOG_txt "O wallpaper em uso neste perfil: $CurrentWallpaperPath"

	# Remove any cached background images
    Gravar-Log -LOG_txt "Removendo os antigos arquivos do caminho C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes"
	Remove-Item -Path "C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\*" -Force -ErrorAction SilentlyContinue
    Gravar-Log -LOG_txt "Arquivos removidos"

    Gravar-Log -LOG_txt "Criando o novo arquivo C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"
    Copy-Item ".\Files\$SourceWallpaperFileName" "C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper" -Force
    Gravar-Log -LOG_txt "Arquivo criado"

    Update-Registry
	RefreshWallpaper "C:\Users\$chave\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"
    #RefreshWallpaper "$DestinationFolderPath\$DestinationWallpaperFileNamePetro"

}

#---Inicio da estrutura para consulta de todos os perfis---#
#Link: https://www.pdq.com/blog/modifying-the-registry-users-powershell/

# Padrao de regex para SIDs
$patternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
 
# Get Username, SID e location of ntuser.dat para todos os usuarios
$profileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $patternSID} | 
    Select  @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
 
# Obter todos os SIDs de usuarios encontrados em HKEY_USERS (arquivos ntuder.dat carregados)
$loadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $patternSID} | Select @{name="SID";expression={$_.PSChildName}}
 
# Obter todos os usuarios que nao estao atualmente conectados
$unloadedHives = Compare-Object $profileList.SID $loadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username

#---Fim da estrutura para consulta de todos os perfis---#

#Obtem a resolução do monitor primário para tentar definir o arquivo backgroundDefault.jpg coma  resolucao adequada.
#$Res = Get-WmiObject -Class Win32_DesktopMonitor | where {$_.DeviceID -eq "DesktopMonitor1"}
#$W = $res.ScreenWidth
#$H = $res.ScreenHeight

$winVer = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object -ExpandProperty ProductName

if ($winVer -eq "Windows 10 Enterprise") {    
    $W = (Get-CimInstance -ClassName CIM_VideoController).CurrentHorizontalResolution
    $H = (Get-CimInstance -ClassName CIM_VideoController).CurrentVerticalResolution
    $resolution = "Background"+$W+"x"+$H+".jpg"
    if (($W -eq $null) -or ($H -eq $null) ) {
        $resolution = "background1920x1200.jpg"
    }
    Write-Output $resolution
}
else {
    Add-Type -AssemblyName System.Windows.Forms
    $W = (([System.Windows.Forms.Screen]::PrimaryScreen).Bounds).Width
    $H = (([System.Windows.Forms.Screen]::PrimaryScreen).Bounds).Height
    $resolution = "Background"+$W+"x"+$H+".jpg"
    if (($W -eq $null) -or ($H -eq $null) ) {
        $resolution = "background1920x1200.jpg"
    }
    Write-Output $resolution
}

if(!(Test-Path ".\Files\$resolution")){
    $resolution = "Background1920x1080.jpg"
}

$files = ".\Files"
$SourceWallpaperFileName = $resolution
$DestinationWallpaperFileNamePetro = "WallpaperMod.jpg"
$DestinationFolderPath = "C:\Windows"

#DEFINA AQUI O NOME DO SOFTWARE
$global:SoftwareName = "SetWallpaper"

#DEFINA AQUI A VERSÃO DO SOFTWARE
$global:SoftwareVersion = "Versao 1"

#****************************************************************************************************************************************************
#******************************************************************* MAIN PROGRAM *******************************************************************
#****************************************************************************************************************************************************

#Arquivo de Log criado
Gravar-Log -LOG_txt "--------------------------------------------------------------------"
Gravar-Log -LOG_txt "Início do script"
$user = Get-Username
Gravar-Log -LOG_txt "Usuario atualmente logado: $user"
Gravar-log -LOG_txt "Copiando o arquivo $SourceWallpaperFileName com a resolucao correta para $DestinationFolderPath\$DestinationWallpaperFileNamePetro"
Copy-Item ".\Files\$SourceWallpaperFileName" "$DestinationFolderPath\$DestinationWallpaperFileNamePetro" -Force
Gravar-log -LOG_txt "Copia concluida"

Gravar-log -LOG_txt "$winVer"

Gravar-log -LOG_txt "$resolution"

# Loop através de cada perfil na maquina
foreach ($item in $profileList) {
    # Carregar o usuario ntuser.dat, se ainda nao estiver carregado
    # Substituido o "-in" por "-contains" devido a versao 2.0 do powershell. Com isso foi necessario inverter as variaveis de posicao
    if ($unloadedHives.SID -contains $item.SID) {
        reg load HKU\$($item.SID) $($item.UserHive) | Out-Null
    }
 
    #Exibe a chave que ira percorrer
    "{0}" -f $($item.Username) | Write-Output
        
    #Chave do usuario que esta sendo migrado    
    $chave = "{0}" -f $($item.Username)
    
    #Somente ira verificar as chaves de 4 digitos e 6 digitos 
    #if (($chave | Measure-Object -Character).Characters -le 6){
        Gravar-Log -LOG_txt "Percorrendo o perfil $chave"
                
        $sid = $item.SID    
        
        #$printer_map = Get-ChildItem "registry::HKEY_USERS\$($sid)\Printers\Connections\" -Recurse -Name
        $CurrentWallpaperPath = (Get-ItemProperty -Path "registry::HKEY_USERS\$($sid)\Control Panel\Desktop").WallPaper
        Update-Wallpaper
        #Start-Process C:\Windows\Resources\Themes\petrobras.theme
        #Start-sleep 1
        RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 1, True
        Write-Output "Concluida a configuracao no perfil $chave"      
         
    #}
       
    # Descarregar ntuser.dat 
    # Substituido o "-in" por "-contains" devido a versao 2.0 do powershell. Com isso foi necessario inverter as variaveis de posicao      
    if ($unloadedHives.SID -contains $item.SID) {
        ### Coleta de lixo e fechamento de ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($item.SID) | Out-Null
    }
}

<#Esta condição foi criada para uso no Windows 10
if (($winVer -eq "Windows 10 Enterprise") -and ($user -ne $null)) {
    Write-Output "Sera necessario alterar o tema do perfil $user pelo SCCM na chave do usuario"
    Gravar-log -LOG_txt "Sera necessario alterar o tema do perfil $user na chave do usuario"
    .\Invoke-PSScriptAsUserBR.ps1
	Start-Sleep 10
    Write-Output "Tema alterado"
    Gravar-log -LOG_txt "Tema alterado"
}
else {
    Write-Output "Nenhum perfil logado"
    Gravar-Log "Nenhum perfil logado"
}
Gravar-log -LOG_txt "Fim do script"
#>
[System.Environment]::Exit(0)