Function Main { 
  Get-HDInfo
  Get-PartitionInfo
  Show-Output
}

<#
    .SYNOPSIS
    Gets specific hard drive information
    .DESCRIPTION
    Get-HDInfo uses Get-CIMInstance to retrieve the PSComputername, DeviceID (C:,D:,etc), HD size and amount of freespace. 
    Both size and freespace are rounded to nearest GB. The info is saved to a CSV file called Report.csv
    $script:report stores the HDInfo 
    .Examples
    PS>ghd
    PS>ghd -name SRV2-SC -verbose
    .NOTES
    AuthorName: Fatjon Dauti
    DateLastModified: 02/2021
#>

function Get-HDInfo {

  [CmdletBinding()]
  Param()
   
  Begin
  {
    #Get hard coded computer names from file and store in variable
    $computer = gc .\computers.txt 
  }
  Process
  {
    #Retrieve Disk information and round size to GB
    $script:report = Get-CimInstance Win32_LogicalDisk -computername $computer | select PSComputerName,DeviceID, `
    @{Label='Size';Expression={[math]::round($_.Size/1GB)}},`
    @{Label='FreeSpace';Expression={[math]::round($_.FreeSpace/1GB)}}
  }    
  End
  {
    #Store file path in variable  
    $File = ".\report.csv"
    #Convert disk information to CSV format   
    $report | Export-CSV $File -NoTypeInformation
  } 
} #end of Get-HDInfo ##############################

<#
    .Synopsis
    Gets specific parition information
    .DESCRIPTION
    Get-PartitionInfo uses Get-CIMInstance to retrieve the PSComputername, Partition Name, Boolean value, 
    if it is a primary partition, partition size which is rounded to nearest GB. The info is saved to a file called CSV Report1.csv
    $script:report1 stores the PartitionInfo
    .NOTES
    Author: Fatjon Dauti
    DateLastModified: 02/2021
#>

function Get-PartitionInfo {

  [cmdletBinding()]
  param()
   
  Begin
  {
    # Get hard coded computer names from a file and save to variable
    $computer = gc .\computers.txt
  }
  Process
  {
    #Get Partition information for each computer and round size to GB
    $Script:Report1 = Get-CIMInstance Win32_DiskPartition -computername $computer `
    | Select PScomputername,Name,PrimaryPartition,`
    @{Label='Size';Expression={[math]::round($_.Size/1GB)}}
  }   
  End
  {
    #Create variables to store file path
    $File = ".\report1.csv"

    #Convert Partition information to CSV format
    $report1 | Export-CSV  $File -NoTypeInformation       
  }
} #end of Get-PartitonInfo ################

<#
    .Synopsis
    Displays hard Drive and partition format in table format in the browser
    .DESCRIPTION
    Displays hard Drive and partition format in table format in the browser
    .NOTES
    Author: Fatjon Dauti
    DateLastModified: 02/2021
#>

Function Show-Output {

  [cmdletBinding()]
  param()

  Begin
  {
    # Create variables for file path
    $file = ".\report.csv"
    $file1 = ".\report1.csv"

    #import the Disk and Partition CSV files and convert to HTML Tables only
    $WWW1 =  (Import-CSV  $file) | ConvertTo-html -fragment
    $WWW2 =  (Import-CSV  $file1) | ConvertTo-html -fragment

    #Create varabile to store HTML web page file
    $www = ".\Report.html"
  }
  Process
  {
    #Build web page line by line
    Write-output '<!!DOCTYPE html>' > $www
    Write-output '<head><title>System Inventory</title>' | Add-Content $WWW
    Write-output '<link rel="stylesheet" type="text/css" href=".\Table.css" />' | Add-Content $WWW
    Write-output '</head>' | Add-content $WWW
    write-output '<body>' | Add-content $WWW
    Write-output '<h1>System Inventory of MyDomain</h1>' | Add-content $www
    Write-output '<h5>Drive Information</h5>' | Add-content $www
    Write-output "$www1" | Add-Content $www
    Write-output '<BR>' | Add-content $www
    Write-Output '<h5>Partition Information</h5>' | Add-content $www
    Write-output "$www2" | Add-Content $www
    Write-output "prepared by IT services on <b>$(get-date -format D)</b>" | Add-content $www
    Write-output '</body></html>' | Add-content $www
  } 
  End
  {
    #Call browser to display web page
    Invoke-Item $www
  } 
} # end of Show-Ouput ###############

sl 'C:\Users\fotip\OneDrive - Seneca\Documents\WindowsPowerShell\Modules\DiskInfo'

####### Additional cmdlets to craete aliases ##########
New-Alias -name "ghd" -value "Get-HDInfo"
New-Alias -name "gpi" -value "Get-PartitionInfo"
New-Alias -name "sho" -value "Show-Output"

##### Export cmdlet to let PowerShell know how to import the module#####
#Load all functions and alias on memory
Export-ModuleMember -Function *  -Alias *

#Share only specific functions
#Export-ModuleMember -function Get-HDInfo,Get-PartitionInfo -alias ghd,gpi 

#Calling Main
. Main  




