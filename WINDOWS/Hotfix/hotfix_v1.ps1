$strComputer = "." 
 
$colItems = get-wmiobject -class "Win32_QuickFixEngineering" 
 
foreach ($objItem in $colItems) { 
      $caption = "Caption: " $objItem.Caption 
      #write-host "CS Name: " $objItem.CSName 
      #write-host "Description: " $objItem.Description 
      #write-host "Fix Comments: " $objItem.FixComments 
      $hotfixid = "HotFix ID: " $objItem.HotFixID 
      $installdate = "InstallationDate: " $objItem.InstallDate 
      #write-host "Installed By: " $objItem.InstalledBy 
      #write-host "Installed On: " $objItem.InstalledOn 
      #write-host "Name: " $objItem.Name 
      #write-host "Service Pack In Effect: " $objItem.ServicePackInEffect 
      #write-host "Status: " $objItem.Status 
      #write-host 
	  
} 