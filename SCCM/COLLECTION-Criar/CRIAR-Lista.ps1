$alvos = Get-Content -Path 'C:\Users\felipe.cardoso\OneDrive - Solo Network Brasil S.A\Documentos\GitHub\Scripts\SCCM\COLLECTION-Criar\CRIAR-Lista_Alvos.txt'
$alvos.Count


 for($i=1;$i -le 1000; $i++){
       Write-Host $i
 }

 while($val -ne 10) { $val++ ; Write-Host $val }