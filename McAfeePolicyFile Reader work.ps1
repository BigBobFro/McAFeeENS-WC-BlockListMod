
$path = "C:\Users\fro\TempGit\McAFeeENS-WC-BlockListMod\SmallWCPolicy.xml"
[xml]$infile = get-content $path

$balist = $($infile.epopolicyschema.EPOpolicysettings.section|?{$_.name -eq "BlockAndAllowList"}).Setting

$list = @{}
foreach ($setting in $balist){
    $props      = @{}
    [int]$ordinal    = $null
    if ($($setting.name) -like "Action*") {
        [int]$ordinal = $setting.name.substring(6,$($setting.name.length)-6)
        $props = @{
            "Action"    = $setting.value
            "Note"      = $null
            "Site"      = $null
        }
        $list.add($ordinal,$props)
    }
    elseif ($($setting.name -like "szNote*")) {
        $ordinal = $setting.name.substring(6,$($setting.name.length)-6)
        $($list[$ordinal]).Note = $setting.value
    }
    elseif ($($setting.name -like "szSite*")) {
        $ordinal = $setting.name.substring(6,$($setting.name.length)-6)
        $($list[$ordinal]).Site = $setting.value
    }
    elseif($($setting.name -eq "uiSiteCount")){
        $totalsites = $setting.value
    }
    #else #DO NOTHING
}

$rv = @{
    "TotalSites"    = $totalsites
    "List"          = $list
}

RETURN $rv