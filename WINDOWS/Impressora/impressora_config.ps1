<#        
    .SYNOPSIS
     A brief summary of the commands in the file.

    .DESCRIPTION
    A detailed description of the commands in the file.

    .NOTES
    ========================================================================
         Windows PowerShell Source File 
         Created with SAPIEN Technologies PrimalScript 2016
         
         NAME: 
         
         AUTHOR:  , 
         DATE  : 03/02/2017
         
         COMMENT: 
         
    ==========================================================================
#>

$printer = Get-PrintConfiguration -ComputerName sbclps -PrinterName APYM
$printer

