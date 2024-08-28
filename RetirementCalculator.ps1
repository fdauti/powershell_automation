<#
    .SYNOPSIS
    Retirement Calculator
    .DESCRIPTION
    A Menu will be displayed first using Here-String. The script will ask the user to input their birthday in the correct format. When the format is correct, the script will calculate the retirement age.
    The retirement age will be displayed in a different color.  The script will account for leap retirements years, by making the correct adjustment.
    .NOTES
    AuthorName: Fatjon Dauti
#>
#Set-StrictMode -Version Latest

Clear-Host
$Menu = @"
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
▒                                                              ▒
▒             Seneca Software Retirement Calculator            ▒
▒                                                              ▒
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
"@
Write-Host $Menu -ForegroundColor Green
''
$Pattern = '^\d{1,2}/\d{1,2}/\d{4}$'
do
{
  $Birth = Read-Host "Enter you birth date in the format [m/d/yyyy]"
}
until ($Birth -match $pattern)
''
$DateArray = $Birth.Split("/")

$Month = $DateArray[0]
$Day = $DateArray[1]
$Year = $DateArray[2]

if ($Month -eq 1 -or $Month -eq 3 -or $Month -eq 5 -or $Month -eq 7 -or $Month -eq 8 -or $Month -eq 10 -or $Month -eq 12){
    
    $DaysInMonth = 31
    $EndofMonth = $DaysInMonth - $Day
    
 } elseif ($Month -eq 4 -or $Month -eq 6 -or $Month -eq 9 -or $Month -eq 11){
 
     $DaysInMonth = 30
     $EndofMonth = $DaysInMonth - $Day
     
 } elseif ($Month -eq 2){
     
     $DaysInMonth = 28
     $EndofMonth = $DaysInMonth - $Day   
     
} else  {Write-Warning "Invalid month!";pause;break}

if ([datetime]::IsLeapYear([int]$Year + 67)) {

  $Month = 3
  $Day = 1
  $Retirement = (Get-Date -Day $Day -Month $Month -Year $Year).AddYears(67).ToString("dddd, MMMM dd, yyyy") 
  
} else { $Retirement = (Get-Date -Day $Day -Month $Month -Year $Year).AddDays($EndofMonth).AddYears(67).ToString("dddd, MMMM dd, yyyy") 
  }

Write-Host "You are eligible to retirement on: " -NoNewline
Write-Host "$Retirement" -BackgroundColor Black -ForegroundColor Yellow 
''
Write-Host "================================================================" -ForegroundColor Green