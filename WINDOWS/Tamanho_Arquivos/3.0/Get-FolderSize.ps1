﻿cls

function Get-FolderSize {
    <#
    .SYNOPSIS

    Get-FolderSize
    Returns the size of folders in MB and GB.
    You can change the base path, omit folders, as well as output results in various formats.

    .DESCRIPTION

    This function will get the folder size in MB and GB of folders found in the basePath parameter. 
    The basePath parameter defaults to C:\Users. You can also specify a specific folder name via the folderName parameter.

    .PARAMETER BasePath

    This parameter allows you to specify the base path you'd like to get the child folders of.
    It defaults to where the module was run from via (Get-Location).

    .PARAMETER FolderName

    This parameter allows you to specify the name of a specific folder you'd like to get the size of.

    .PARAMETER AddTotal

    This parameter adds a total count at the end of the array

    .PARAMETER OmitFolders

    This parameter allows you to omit folder(s) (array of string) from being included

    .PARAMETER Output

    Use this option to output the results. Valid options are csv, xml, or json.

    .PARAMETER OutputPath

    Specify the path you want to use when outputting the results as a csv, xml, or json file.

    Do not include a trailing slash.

    Example: C:\users\you\Desktop

    Defaults to (Get-Location)
    This will be where you called the module from.

    .PARAMETER OutputFile

    This allows you to specify the path and file name you'd like for output.
    
    Example: C:\users\you\desktop\output.csv

    .PARAMETER AddFileTotals

    This parameter allows you to add file totals to the results. 
    Note: This will reduce performance of the script by around 30%!

    .EXAMPLE 

    Get-FolderSize | Format-Table -AutoSize


    FolderName                Size(Bytes) Size(MB)     Size(GB)
   
    $GetCurrent                    193768 0.18 MB      0.00 GB
    $RECYCLE.BIN                 20649823 19.69 MB     0.02 GB
    $SysReset                    53267392 50.80 MB     0.05 GB
    Config.Msi                            0.00 MB      0.00 GB
    Documents and Settings                0.00 MB      0.00 GB
    Games                     48522184491 46,274.36 MB 45.19 GB

    .EXAMPLE 

    Get-FolderSize -BasePath 'C:\Program Files'
    

    FolderName                                   Size(Bytes) Size(MB)    Size(GB)

    7-Zip                                            4588532 4.38 MB     0.00 GB
    Adobe                                         3567833029 3,402.55 MB 3.32 GB
    Application Verifier                              353569 0.34 MB     0.00 GB
    Bonjour                                           615066 0.59 MB     0.00 GB
    Common Files                                   489183608 466.52 MB   0.46 GB

    .EXAMPLE 

    Get-FolderSize -BasePath 'C:\Program Files' -FolderName IIS


    FolderName Size(Bytes) Size(MB) Size(GB)
  
    IIS            5480411 5.23 MB  0.01 GB

    .EXAMPLE

    $getFolderSize = Get-FolderSize 
    $getFolderSize | Format-Table -AutoSize


    FolderName Size(GB) Size(MB)
  
    Public     0.00 GB  0.00 MB
    thegn      2.39 GB  2,442.99 MB

    .EXAMPLE

    $getFolderSize = Get-FolderSize -Output csv -OutputPath ~\Desktop
    $getFolderSize 
  

    FolderName Size(GB) Size(MB)
    
    Public     0.00 GB  0.00 MB
    thegn      2.39 GB  2,442.99 MB

    (Results will also be exported as a CSV to your Desktop folder)

    .EXAMPLE

    Sort by size descending 
    $getFolderSize = Get-FolderSize | Sort-Object 'Size(Bytes)' -Descending
    $getFolderSize 


    FolderName                Size(Bytes) Size(MB)     Size(GB)

    Users                     76280394429 72,746.65 MB 71.04 GB
    Games                     48522184491 46,274.36 MB 45.19 GB
    Program Files (x86)       27752593691 26,466.94 MB 25.85 GB
    Windows                   25351747445 24,177.31 MB 23.61 GB

    .EXAMPLE

    Omit folder(s) from being included 
    Get-FolderSize.ps1 -OmitFolders 'C:\Temp','C:\Windows'

    .EXAMPLE

    Add file counts for each folder
    Note: This will slow down the execution of the script by around 30%
    
    $results = Get-FolderSize -AddFileTotal

    PS /Users/ninja/Documents/repos/PSFolderSize> $results[0] | Format-List *

    FolderName  : .git
    Size(Bytes) : 228591
    Size(MB)    : 0.22
    Size(GB)    : 0.00
    FullPath    : /Users/ninja/Documents/repos/PSFolderSize/.git
    HostName    : njambp.local
    FileCount   : 382

    #>
    [cmdletbinding(
        DefaultParameterSetName = 'default'
    )]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default'
        )]
        [Alias('Path')]
        [String[]]
        $BasePath = (Get-Location),        

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'default'
            
        )]
        [Alias('Name')]
        [String[]]
        $FolderName = 'all',

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String[]]
        $OmitFolders,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Switch]
        $AddTotal,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Switch]
        $AddFileTotals,        

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Switch]
        $UseRobo,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [ValidateSet('csv','xml','json')]
        [String]        
        $Output,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [String]
        $OutputPath = (Get-Location),

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String]
        $OutputFile = [string]::Empty
    )

    #Get a list of all the directories in the base path we're looking for.
    $allFolders = Get-FolderList -FolderName $FolderName -OmitFolders $OmitFolders -BasePath $BasePath
    
    #Create array to store folder objects found with size info.
    [System.Collections.ArrayList]$folderList = @()

    #Get hostname
    $hostName = [System.Net.Dns]::GetHostByName((hostname)).HostName

    #Go through each folder in the base path.
    ForEach ($folder in $allFolders) {

        #Clear out the variables used in the loop.
        $fullPath          = $null
        $folderInfo        = $null        
        $folderObject      = $null
        $folderSize        = $null
        $folderSizeInBytes = $null
        $folderSizeInMB    = $null
        $folderSizeInGB    = $null
        $folderBaseName    = $null
        $totalFiles        = $null

        #Store the full path to the folder and its name in separate variables
        $fullPath       = $folder.FullName
        $folderBaseName = $folder.BaseName     

        Write-Verbose "Working with [$fullPath]..."            

        #Get folder info / sizes
        if ($UseRobo) {

            $folderSize        = Get-RoboSize -Path $fullPath -DecimalPrecision 2

            $folderSizeInBytes = $folderSize.TotalBytes
            $folderSizeInMB    = [math]::Round($folderSize.TotalMB, 2)
            $folderSizeInGB    = [math]::Round($folderSize.TotalGB, 2)

        } else {

            $folderInfo = Get-Childitem -LiteralPath $fullPath -Recurse -Force -ErrorAction SilentlyContinue 
            $folderSize = $folderInfo | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue       

            #We use the string format operator here to show only 2 decimals, and do some PS Math.            
            if ($folderSize.Sum) {

                $folderSizeInBytes = $folderSize.Sum
                $folderSizeInMB    = [math]::Round($folderSize.Sum / 1MB, 2)
                $folderSizeInGB    = [math]::Round($folderSize.Sum / 1GB, 2)

            }
        }
        
        #Here we create a custom object that we'll add to the array
        $folderObject = [PSCustomObject]@{

            PSTypeName    = 'PS.Folder.List.Result'
            FolderName    = $folderBaseName
            'Size(Bytes)' = $folderSizeInBytes
            'Size(MB)'    = $folderSizeInMB
            'Size(GB)'    = $folderSizeInGB
            FullPath      = $fullPath            
            HostName      = $hostName

        }                        

        #Add file totals if switch is true
        if ($AddFileTotals) {

            $totalFiles = ($folderInfo | Where-Object {!$_.PSIsContainer}).Count
            $folderObject | Add-Member -MemberType NoteProperty -Name FileCount -Value $totalFiles

        }

        #Add the object to the array
        $folderList.Add($folderObject) | Out-Null

    }

    if ($AddTotal) {

        $grandTotal      = $null
        $grandTotalFiles = $null

        if ($folderList.Count -gt 1) {
        
            $folderList | ForEach-Object {
                
                if ($_.'Size(Bytes)' -gt 0) {

                    $grandTotal += $_.'Size(Bytes)'

                }                  
            }

            $totalFolderSizeInMB = [math]::Round($grandTotal / 1MB, 2)
            $totalFolderSizeInGB = [math]::Round($grandTotal / 1GB, 2)

            $folderObject = [PSCustomObject]@{

                FolderName    = "GrandTotal for [$BasePath]"
                'Size(Bytes)' = $grandTotal
                'Size(MB)'    = $totalFolderSizeInMB
                'Size(GB)'    = $totalFolderSizeInGB
                FullPath      = 'N/A'                
                HostName      = $hostName

            }

            if ($AddFileTotals) {

                $folderList | ForEach-Object {

                    $grandTotalFiles += $_.FileCount   
    
                }

                $folderObject  | 
                    Add-Member -MemberType NoteProperty -Name FileCount -Value $grandTotalFiles

            }

            #Add the object to the array
            $folderList.Add($folderObject) | Out-Null

        }   
    }
    
    if ($Output -or $OutputFile) {

        if (!$OutputFile) {

            $fileName = "{2}\{0:MMddyy_HHmm}.{1}" -f (Get-Date), $Output, $OutputPath

        } else {

            $fileName = $OutputFile
            $Output   = $fileName.Substring($fileName.LastIndexOf('.') + 1) 


        }
       
        Write-Verbose "Attempting to export results to -> [$fileName]!"

        try {

            switch ($Output) {

                'csv' {
    
                    $folderList | Sort-Object 'Size(Bytes)' -Descending | Export-Csv -Path $fileName -NoTypeInformation -Force
    
                }
    
                'xml' {
    
                    $folderList | Sort-Object 'Size(Bytes)' -Descending | Export-Clixml -Path $fileName
    
                }
    
                'json' {
    
                    $folderList | Sort-Object 'Size(Bytes)' -Descending | ConvertTo-Json | Out-File -FilePath $fileName -Force
    
                }
    
            } 
        } 

        catch {

            $errorMessage = $_.Exception.Message

            Write-Error "Error exporting file to [$fileName] -> [$errorMessage]!"

        }
      
    }

    #Return the object array with the objects selected in the order specified.
    Return $folderList | Sort-Object 'Size(Bytes)' -Descending

}

