#Use filters to get the needed info from get-adcomputer
Get-ADComputer -Filter * -Properties OperatingSystem | Select OperatingSystem -unique | Sort OperatingSystem
Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties OperatingSystem `
| Select Name,OperatingSystem | Format-Table -AutoSize


#Properties available on srv1-ad for get-adcomputer cmdlet
Get-ADComputer -Identity srv1-ad -Properties *
Get-ADComputer -Identity srv1-ad -Properties distinguishedname | select distinguishedname

#number of months will be subtracted from current date and will be used to determine 
#######which systems have not logged on, after a specified date
$a = Read-host "Enter number of Months for testing (0 for current date)"

(get-date).addmonths(-$a) #go back a months from current date

$result = Get-adcomputer -properties lastLogondate -filter * `
| where {$_.lastlogondate -lt (get-date).addmonths(-$a)} | sort Name | ft Name,Lastlogondate -AutoSize

$result | out-file c:\win500\lab8\old_systems.txt 
gc c:\win500\lab8\old_systems.txt

#Remove systems from AD, that have not log on in the last $a months
write-host
$test = Read-Host "Do you want to delete these systems from Active Directory? (Yes or No)"
If ($test -eq "Yes") {
  Get-adcomputer -properties lastLogondate -filter * | where {$_.lastlogondate -lt (get-date).addmonths(-$a)} | `
  Remove-ADComputer -WhatIf
  Write-Host "System(s) deleted"
}
#What if: Performing the operation "Remove" on target "CN=SRV1-AD,OU=Domain Controllers,DC=fdauti,DC=loc".


#Exercise 1 Script ##############################
$a = Read-host "Enter number of Months for testing (0 for current date)"

#Get the systems that have not log on in the last $a months
$result = Get-adcomputer -properties lastLogondate -filter * `
| where {$_.lastlogondate -lt (get-date).addmonths(-$a)}

#Get the distingushedname of system and output to txt file
$result.distinguishedname | out-file c:\win500\lab8\old_systems.txt 

write-host
$delete = Read-Host "Do you want to delete these systems from Active Directory? (Yes or No)"
If ($delete -eq "Yes") {
  $systems = gc c:\win500\lab8\old_systems.txt
  foreach ($system in $systems) {
    Remove-ADComputer -Identity $system -WhatIf
  }
  Write-Host "System(s) deleted"
}


#pre-register a computer in Active Directory by manually adding it with PS with specific options
New-ADComputer -Name "Server1" -SamAccountName "Server1" -WhatIf
New-ADComputer -Name "Server2" -SamAccountName "Server2" -location "Main Floor" 
New-ADComputer -name "Server3" -SamAccountName "Server3" -AccountPassword (Read-Host -AsSecureString "AccountPassword")
Remove-ADComputer -Identity Server1 -WhatIf

#add 5 servers
foreach ($system in 1..5 ) 
{
  #set the domain
  $domain = "CN=Computers,DC=fdauti,DC=loc" 
  #create the system name
  $Label ="MainFloor" + $system
  #create the new computer. Note: All systems will be disabled due to non-entry of password
  New-AdComputer -name $Label -SamAccountName $Label -Path $domain -enable $True -location "Toronto"
}

#set the location and do not allow the password to expire
Set-ADComputer "Server1" -PasswordNeverExpires $true -Location "Second floor server room" -confirm 


################# Working with Ad Groups ##############################
New-ADGroup -Name "Male Supers" -SamAccountName MaleSupers -GroupCategory Security -GroupScope Global `
-DisplayName "Male Superheros" -Path "CN=Users,DC=fdauti,DC=loc" -Description "Members of this group are superheros"
New-ADGroup -Name "Female Supers" -SamAccountName FemaleSupers -GroupCategory Security -GroupScope Global `
-DisplayName "Female Superheros" -Path "CN=Users,DC=fdauti,DC=loc" -Description "Members of this group are superheros"

get-member -InputObject Set-ADComputer
#Change gorup description and output on screen
Set-ADGroup MaleSupers -Description "These are male super heros" -passthru

#Show all group properties
get-adgroup -Identity MaleSupers -Properties *

#Change in bulk by using a filter to select find all groups with the word Super
get-adgroup -filter {name -like "*Supers"} | set-adgroup -description "Super Heros"

$oldname = Get-ADGroup MaleSupers | select -Property samaccountname
$newname = $oldname.samaccountname + "New"
Set-ADGroup MaleSupers -SamAccountName $newname

# Do the above in one command
Set-ADGroup MaleSupers -SamAccountName ((Get-ADGroup MaleSupers | select -Property samaccountname).samaccountname + "New")


#Deleate groups from a txt file
$delgroups = get-content C:\win500\lab8\groups.txt
$delgroups | Get-ADGroup -Properties ProtectedFromAccidentalDeletion
$delgroups | Set-ADObject -ProtectedFromAccidentalDeletion $false
$delgroups | Remove-ADGroup -WhatIf

#Long version
$groups = Get-adgroup -filter {name -like "*Supers"} | select -Property samaccountname
$groups.samaccountname | out-file C:\win500\lab8\groups.txt 

$delgroups = gc C:\win500\lab8\groups.txt
foreach ($group in $delgroups) {

  if ((Get-ADGroup $group | select -Property ProtectedFromAccidentalDeletion).ProtectedFromAccidentalDeletion) {
    Set-ADObject $group -ProtectedFromAccidentalDeletion $false
  }
  
  Remove-ADGroup $group -whatif
}

#Add users to group 
Add-ADGroupMember MaleSupersNew -Members user1,user2

#get users from one group and add to another group
$usersnames = Get-ADGroupMember MaleSupersNew
Add-ADGroupMember FemaleSupers -Members $usersnames.SamAccountName

Get-ADUser user1 -Properties *
#Import users from CSV files for newadUsers.csv ############################
$newadusers = Import-CSV "C:\win500\lab8\newadUsers.csv" 
$newadusers | New-ADUser -PassThru -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)

foreach ($user in $newadusers) {
  Enable-ADAccount $user.SamAccountName  
  Add-ADGroupMember FemaleSupers -Members $user.SamAccountName -PassThru
}

#remove a member from the SalesGroup group
Get-ADGroupMember FemaleSupers | select -Property name,samaccountname
Remove-ADGroupMember FemaleSupers -Members sanjay.patel #samaccountname
Get-ADUser -Filter * | select -Property Name,SamAccountName
Remove-ADUser brucebanner

#Get all of the members of the group
$group = Get-ADGroupMember FemaleSupers
#List the members
$group.SamAccountName
#Now delete the members
Foreach ($deluser in $group.SamAccountName){
	Remove-ADGroupMember FemaleSupers -Members $deluser -Confirm:$false 
}
