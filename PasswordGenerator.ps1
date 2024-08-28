 <#
      .SYNOPSIS
       Generate random passwords for a group of users.
      .DESCRIPTION
       The script generates 8-characters random passwords for all users present in the file Lab5_Users.txt
       The script will exit if the file is not present in the "$Home\Documents\Win213\" directory.
      .NOTES
        AuthorName: Fatjon Dauti
        DateLastModified: 26 July 2020
  #>
 #Set-StrictMode -Version Latest

 $SourceFile = "$Home\Documents\Win213\Lab5_Users.txt"
 if ($(Test-Path $SourceFile) -ne 'True') 
  {
    Write-Warning "File $SourceFile not found, or path is invalid!"
    pause;return 
  } 
 
 $Users = Get-Content $SourceFile  #$Users.GetType()

 $passwords = @()
 $passwords = for ($i=0; $i -lt $users.count; $i++) 
  {
   $array1 = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
   $array2 = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
   $array3 = @("0","1","2","3","4","5","6","7","8","9")
   $array4 = @("!","@","#","$","%","%","&","*","+","?")
 
   $RandomArray1 = $array1 | Get-Random -Count 3
   $RandomArray2 = $array2 | Get-Random -Count 2
   $RandomArray3 = $array3 | Get-Random -Count 2
   $RandomArray4 = $array4 | Get-Random -Count 1
 
   $password = $RandomArray1 + $RandomArray2 + $RandomArray3 + $RandomArray4
   -join $password 
  }

 $OutString = foreach ($password in $passwords) 
  {
   $inputstring = $password.ToString().ToCharArray()
   $scrambled = $inputstring | Get-Random -count $inputstring.count
   $scrambled -join ""
  }

 $UserCredentials = @{}
 for ($i=0; $i -lt $users.count; $i++) 
  {
   $UserCredentials.Add($Users[$i],$OutString[$i])
  }
  
 $UserCredentials