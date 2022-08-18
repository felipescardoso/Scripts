#Reparando o WMI
Function Repair-WMI {
    $text ='Repairing WMI'
    Write-Output $text
        
    # Check PATH
    if((! (@(($ENV:PATH).Split(";")) -contains "$env:SystemDrive\WINDOWS\System32\Wbem")) -and (! (@(($ENV:PATH).Split(";")) -contains "%systemroot%\System32\Wbem"))){
        $text = "WMI Folder not in search path!."
        Write-Warning $text
    }
    # Stop WMI
    Stop-Service -Force ccmexec -ErrorAction SilentlyContinue 
    Stop-Service -Force winmgmt

 

    # WMI Binaries
    [String[]]$aWMIBinaries=@("unsecapp.exe","wmiadap.exe","wmiapsrv.exe","wmiprvse.exe","scrcons.exe")
    foreach ($sWMIPath in @(($ENV:SystemRoot+"\System32\wbem"),($ENV:SystemRoot+"\SysWOW64\wbem"))) {
        if(Test-Path -Path $sWMIPath){
            push-Location $sWMIPath
            foreach($sBin in $aWMIBinaries){
                if(Test-Path -Path $sBin){
                    $oCurrentBin=Get-Item -Path  $sBin
                    & $oCurrentBin.FullName /RegServer
                }
                else{
                    # Warning only for System32
                    if($sWMIPath -eq $ENV:SystemRoot+"\System32\wbem"){
                        Write-Warning "File $sBin not found!"
                    }
                }
            }
            Pop-Location
        }
    }

 

    # Reregister Managed Objects
    Write-Verbose "Reseting Repository..."
#Write-Log  "Reseting Repository..."
    & ($ENV:SystemRoot+"\system32\wbem\winmgmt.exe") /resetrepository
    & ($ENV:SystemRoot+"\system32\wbem\winmgmt.exe") /salvagerepository
    Start-Service winmgmt
    $text = 'Tagging ConfigMgr client for reinstall'
    Write-Warning $text
}

 

Repair-WMI