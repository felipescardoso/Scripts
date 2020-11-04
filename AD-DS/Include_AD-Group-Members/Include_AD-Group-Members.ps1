# ADD USER TO AD GROUP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

$GRUP = "GROUP'S_NAME"

$UserAcounts = "USER1","USER2","USER3"

foreach ($UserAcount in $UserAcounts) {
    $UserAcount = Get-ADUser $UserAcount -Properties *
    Add-ADGroupMember $GRUP -Members $UserAcount | Out-Null
    write-host ""
    write-host  $UserAcount.CN " - " $GRUP
}