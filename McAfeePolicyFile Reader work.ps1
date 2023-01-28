
$path = "C:\Users\fro\TempGit\McAFeeENS-WC-BlockListMod\SmallWCPolicy.xml"
[xml]$blah = get-content $path

$balist = $($blah.epopolicyschema.EPOpolicysettings.section|?{$_.name -eq "BlockAndAllowList"}).Setting

$rv = @{
    "TotalSites"    = 0
    "SiteList"      = @() # IndexTables
}



$totalsites = $($BAlist|?{$_.name -eq "uiSiteCount"}).value