# we can use -Quiet parameter to return True if connection is alive
# we can create an array with the list of computers to test

# if we log as the domain admin, there is no need to supply the credential to run remoting commands

$computers = @("win10-ws", "srv1-ad", "srv2-sc")

foreach ($computer in $computers){
  if (Test-connection -computername $computer -quiet)  {
    New-PSSession -ComputerName $computer #-Credential fdauti\fdauti
  } 
 } 