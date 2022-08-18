New-Item -ItemType directory -Path "C:\Program Files\Ragnarok\1.6"
$objShell = New-Object -ComObject WScript.Shell
$lnk = $objShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Ragnarok 1.6.lnk")
$lnk.TargetPath = "C:\Program Files\Ragnarok\1.6\ragnarok1_6.exe"
$lnk.Description = "Ragnarök 1.6"
$lnk.WorkingDirectory = "$ENV:WinDir\System32"
$lnk.WindowStyle = "1"
$lnk.Save()