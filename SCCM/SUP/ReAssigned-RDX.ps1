$sms = New-Object -ComObject 'Microsoft.SMS.Client'
$sms.GetAssignedSite()
$sms.SetAssignedSite('RDX')