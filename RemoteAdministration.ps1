##############################################################################################################################
#WinRm Full object sent, Partial object returned
#if time do the following on win10-ws
$listing = Get-ChildItem c:\
$listing | Get-Member | Where {$_.Definition -match "System.IO.DirectoryInfo"} #notice System.IO.DirectoryInfo object and 20+ properties and methods

#This code needs to be copied to the client pc
#Now send the same command to srv1-ad using invoke command and pipe to Export-CLiXML
Invoke-command -computername srv1-ad -scriptblock {
  gci c:\ | Export-CliXml "$home\documents\winrm.xml"
} -credential fdauti\fdauti  #notice login box pops up to enter domain admin credentials

#from the server, import the commands output from Export-CliXML
Import-CLiXML .\winrm.xml  #notice command output is completed

#look at what type of object would be returned to win10-ws
import-CLiXML .\winrm.xml | Get-Member  #notice Deserialized.System.IO.DirectoryInfo object returned with properties, but only 2 methods

#Onehop rule
#this code needs to be copied to Server
Enter-PSsession -computername srv1-ad -credential fdauti\fdauti  #allowed
#from client connection type
invoke-command -computername srv1-sc -scriptblock {get-process} -credential fdauti\fdauti #allowed - 1st hop

invoke-command -computername srv1-sc -scriptblock {invoke-command -computername win10-ws -scriptblock {get-process}} #not allowed 2nd hop

##############################################################################################################################
# this code needs to be copied to win10-ws
# Enter-PSsession -interactive session -ideal for troubleshooting
Enter-PSsession -ComputerName srv1-ad -credential fdauti\administrator  #domain admin credentials needed to connect to DC
#notice connected computer name in the prompt
Test-Path .\users\pubic\logo.jpg  #true
#exit alias for Exit-PSsession

#invoke-command -multipurpose tool ideal for running remote commands on one to more computers
invoke-command -ComputerName sc-server -ScriptBlock {get-service | ? {$_.Status -eq "Running"}} -credential fdauti\administrator

#############################################################################################################################

#This code needs to be copied to s1-server
#Test if computer is online and create a log file of online computers.
#Example 1

 Function Test-online {
  #get computer names, file on win10-ws
  $computers = get-content .\PCs.txt
  #create log file
  $online = '.\pingup.log'
  $offline = '.\pingdown.log'
  
  foreach($computer in $computers){
    #test connection returns true with quiet parameter
    if (Test-connection -computername $computer -Count 1 -quiet)  {
       Write-host "$computer is online _____________" -ForegroundColor green
       $computer | Out-file -append $online
     } else {
       Write-host "$computer offline ______________" -ForegroundColor red 
       $computer | Out-file -append $offline     
     } 
  } 
} #end of Test-online

#############################################################################################################################
# This code needs to be copied to win10-ws
# Get content of online computers and send command using invoke to find PowerSehll processes
#Example 2

 #get content of pingup.log
 $PCs = get-content '.\pingup.log'

 $PoWerShellInfo = invoke-command -ComputerName $PCs -scriptblock {
        Get-Process | ? {$_.name -like "Pow*"} | select PScomputername,processname,ID }   

#############################################################################################################################

#passing Parameters with the copy-item command
#This code needs to be copied to c1-server - load function into memory before running examples

Function Send-File {

  param (
    [string] $source,
    [string] $destination
  )

  Copy-item $source -destination $destination -passthru
} #end of Send-File

#############################################################################################################################
#This code needs to be copied to the win10-ws
#Example 1- copying local file to remote host - push scenario
Send-File .\*.txt  \\srv1-ad\homedir\win10-ws\ #note destination is UNC path

#Example 2- copying local file on srv1-ad from one directory to another - note copy code to win10-ws 
#Shows how to pass Get-Credential as an argument to credential parameter
invoke-command -computername srv1-ad -credential (Get-Credential) -scriptblock ${function:Send-File} -argumentlist 'c:\homedir\*.txt','C:\' 

#Example 3 - copying remote file to local host-pull scenario
#this code needs to be copied to win10-ws
Send-File '\\srv1-ad\homedir\win10-ws\pcs.txt' -destination 'c:\pcs2.txt' #note source is UNC path

#############################################################################################################################
#Credentals -get-credential
invoke-command -ComputerName localhost -Credential Administrator -scriptblock {gci c:\}
#Read-host
$MyCredential = Read-Host -prompt "Enter password" -AsSecureString #password masked 
($MyCredential.GetType()).FullName #system.security.securestring


##############################################################################################################################
#CSV Files and convert to HTML
##############################################################################################################################
# CSV example - creating
#you can manually type the file as we did here or create a hash table which is easily converted to CSV
# I often use EXCEL to create the file and then save the file as a CSV file.
# OR to create CSV in code use this example
#hash tables do not allow duplicates, therefore you must create an array of hash tables, and for each record
#we use the [pscustomobject] data type because that is the type used by PowerShell to create CSV files

$SenecaInventory = @(

  [pscustomobject]@{

    Department = 'Administration'
    Computer = 'Server01'
    Email = 'rbaker@seneca.ca'

  }
  [pscustomobject]@{

    Department = 'Registrar'
    Computer = 'PC05'
    Email = 'sabraham@seneca.ca'

  }
  [pscustomobject]@{

    Department = 'Faculty'
    Computer = 'Server07'
    Email = 'msaul@seneca.ca'

  }
  [pscustomobject]@{

    Department = 'Support'
    Computer = 'PC09'
    Email = 'dpansear@seneca.ca'

  }

) 

