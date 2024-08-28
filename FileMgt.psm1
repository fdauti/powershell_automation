<#
    .SYNOPSIS
    Script for searching, creating and copying files.
    .DESCRIPTION
    A Menu will be displayed first. Based on user selection a corresponding function will be executed to carry the specified task. Menu automatically reappears after each selection, until the user presses 4 to exit.
    .NOTES
    AuthorName: Fatjon Dauti
    DateLastModified: 25 July 2020
#>
#Set-StrictMode -Version Latest


function Get-File
{
  param
  (
    [Parameter(Mandatory=$True, HelpMessage='Directory path where to search at', Position=0)]
    [String] $FileDirectory,
    [Parameter(Mandatory, HelpMessage='Type of files to search for, like docx or txt', Position=1)]
    [String] $FileExtension
  )
  ''
  if (Test-Path $FileDirectory) 
  {
    
    Write-Host "##############################################################" -ForegroundColor green
    Write-Host                 "`t`t`t`t`t Searching for files" -ForegroundColor green
    Write-Host "##############################################################" -ForegroundColor green
    
    Get-Childitem -Path $FileDirectory -Filter *.$FileExtension # -Recurse, to search recursively
    return
  } else {
    Write-Warning 'Directory does not exist, or path is invalid. Please, enter the correct path and try again!'
    return
  } Write-Output "Supply values for the following parameters:"

} # end of Get-File 

function Copy-File
{
  do
  {
    $SourceDir = Read-Host "Enter files to be copied from a source directory"
    if ($(Test-Path $SourceDir) -ne 'True') 
    {
      Write-Warning 'Source directory does not exist, or path is invalid. Please, enter the correct path again!'
      pause 
    } 
  }
  until (Test-Path $SourceDir)

  do
  {
    $DestinationDir = Read-Host "Enter destination directory"
    if ($(Test-Path $DestinationDir) -ne 'True') 
    {
      Write-Warning 'Destination directory does not exist, or path is invalid. Please, enter the correct path again!'
      pause
    } 
  }
  until (Test-Path $DestinationDir)
  ''
  Write-Host "##############################################################" -ForegroundColor green
  Write-Host                 "`t`t`t`t`t Copying files..." -ForegroundColor green
  Write-Host "##############################################################" -ForegroundColor green
 
  Copy-Item -Path $SourceDir -Destination $DestinationDir -PassThru #-Recurse , if needed to copy recursively

} # end of Copy-File

function New-File
{
  $FileName = Read-Host "Enter the file name to be created"
  $FilePath = Read-Host "Enter the directory path where files should be created"

  if ($(Test-Path $FilePath) -ne 'True') 
  {
    Write-Warning 'Directory does not exist, or path is invalid. Please, enter the correct path again!'
    return
  } 

  $FileNumber = Read-Host "Enter the number of files to be created"
  ''
  if ($FileNumber -gt 0)
  {
    Write-Host "##############################################################" -ForegroundColor green
    Write-Host                 "`t`t`t`t`t Creating new files" -ForegroundColor green
    Write-Host "##############################################################" -ForegroundColor green
    
    for ($x = 1; $x -le $FileNumber; $x++) 
    {
      #if (Test-Path $FileName$x) {"File already exists!";break}  #This will not create any file at all, if at least one  file with the same name exist
      New-Item -Path $FilePath -Name $FileName$x -ItemType File
    }
  } else {Write-Warning 'You must select at least one file to be created.';return}

} # end of New-File

function Get-MenuHelper
{

  $Menu = @"
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
▒                                         ▒
▒             File Management             ▒
▒                                         ▒
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
▒                                         ▒
▒            1 Search file(s)             ▒
▒            2 New file(s)                ▒
▒            3 Copy file(s)               ▒
▒            4 Exit program               ▒
▒                                         ▒
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
"@

  do
  {
    Clear-Host
    ''
    Write-Host $Menu -ForegroundColor Green
    ''
    $Selection = Read-Host "Enter a number [1-4]"
    ''
    Switch ($Selection) 
    {
      '1' {Get-File;pause;break} 
      '2' {New-File;pause;break}
      '3' {Copy-File;pause;break}
      '4' {"Exiting program...";return}
      Default {Write-Warning "Invalid Selection. Enter a valid choice!";pause}
    }
  } until ($Selection -eq 4)
  
} #end of Get-MenuHelper

function Show-Menu
{
  Get-MenuHelper
  
} #end of Show-Menu

Export-ModuleMember -function *

#Import-Module FileMgt -Force -Verbose