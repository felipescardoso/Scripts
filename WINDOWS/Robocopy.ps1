$ORIGEM = "\\radixengrj.matriz\FilesRDX\ManutencaoTI\SCOM"
$DESTINO = "C:\Users\felipe.cardoso\OneDrive-Live\OneDrive\BACKUP\RADIX\FileRDX\SCOM"

#Robocopy.exe $ORIGEM $DESTINO /SEC /XF THUMB.DB THUMBS.DB Microsoft.lnk autorun.inf /e /w:3 /r:10
#Robocopy.exe "$ORIGEM" "$DESTINO" /e /w:3 /r:10  /XF *.exe *.msi *.mp4 *.mkv *.mkv
Robocopy.exe "$ORIGEM" "$DESTINO" /e /w:3 /r:10