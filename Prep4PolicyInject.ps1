$startnum = 77309
$inc = "INC3891174"

$srcList = "C:\temp\McAfee Stuff\PS-McAfeeWCPolicyEdits\newblocks-$inc.csv"

$output = "C:\temp\McAfee Stuff\PS-McAfeeWCPolicyEdits\output-$inc.xml"

#blanks the output file each time
$null | out-file -FilePath $output

$newBlocksList = import-csv $srcList -Header "site"
#$newblockslist

$num = $startnum
foreach ($site in $newBlocksList)
{"<Setting name=""Action$num"" value=""1""/>" | out-file -FilePath $output -Append; $num++}
write-host "Top #: $num"

$num = $startnum
foreach ($site in $newBlocksList)
{"<Setting name=""szNote$num"" value=""$inc""/>" | out-file -FilePath $output -Append; $num++}
write-host "Top #: $num"

$num = $startnum
foreach ($site in $newBlocksList)
{"<Setting name=""szSite$num"" value=""$($site.site)""/>" | out-file -FilePath $output -Append; $num++}
write-host "Top #: $num"

$num = $startnum
foreach ($site in $newBlocksList)
{"<Setting name=""szUnicodeSite$num"" value=""$($site.site)""/>" | out-file -FilePath $output -Append; $num++}
write-host "Top #: $num"

