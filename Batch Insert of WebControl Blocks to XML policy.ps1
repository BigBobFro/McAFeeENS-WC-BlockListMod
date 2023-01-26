# Open XML Data file
#$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$srcpath = "C:\temp\McAfee Stuff\PS-McAfeeWCPolicyEdits"
$DataPath = "$srcpath\SmallWCpolicy.xml"
#$DataPath = "$srcpath\LargeWCpolicy.xml"

if (Test-Path -path $datapath) {[xml]$dataFile = Get-Content $datapath;write-host "Got Datafile"}
else {write-host "Error with Datafile"}


$BALs = $dataFile.EPOPolicySchema.EPOPolicySettings.Section.Setting

$NextNum = $($BALs | ? {$($_.name) -eq "uiSiteCount"}).value
write-host "max:" $nextnum

$inc = "INC3848217"

$srcList = "C:\temp\McAfee Stuff\PS-McAfeeWCPolicyEdits\newblocks-$inc.csv"
$newBlocksList = import-csv $srcList -Header "site"
$output = "C:\temp\McAfee Stuff\PS-McAfeeWCPolicyEdits\output-$inc.xml"

#copy-item $DataPath $output -Force

$num = $NextNum
foreach ($site in $newBlocksList)
{
    
    $insdataAction.[name] = "Action$num"
    $insdataAction.[value] = "1"
    
    $insdataNote.[name] = "szNote$num"
    $insdataNote.[value] = "$inc"
    
    $insdataSite.[name] = "szSite$num"
    $insdataSite.[value] = "$($site.site)"
    
    $insdataUsite.[name] = "szUnicodeSite$num"
    $insdataUsite.[value] = "$($site.site)"

    $bals.DocumentElement.appendchild($insdataAction)
    $bals.DocumentElement.appendchild($insdataNote)
    $bals.DocumentElement.appendchild($insdataSite)
    $bals.DocumentElement.appendchild($insdataUsite)
    $num++
}

$($BALs | ? {$($_.name) -eq "uiSiteCount"}).value = $num
write-host "Top #: $num"

$BALs.save($output)


