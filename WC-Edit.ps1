# Open XML Data file
#$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$srcpath = "C:\temp\McAfee Stuff\PS-McAfeeWCPolicyEdits"
$DataPath = "$srcpath\SmallWCpolicy.xml"
#$DataPath = "$srcpath\LargeWCpolicy.xml"

if (Test-Path -path $datapath) {[xml]$dataFile = Get-Content $datapath;write-host "Got Datafile"}
else {write-host "Error with Datafile"}

$BALs = $dataFile.EPOPolicySchema.EPOPolicySettings.Section.Setting

$MaxCount = $($BALs | ? {$($_.name) -eq "uiSiteCount"}).value
write-host "max:" $maxcount


<#
$count = 0
do
{
    $site = $($BALs | ? {$($_.name) -eq $("szSite$count")}).value
    $pAction = $($BALs | ? {$($_.name) -eq $("Action$count")}).value
    $note   = $($BALs | ? {$($_.name) -eq $("szNote$count")}).value
    if ($pAction -eq 1) {$action = "Block"} else {$action = "Allow"}
    
    write-host "Entry :" $count
    write-host "URL   :" $site
    Write-host "Action:" $action
    write-host "Note  :" $note
    write-host
    $count++
} while ($count -le $($MaxCount-1))
#>