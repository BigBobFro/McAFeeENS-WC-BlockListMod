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

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 						# Load .NET Assembly
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 				# Load .NET Assembly

function DDE #Do_De_Exit
{
    $MainWinObj.close()
}


# Build GUI Window

    $MainWinObj                 = New-object System.Windows.Forms.Form
    $MainWinObj.Text            = "McAfee ENS-WC Policy Inject"
    $MainWinObj.size            = New-Object System.Drawing.Size(550,300)
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
    $InputFileNameLabel             = New-Object System.Windows.Forms.Label
    $InputFileNameLabel.Location    = New-Object System.Drawing.size(25,25)
    $InputFileNameLabel.Size        = New-Object System.Drawing.Size(170,20)
    $InputFileNameLabel.Text        = "Input filename (*.xml)"

    $InputFileNameField             = New-Object System.Windows.Forms.TextBox
    $InputFileNameField.location    = New-Object System.Drawing.Size(205,25)
    $InputFileNameField.size        = New-Object System.Drawing.Size(150,20)
    $InputFileNameField.TabStop     = $true
    $InputFileNameField.TabIndex    = 1

    $SelectFileButton               = New-Object System.Windows.Forms.Button
    $SelectFileButton.Location      = New-Object System.Drawing.Size(365,25)
    $SelectFileButton.Size          = New-Object System.Drawing.Size(140,20)
    $SelectFileButton.Text          = "Select Input File"
    $SelectFileButton.TabStop       = $true
    $SelectFileButton.TabIndex      = 2
    $SelectFileButton.add_click(    {<#Activate Windows File Dialog#>})

    $ReadInputFileButton            = New-Object System.Windows.Forms.Button
    $ReadInputFileButton.Location   = New-Object System.Drawing.Size(365,50)
    $ReadInputFileButton.Size       = New-Object System.Drawing.Size(140,20)
    $ReadInputFileButton.Text       = "Read Existing Policy File"
    $ReadInputFileButton.TabStop    = $true
    $ReadInputFileButton.TabIndex   = 3
    $ReadInputFileButton.add_click( {<#Read File stats#>})

    $OutputFileLabel                = New-Object System.Windows.Forms.Label
    $OutputFileLabel.Location       = New-Object System.Drawing.size(25,120)
    $OutputFileLabel.Size           = New-Object System.Drawing.Size(170,20)
    $OutputFileLabel.Text           = "Output File"
    
    $OutputFileField                = New-Object System.Windows.Forms.TextBox
    $OutputFileField.Location       = New-Object System.Drawing.size(205,120)
    $OutputFileField.Size           = New-Object System.Drawing.Size(150,20)
    $OutputFileField.TabStop        = $true
    $OutputFileField.TabIndex       = 10

    $KwitButton                     = New-Object System.Windows.Forms.Button
    $KwitButton.Location            = New-Object System.Drawing.Size(365,225)
    $KwitButton.Size                = New-Object System.Drawing.Size(140,20)
    $KwitButton.Text                = "Quit"
    $KwitButton.TabStop             = $true
    $KwitButton.TabIndex            = 99
    $KwitButton.add_click(          {DDE})

# Add Controls to Main window
    $MainWinObj.Controls.add($InputFileNameLabel)
    $MainWinObj.Controls.add($InputFileNameField)
    $MainWinObj.Controls.add($SelectFileButton)
    $MainWinObj.Controls.add($KwitButton)
    $MainWinObj.Controls.add($OutputFileLabel)
    $MainWinObj.Controls.add($OutputFileField)
    $MainWinObj.Controls.add($ReadInputFileButton)

# Activate Main window
    $MainWinObj.topmost = $true
    $MainWinObj.add_shown({$MainWinObj.Activate();$InputFileNameField.focus()})
    [void] $MainWinObj.ShowDialog()




