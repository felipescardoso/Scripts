$scriptpath = "C:\Users\gnfk\Desktop\SMDI\0-Scripts"

$Exportar = ($scriptpath + "\Arquivo.csv")
$Computers = Get-Content ($scriptpath + "\Computer.ini")
$Arquivos = Get-Content ($scriptpath + "\Caminhos.ini")

foreach ($Computer in $Computers){

    Foreach ( $Arquivo in $Arquivos) {
        Get-ChildItem -Path $Arquivos -Recurse -File  | Select-Object FullName, Length | Export-Csv $Exportar -Encoding UTF8 -NoTypeInformation
    
    }

}