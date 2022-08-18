Import-Module activedirectory
$user = $env:username
$group = "GU_BOTI_DESBLOQUEIO_STORAGE-DEVICES"
$members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty Name

If ($members -contains $user) {
      $valores = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CD Burning\Drives\vol*" -name "Drive Type" | select -exp "Drive Type"

	 ForEach ($Valor in $Valores)
	{
	if ($valor -ne 21495)
	{
	set-itemproperty -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CD Burning\Drives\vol*" -name "Drive Type" -value 21495
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
		[System.Windows.Forms.MessageBox]::Show("Correção efetuada Favor realizar os teste" , "Correção Drive CD/DVD" , 0,"Information") 
 	}
	Else{
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[System.Windows.Forms.MessageBox]::Show("Correção efetuada Favor realizar os teste" , "Correção Drive CD/DVD" , 0,"Information") 
	Exit(0)
 
	}
	}
     
 } Else {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
		[System.Windows.Forms.MessageBox]::Show("$user não faz parte do grupo de exceção favor entrar em contato com o 881" , "Correção Drive CD/DVD" , 0,"Information") 
        
}