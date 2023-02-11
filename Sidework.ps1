# get data to play with
[xml]$InputPolicyFile = get-content -path "C:\Users\fro\TempGit\McAFeeENS-WC-BlockListMod\SmallWCPolicy.xml"
$inputCSVfile = "C:\Users\fro\TempGit\McAFeeENS-WC-BlockListMod\newblocks-INC3891174.csv"

$balist     = ReadMcAfeePolicyFile($InputPolicyFile)
$InputCSV   = Import-Csv $inputCSVfile -header "site","action"

#add a junk entry
$entry = @{
        "site"      = "blahblahblah.com"
        "note"      = "test site"
        "action"    = 1
}
$total = $balist.List.count
$balist.list.add($total, $entry)

# create a quicklist to check for duplicates
$dupeCheckList = @{}
$ordinal = 1
foreach($item in $($balist.list))
{
    # Check for null sites in policy
    if($null -ne $item.site){
        $dupeCheckList.add($item.site,$item.action) 
    }
    $ordinal++
}

# Ratchet through new items list
foreach($newItem in $InputCSV){
    #Check for duplicate
    if($dupeCheckList[$newitem.site]){
        #Duplicate Exists
        if($($($dupeCheckList[$newitem.site]).action) -ne $newItem.action){
            # Update the balist with changed action
            $($balist.List.Values | ?{$_.site -eq $($newItem.site)}).action = $newItem.action
        }
    }
    else {
        <# Not a duplicate; add to policy#>
        $total = $balist.List.Count
        $entry = @{
            "site"      = $newitem.site
            "action"    = $newItem.action
            "note"      = "$RunDate-testing something"      #TODO: Come up with an entry
        }
        $balist.List.add($total,$entry)
    }
}