function Get-FolderList {
    [cmdletbinding()]
    param(
        [string[]]
        $FolderName,

        [string[]]
        $BasePath,

        [string[]]
        $OmitFolders,

        [string[]]
        $FindExtension
    )
    
    #All folders and look for files with a particular extension
    if ($FolderName -eq 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem -LiteralPath $BasePath -Force -Recurse | 
            Where-Object {
                ($OmitFolders -notcontains $_.FullName ) -and 
                ($FindExtension -contains $_.Extension )
            }                

    #All folders
    } elseif ($FolderName -eq 'all') {

        $allFolders = Get-ChildItem -LiteralPath $BasePath -Force | 
            Where-Object {
                $OmitFolders -notcontains $_.FullName
            }

    #Specified folder names and look for files with a particular extension
    } elseif ($FolderName -ne 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem -LiteralPath $BasePath -Force -Recurse | 
            Where-Object {
                ($_.FullName -match ".+$FolderName.+")   -and 
                ($OmitFolders -notcontains $_.FullName) -and 
                ($FindExtension -contains $_.Extension)
            } 
            
    } else {

        $allFolders = Get-ChildItem -LiteralPath $BasePath -Force | 
            Where-Object {
                ($_.BaseName -match "$FolderName") -and 
                ($OmitFolders -notcontains $_.FullName)
        }
    }

    
    $splitPath = Split-Path $BasePath
    
    #Test for null, return just folder if no subfolders
    if (!($allFolders) -and (Test-Path -Path $splitPath -ErrorAction SilentlyContinue)) {
        
        $findName   = Split-Path $BasePath -Leaf        
        $allFolders = Get-ChildItem -LiteralPath $splitPath | 
            Where-Object {
                $_.Name -eq $findName
            }
                
    }

    return $allFolders

}

