$objShell = New-Object -ComObject WScript.Shell
$lnk = $objShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\SecurityDesk.lnk")
$lnk.TargetPath = "C:\Program Files (x86)\Genetec Security Center 5.2\SecurityDesk.exe"
$lnk.Description = "Atalho do Security Center"
$lnk.WorkingDirectory = "$ENV:WinDir\System32"
$lnk.WindowStyle = "1"
$lnk.Save()