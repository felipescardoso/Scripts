manage-bde -protectors -add c: -tpm
manage-bde -protectors -add c: -rp
manage-bde -on c: -s

(Get-BitLockerVolume -MountPoint c:\).KeyProtector > $env:UserProfile\Desktop\bitlocker.txt
    $rp = Get-Content -Path $env:UserProfile\Desktop\bitlocker.txt

    $File = Get-Content "$env:UserProfile\Desktop\bitlocker.txt" 
    $resultado=@()
        foreach ($Linha in $File){
        $resultado+=$Linha
                            }
        $rp = $resultado[10].split(':').split('{').split('}').split('KeyProtectorId         ')
        Write-Output "$hostname-$rp"
        Rename-item -Path C:\Users\Administrador\Desktop\bitlocker.txt $hostname-'Chave de proteção'$rp.txt -PassThru
        Move-Item -Path C:\Users\Administrador\Desktop\$hostname-'Chave de proteção'$rp.txt -Destination D:\Configuracao_de_maquina\Bitlocker -PassThru  

$hostname = ""
$hostname = hostname
$bitlocker = $hostname

#se puder , já jogar direto no caminho \\radixengrj.matriz\FilesRDX\ManutencaoTI\bitlocker