#after creating array of hash tables pass the variable to Export-CSV - it will automatically create the column headings
#the NoTypeInformation parameter must be used to prevent PowerShell from placing object type on the first line which prevents it from being imported properly.
#IMPORTANT - Export-CSV will overwrite any existing file of the same name -without warning!!

$SenecaInventory | Export-CSV -path '.\weekly\w11\wk11_CSV.csv' -NoTypeInformation
gc '.\weekly\w11\wk11_CSV.csv'
help Export-Csv -Parameter * # -delimiter ";"

#Created CSV file without the NoTypeInformation Parameter ########################################################################################

$SenecaInventory | Export-CSV -path '.\weekly\w11\wk11_CSV.csv'
Invoke-item '.\weekly\w11\wk11_CSV.csv'

#############################################################################################################################
# Accessing CSV using dot notation - first import to a variable using Import-CSV

$SenecaInventory = Import-CSV '.\weekly\w11\wk11_CSV.csv'

#whole inventory
$SenecaInventory
#last record -array notation
$SenecaInventory[-1]
#third record
$SenecaInventory[2]
#All Department
$SenecaInventory.Department
#First department
$SenecaInventory.Department[0]
#all email
$SenecaInventory.Email
#first email
$SenecaInventory.Email[0]

#############################################################################################################################
#adding elements - use hash table with [pscustomobject]

[pscustomobject] @{
  Department = 'Media Arts'
  Computer = 'Server20'
  Email = 'drogers@seneca.ca'
 } | Export-CSV  -Append '.\weekly\w11\wk11_CSV.csv'

 #to see the result use import-CSV
 $SenecaInventory = import-CSV '.\weekly\w11\wk11_CSV.csv'
 $SenecaInventory #media arts record added

#remove elements
$SenecaInventory | ? {$_.Department -notlike "Media*" } | Export-CSV -Path '.\weekly\w11\wk11_CSV.csv' -NoTypeInformation
Invoke-item '.\weekly\w11\wk11_CSV.csv'

#sorting elements
$SenecaInventory = $SenecaInventory | Sort-Object -property Department
$SenecaInventory

###########################################################################################################################
#CSV: Invoke example 3 - convert to CSV
###########################################################################################################################

 $WinInfo = Get-Process | ? {$_.name -like "win*"} 
 $WinInfo = Get-Process | ? {$_.name -eq "winword"} 
 $WinInfo = Get-Process | ? {$_.name -match '^win'} 
        
 $WinInfo | select ProcessName,ID,CPU | Export-CSV '.\weekly\w11\wininfo.csv' -NoTypeInformation

############################################################################
# invoke example 4 - converting CSV to HTML

 $WinProcess = Import-Csv '.\weekly\w11\wininfo.csv'
 $WinProcess | ConvertTo-HTML | Out-file '.\weekly\w11\powershell.html'
 invoke-item '.\weekly\w11\powershell.html'
 
 ###########################################################################
 # invoke example 4 - converting CSV to HTML using inline CSS style sheet
 # note part of lecture, may wish to add to assignment - shows how to add style sheet - creates a pretty table

 $WinProcess = Import-CSV '.\weekly\w11\wininfo.csv'
 #Create style sheet for web page
 $header = @"
  <style>
 TABLE {border-width:2px; border-sytle:solid; border-color:black; border-collapse:collapse}
 TH    {border-width:2px; padding:5px; border-style:solid; border-color:black; background-color:#bde9ba}
 TD    {border-width:2px; padding:5px; border-style:solid; border-color:black}
 </style>
"@

#create web page
$WinProcess | ConvertTo-HTML -property ProcessName,ID,Cpu -head $header -PreContent "<H3>Seneca Inventory as of $(Get-Date)</H3>" -PostContent "Prepared by Seneca IT" | Out-file '.\weekly\w11\powershell.html'
invoke-item '.\weekly\w11\powershell.html'


#############################################################################################################
#Tee-Object and PassThru
#############################################################################################################

Get-Process notepad | Stop-Process | Out-File ".\Weekly\w11\tee.txt"
gc ".\Weekly\w11\tee.txt" #empty

Get-Process notepad | Tee-Object -FilePath ".\Weekly\w11\tee.txt" | Stop-Process

Get-Process notepad | Stop-Process -PassThru > ".\Weekly\w11\tee.txt"


#Write a command to create an interactive session to Server-S16. Design your command to pass the prompt the user for  user name and password.

Enter-PSsession -ComputerName srv1-ad -credential (Get-Credential)

#Change to your documents folder. Write a command which will get a directory listing of only text files (use the filter parameter) and convert the contents to a CSV file called txtlist.csv

gci -Filter *.txt | Export-Csv txtlist.csv -NoTypeInformation
Invoke-Item txtlist.csv

#Type Start-Process Notepad. Using the passthru parameter, stop the notepad process and log the result in a log file called kill.log

Start-Process notepad 
get-process notepad | Stop-Process -PassThru > notepadkill.log
gc .\notepadkill.log