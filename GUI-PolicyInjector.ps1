<#
Title: McAfee ENS WebControl Block/Allow policy injector
Author: Victor Willingham (https://github.com/BigBobFro)
Use: The McAfee Orchestrator admin WebGUI is limited by design to a max resubmission per section of 2MB
    This is insufficient when the total number of exceeds 50-75K
    This limitation is not imposed on the overall size of the policy file when imported.

Requirements:
    Powershell 5.1
    Current Exported WC Policy from the same server to which it will be injected
    CSV file of additional site to block or allow

Current Version: 2.0 [NOW]
========================
Update History
1.0 - Used through CLI and manual cut and paste
1.1 - Made additional ability to allow sites
2.0 - Complete rework of script to read in existing policy and output a new file

#>
param($debug = $true)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 						# Load .NET Assembly
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 				# Load .NET Assembly

# Constants
$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$ScriptStart = Get-Date
$RunDate = Get-Date -format ddMMyyyy


# Variables to NULL or Reset
$fullinputfilepath      = $null
[xml]$InputPolicyFile   = $null
$LastDialogPath         = $srcPath

function DDE #Do_De_Exit
{
    $MainWinObj.close()
}

function JustTheName
{
    param([string]$inputpath)
    $rv = $inputpath.substring($($inputpath.lastindexof("\")) + 1,$($($inputpath.length)-$($inputpath.lastindexof("\")))-1)
    RETURN $rv
}

Function ReadMcAfeePolicyFile
{
    # Opens XML File and returns object with HashTable list object
    param([XML]$InFile)

    $balist = $($InFile.epopolicyschema.EPOpolicysettings.section|?{$_.name -eq "BlockAndAllowList"}).Setting

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


    RETURN $RV  
}


# Build GUI Window

    $MainWinObj                 = New-object System.Windows.Forms.Form
    $MainWinObj.Text            = "McAfee ENS-WC Policy Inject"
    $MainWinObj.size            = New-Object System.Drawing.Size(600,450)
    $MainWinObj.KeyPreview      = $true
    $MainWinObj.StartPosition   = "CenterScreen"

# Keys Intercepted
    $MainWinObj.add_keydown
    (   {if($_.keycode -eq "Enter")
            { #Do Enter Things
            }   
        }
    )
    $MainWinObj.add_keydown
    (   {if($_.keycode -eq "Escape")
            {DDE}
        }
    )

# Create operational object
    $InputPolicyFileLabel               = New-Object System.Windows.Forms.Label
    $InputPolicyFileLabel.Location      = New-Object System.Drawing.size(25,25)
    $InputPolicyFileLabel.Size          = New-Object System.Drawing.Size(155,20)
    $InputPolicyFileLabel.Text          = "Input Policy filename (*.xml)"

    $InputPolicyFileField               = New-Object System.Windows.Forms.TextBox
    $InputPolicyFileField.location      = New-Object System.Drawing.Size(185,25)
    $InputPolicyFileField.size          = New-Object System.Drawing.Size(200,20)
    $InputPolicyFileField.TabStop       = $true
    $InputPolicyFileField.TabIndex      = 1

    $SelectPolicyFileButton             = New-Object System.Windows.Forms.Button
    $SelectPolicyFileButton.Location    = New-Object System.Drawing.Size(395,25)
    $SelectPolicyFileButton.Size        = New-Object System.Drawing.Size(140,20)
    $SelectPolicyFileButton.Text        = "Select Input Policy File"
    $SelectPolicyFileButton.TabStop     = $true
    $SelectPolicyFileButton.TabIndex    = 2
    $SelectPolicyFileButton.add_click(    {
                                    <#Activate Windows File Dialog#>
                                    $OpenFileDialog                     = New-Object System.Windows.Forms.OpenFileDialog
                                    $OpenFileDialog.initialDirectory    = $LastDialogPath
                                    $OpenFileDialog.Filter              = "eXtensible Markup Language (*.xml)| *.xml"
                                    [void] $OpenFileDialog.ShowDialog()
                                    $FullInputFilePath = $OpenFileDialog.filename
                                    if($debug)  {write-host "Input File: $FullInputFilePath"}
                                    $LastDialogPath                     = $FullInputFilePath.substring(0,$FullInputFilePath.lastindexof("\"))
                                    $InputPolicyPathLabel.text          = $LastDialogPath
                                    $InputPolicyFileField.text          = JustTheName($FullInputFilePath)
                                    $OutputPolictFileField.text         = "$($InputPolicyFileField.Text.substring(0,$InputPolicyFileField.text.LastIndexOf(".")))_$rundate.XML"
                                    $InputPolicyFileField.Enabled       = $false
                                    })

    $InputPolicyPathLabel               = New-Object System.Windows.Forms.Label
    $InputPolicyPathLabel.Location      = New-Object system.drawing.size(185,50)
    $InputPolicyPathLabel.Size          = New-Object System.Drawing.Size(350,20)
    $InputPolicyPathLabel.Text          = ""
    

    $ReadPolictInputButton              = New-Object System.Windows.Forms.Button
    $ReadPolictInputButton.Location     = New-Object System.Drawing.Size(395,75)
    $ReadPolictInputButton.Size         = New-Object System.Drawing.Size(140,20)
    $ReadPolictInputButton.Text         = "Read Existing Policy File"
    $ReadPolictInputButton.TabStop      = $true
    $ReadPolictInputButton.TabIndex     = 3
    $ReadPolictInputButton.add_click( {<#Read File stats#>
                                    $InputPolicyFile                    = Get-Content "$($InputPolicyPathLabel.text)\$($InputPolicyFileField.text)"
                                    $balist                             = ReadMcAfeePolicyFile($InputPolicyFile)
                                    if($debug)                          {write-host "Total sites found in BAlist: $($balist.totalsites)"}
                                    $InputPolicySitesLabel.Text         = "Total Sites found in policy file: $($balist.TotalSites)"
                                    })

#TODO Add list of sites to inject to policy CVS file input
#TODO Create inverted BAlist, keyed on site, or some other way of dealing with conflicts

    $InputPolicySitesLabel              = New-Object System.Windows.Forms.Label
    $InputPolicySitesLabel.location     = New-Object system.drawing.size(185,75)
    $InputPolicySitesLabel.Size         = New-object System.Drawing.size(350,20)
    $InputPolicySitesLabel.Text         = ""

    $InputSiteAddLabel                  = New-object System.Windows.Forms.Label
    $InputSiteAddLabel.Location         = New-Object System.Drawing.Size(25,120)
    $InputSiteAddLabel.Size             = New-Object System.Drawing.Size(155,20)
    $InputSiteAddLabel.Text             = "Input site list (*.csv):"

    $InputSiteAddField                  = New-Object System.Windows.Forms.Textbox
    $InputSiteAddField.Location         = New-Object System.Drawing.Size(185,120)
    $InputSiteAddField.Size             = New-Object System.Drawing.Size(200,20)
    $InputSiteAddField.TabStop          = $true
    $InputSiteAddField.TabIndex         = 4

    $InputSiteAddFullPath               = New-Object System.Windows.Forms.Label
    $InputSiteAddFullPath.location      = New-Object System.Drawing.size(185,145)
    $InputSiteAddFullPath.Size          = New-Object System.Drawing.size(350,20)
    $InputSiteAddFullPath.Text          = ""

    $SelectSiteAddFile                  = New-Object System.Windows.Forms.Button
    $SelectSiteAddFile.location         = New-Object System.Drawing.size(395,120)
    $SelectSiteAddFile.Size             = New-Object System.Drawing.size(140,20)
    $SelectSiteAddFile.TabIndex         = $true
    $SelectSiteAddFile.TabIndex         = 5
    $SelectSiteAddFile.text             = "Select Site Add File"
    $SelectSiteAddFile.add_click(       {<# Select CSV File of sites to add #>
                                        $OpenFileDialog                     = New-Object System.Windows.Forms.OpenFileDialog
                                        $OpenFileDialog.initialDirectory    = $LastDialogPath
                                        $OpenFileDialog.Filter              = "Comma Separated Values (*.CSV)| *.csv"
                                        [void] $OpenFileDialog.ShowDialog()
                                        $SiteAddFilePath = $OpenFileDialog.filename
                                        $InputSiteAddFullPath.text = $SiteAddFilePath.substring(0,$SiteAddFilePath.lastindexof("\"))
                                        $InputSiteAddField.text = JustTheName($SiteAddFilePath)
    })

    $InputSites2AddLabel                = New-Object System.Windows.Forms.Label
    $InputSites2AddLabel.Location       = New-Object System.Drawing.Size(185,170)
    $InputSites2AddLabel.size           = New-Object System.Drawing.Size(150,20)
    $InputSites2AddLabel.Text           = ""

    $ReadInCSVFileButton                = New-Object System.Windows.Forms.Button
    $ReadInCSVFileButton.Location       = New-Object System.Drawing.Size(395,170)
    $ReadInCSVFileButton.Size           = New-Object System.Drawing.Size(140,20)
    $ReadInCSVFileButton.Text           = "Read CSV File"
    $ReadInCSVFileButton.TabStop        = $true
    $ReadInCSVFileButton.TabIndex       = 6
    $ReadInCSVFileButton.add_click(     {
                                        <# READ CSV FILE#>
                                        $inputCSV = Import-Csv "$($InputSiteAddFullPath.text)/$($InputSiteAddField.text)" -header "site","action"
                                        $InputSites2AddLabel.text = $inputCSV.count
    })


    $OutputPolicyFileLabel              = New-Object System.Windows.Forms.Label
    $OutputPolicyFileLabel.Location     = New-Object System.Drawing.size(25,230)
    $OutputPolicyFileLabel.Size         = New-Object System.Drawing.Size(155,20)
    $OutputPolicyFileLabel.Text         = "Output Policy File"
    
    $OutputPolictFileField              = New-Object System.Windows.Forms.TextBox
    $OutputPolictFileField.Location     = New-Object System.Drawing.size(185,230)
    $OutputPolictFileField.Size         = New-Object System.Drawing.Size(200,20)
    $OutputPolictFileField.TabStop      = $true
    $OutputPolictFileField.TabIndex     = 10

    $DoDeBizniz                         = New-Object System.Windows.Forms.Button
    $DoDeBizniz.Location                = New-Object System.Drawing.Size(395,230)
    $DoDeBizniz.Size                    = New-Object System.Drawing.Size(140,20)
    $DoDeBizniz.TabStop                 = $true
    $DoDeBizniz.TabIndex                = 50
    $DoDeBizniz.Text                    = "YOU CAN DO EET!!"

    $KwitButton                         = New-Object System.Windows.Forms.Button
    $KwitButton.Location                = New-Object System.Drawing.Size(395,275)
    $KwitButton.Size                    = New-Object System.Drawing.Size(140,20)
    $KwitButton.Text                    = "Quit"
    $KwitButton.TabStop                 = $true
    $KwitButton.TabIndex                = 99
    $KwitButton.add_click(              {DDE})

# Add Controls to Main window
    $MainWinObj.Controls.add($InputPolicyFileLabel)
    $MainWinObj.Controls.add($InputPolicyFileField)
    $MainWinObj.Controls.add($SelectPolicyFileButton)
    $MainWinObj.Controls.add($KwitButton)
    $MainWinObj.Controls.add($OutputPolicyFileLabel)
    $MainWinObj.Controls.add($OutputPolictFileField)
    $MainWinObj.Controls.add($ReadPolictInputButton)
    $MainWinObj.Controls.add($InputPolicyPathLabel)
    $MainWinObj.Controls.Add($InputPolicySitesLabel)
    $MainWinObj.Controls.Add($InputSiteAddLabel)
    $MainWinObj.Controls.Add($InputSiteAddField)
    $MainWinObj.Controls.add($SelectSiteAddFile)
    $MainWinObj.Controls.Add($InputSiteAddFullPath)
    $MainWinObj.Controls.Add($InputSites2AddLabel)
    $MainWinObj.Controls.Add($ReadInCSVFileButton)
    $MainWinObj.Controls.Add($DoDeBizniz)

# Activate Main window
    $MainWinObj.topmost = $true
    $MainWinObj.add_shown({$MainWinObj.Activate();$InputPolicyFileField.focus()})
    [void] $MainWinObj.ShowDialog()



