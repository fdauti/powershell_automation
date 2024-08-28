######### FIREWALL ##########################
Import-module netsecurity
Get-command -module netsecurity	 | ? {$_.name -like "*firewall*"} 

#Modify the public profile or all profile of the firewall from true to false
Set-NetFirewallProfile -profile public -enabled False
Set-NetFirewallProfile -All -enabled False
Set-netfirewallprofile -profile Domain,Private -enabled True

##########verify firewall status on local and remote computers
Get-NetFirewallProfile -all | ? {$_.enabled -eq "false"} | select -Property Name,Enabled
Get-NetFirewallProfile -Name Domain

Invoke-command -computername SRV2-SC -scriptblock {Get-NetFirewallProfile}
Invoke-command -computername SRV2-SC -scriptblock {get-netfirewallprofile -profile public | ? {$_.enabled -eq "False"}}	
$FW = New-CIMsession -computername SRV1-AD,SRV2-SC
Get-NetFirewallProfile -CIMsession $FW | ? {$_.enabled -eq "True"} | select -property PScomputername

#create a new rule to allow ping on domain and private profiles
New-NetFirewallRule -Name Allow_Ping `
  -DisplayName "Allow Ping" -Description "Packet Internet Groper ICMPv4" `
  -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Domain,Private -Action Allow

###########create firewall rule on remote computers
$cred = Get-Credential -Credential fdauti.loc\fdauti
$CN = get-adcomputer -filter 'name -like "*SC"' # note use of single quotes with double quotes.

$CIM = New-CimSession -ComputerName $CN.name -Credential $cred 
New-NetFirewallRule -Name Allow_Ping -DisplayName "Allow Ping" -Description "Packet Internet Groper ICMPv4" `
  -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Domain,Private -Action Allow -CimSession $CIM

#Verify if the firewall rule was created on the remote machine
Get-NetFirewallRule -DisplayName "Allow Ping" -CimSession $CIM |
  Select PSComputerName, name, enabled, profile, action | ft -AutoSize

#Test if ping is working
Test-Connection -ComputerName $CIM.computername -BufferSize 15 -Count 1


######Allow telnet access through the firewall for a remote server for group Deve
$FW = New-CIMsession -computername SRV2-SC
New-NetFirewallRule -CIMsession $FW -DisplayName "Allow Inbound Telnet" `
-Direction Inbound -Program %SystemRoot%\System32\telnet.exe -Action Allow -Group "Deve"

Get-CimSession
Remove-CimSession -Name *

#display allowed programs
get-netfirewallrule -action allow | select displayname -last 4

######### Group Policy ######################

Get-GPO -all #Get a list of grop polices in the domain (2 by default)
Get-GPOReport -all -domain fdauti.loc -ReportType HTML -Path C:\win500\lab9\GPOReport1.html

######### ENDPOINTS ##########################
Get-PSsessionConfiguration -name Microsoft.powerShell | select *

##### Related to using a startup script for creating an endpoint

#configuration file must be registered before it can be used
Register-PSSessionConfiguration -Name fdauti_lab9ex1 -StartupScript "C:\win500\lab9\usertest.pssc\startup_script.ps1" -force
#-ShowSecurityDescriptorUI -Force -runascredential fdauti.loc\fdauti

#set the users allowed to execute the Endpoint and display\change permissions
Set-PSSessionConfiguration -Name fdauti_lab9ex1 -ShowSecurityDescriptorUI -Force
Get-PSsessionConfiguration -name fdauti_lab9ex1

#go back to the PowerShell console default by unregistering the endpoint
Unregister-PSsessionConfiguration -name fdauti_lab9ex1  


##### create a default config. file to start from, test it then register it
New-PSsessionConfigurationFile -path "C:\win500\lab9\fdauti_Lab9_Ex1.pssc" 
Test-PSSessionConfigurationFile -Path "C:\win500\lab9\fdauti_Lab9_Ex1.pssc" 

Register-PSSessionConfiguration -name fdauti_lab9ex1 -path "C:\win500\lab9\fdauti_Lab9_Ex1.pssc" -Force


#### From Win10-WS run the endpoint created above, while still registered
Enter-pssession -computername SRV1-AD -configurationname lab9ex1 #-credential fdauti.loc\fdauti