function Get-FileReport { #Begin function Get-FileReport
    [cmdletbinding(
        DefaultParameterSetName = 'default'
    )]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default'
        )]
        [Alias('Path')]
        [String[]]
        $BasePath = (Get-Location),        

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'default'
            
        )]
        [String[]]
        $FindExtension = @('.exe','.msi'),

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'default'
            
        )]
        [String[]]
        $FolderName = 'all',

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String[]]
        $OmitFolders,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Switch]
        $AddTotal,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [ValidateSet('csv','xml','json')]
        [String]        
        $Output,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [String]
        $OutputPath = (Get-Location),

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String]
        $OutputFile = [string]::Empty
    )

    #Get a list of all the directories in the base path we're looking for.
    $allFolders = Get-FolderList -FolderName $FolderName -FindExtension $FindExtension -OmitFolders $OmitFolders -BasePath $BasePath

    $foundFiles = $null

    #Create array to store folder objects found with size info.
    [System.Collections.ArrayList]$fileList = @()

    #Go through each folder in the base path.
    ForEach ($file in $allFolders) {

        #Clear out the variables used in the loop.      
        $fullPath      = $null        
        $folderObject  = $null
        $fileSize      = $null
        $fileSizeInMB  = $null
        $fileSizeInGB  = $null
        $fileName      = $null

        #Store the full path to the folder and its name in separate variables
        $fullPath = $file.FullName
        $fileName = $file.BaseName     

        Write-Verbose "Working with [$fullPath]..."            

        #Get folder info / sizes
        $fileSize = $file.Length 
            
        #We use the string format operator here to show only 2 decimals, and do some PS Math.
        [double]$fileSizeInMB = "{0:N2}" -f ($fileSize / 1MB)
        [double]$fileSizeInGB = "{0:N2}" -f ($fileSize / 1GB)

        #Here we create a custom object that we'll add to the array
        $folderObject = [PSCustomObject]@{

            PSTypeName    = 'PS.File.List.Result'
            FileName      = $fileName
            'Size(Bytes)' = $fileSize
            'Size(MB)'    = $fileSizeInMB
            'Size(GB)'    = $fileSizeInGB
            FullPath      = $fullPath

        }                        

        #Add the object to the array
        $fileList.Add($folderObject) | Out-Null

    }

    if ($AddTotal) {

        $grandTotal = $null

        if ($fileList.Count -gt 1) {
        
            $fileList | ForEach-Object {

                $grandTotal += $_.'Size(Bytes)'    

            }

            [double]$totalFolderSizeInMB = "{0:N2}" -f ($grandTotal / 1MB)
            [double]$totalFolderSizeInGB = "{0:N2}" -f ($grandTotal / 1GB)

            $folderObject = [PSCustomObject]@{

                FileName      = "GrandTotal for [$fullPath]"
                'Size(Bytes)' = $grandTotal
                'Size(MB)'    = $totalFolderSizeInMB
                'Size(GB)'    = $totalFolderSizeInGB
                FullPath      = 'N/A'

            }

            #Add the object to the array
            $fileList.Add($folderObject) | Out-Null
        }   

    }

    if ($Output -or $OutputFile) {

        if (!$OutputFile) {

            $fileName = "{2}\{0:MMddyy_HHmm}.{1}" -f (Get-Date), $Output, $OutputPath

        } else {

            $fileName = $OutputFile
            $Output   = $fileName.Substring($fileName.LastIndexOf('.') + 1) 


        }
    
        Write-Verbose "Attempting to export results to -> [$fileName]!"

        try {

            switch ($Output) {

                'csv' {

                    $fileList | Sort-Object 'Size(Bytes)' -Descending | Export-Csv -Path $fileName -NoTypeInformation -Force

                }

                'xml' {

                    $fileList | Sort-Object 'Size(Bytes)' -Descending | Export-Clixml -Path $fileName

                }

                'json' {

                    $fileList | Sort-Object 'Size(Bytes)' -Descending | ConvertTo-Json | Out-File -FilePath $fileName -Force

                }

            } 
        } 

        catch {

            $errorMessage = $_.Exception.Message

            Write-Error "Error exporting file to [$fileName] -> [$errorMessage]!"

        }
    
    }

    #Return the object array with the objects selected in the order specified.
    Return $fileList | Sort-Object 'Size(Bytes)' -Descending

} 

function Get-RoboSize {
    [cmdletbinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [string]
        $Path,

        [Parameter(
        Mandatory = $false
        )]
        [int]
        $DecimalPrecision = 2,

        [Parameter(
        Mandatory = $false
        )]
        [int]
        $Threads = 16
    )

    if (Get-Command -Name 'robocopy') {

        Write-Verbose -Message "Using robocopy to get size of path -> [$Path]"

        $args = @("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0","/MT:$Threads")

        [DateTime]$startTime = [DateTime]::Now

        Write-Verbose "Running -> [robocopy $($Path) NULL $($args)] <-"
        [string]$summary     = robocopy $Path NULL $args | Select-Object -Last 8
        [DateTime]$endTime   = [DateTime]::Now
        [regex]$headerRegex  = '\s+Total\s*Copied\s+Skipped\s+Mismatch\s+FAILED\s+Extras'
        [regex]$dirRegex     = 'Dirs\s*:\s*(?<DirCount>\d+)(?:\s+\d+){3}\s+(?<DirFailed>\d+)\s+\d+'
        [regex]$fileRegex    = 'Files\s*:\s*(?<FileCount>\d+)(?:\s+\d+){3}\s+(?<FileFailed>\d+)\s+\d+'
        [regex]$byteRegex    = 'Bytes\s*:\s*(?<ByteCount>\d+)(?:\s+\d+){3}\s+(?<BytesFailed>\d+)\s+\d+'
        [regex]$timeRegex    = 'Times\s*:\s*(?<TimeElapsed>\d+).*'
        [regex]$endRegex     = 'Ended\s*:\s*(?<EndedTime>.+)'

        Write-Verbose "Raw summary:"
        Write-Verbose ($summary | Out-String)
        $expectedSummary = "$headerRegex\s+$dirRegex\s+$fileRegex\s+$byteRegex\s+$timeRegex\s+$endRegex"
        if ($summary -match $expectedSummary) {

            $roboObject = [PSCustomObject]@{
                
                Path        = $Path
                TotalBytes  = [decimal] $Matches['ByteCount']
                TotalMB     = [math]::Round(([decimal] $Matches['ByteCount'] / 1MB), $DecimalPrecision)
                TotalGB     = [math]::Round(([decimal] $Matches['ByteCount'] / 1GB), $DecimalPrecision)
                TimeElapsed = [math]::Round([decimal] ($endTime - $startTime).TotalSeconds, $DecimalPrecision)

            }

            return $roboObject

        }

    } else {

        throw "Robocopy command is not available... cannot continue!"

    }
}


$scriptpath = "C:\Users\gnfk\Desktop\SMDI\0-Powershell\Tamanho_Arquivos\3.0"
$Computers = Get-Content ($scriptpath + "\Computer.ini")
$Arquivos = Get-Content ($scriptpath + "\Caminhos.ini")


Foreach ( $arquivo in $Arquivos ) {
    
    Get-FolderSize -BasePath $Arquivo | Format-Table -AutoSize # | Export-Csv $scriptpath\Report.csv -Encoding UTF8 -Append

}