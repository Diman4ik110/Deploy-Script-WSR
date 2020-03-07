Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form

Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore

########################
# Variables
########################
$Global:Stands = @{}
[Int32]$Position = 0
$Global:StandLocation = 30
$Global:StandCount = 1

#######################
# Functions
#######################
 
function Add-Stand {
    param (
        [int]$Count,
        [int]$Location,
        [System.Windows.Forms.SplitContainer]$Container
    )
    #Creating Object
    [System.Windows.Forms.TextBox]$ServerIP = New-Object System.Windows.Forms.TextBox
    [System.Windows.Forms.ComboBox]$Type = New-Object System.Windows.Forms.ComboBox
    [System.Windows.Forms.ProgressBar]$CompleteStatus = New-Object System.Windows.Forms.ProgressBar
    [System.Windows.Forms.Button]$NewButton = New-Object System.Windows.Forms.Button

    if ($StandCount % 2 -eq 0) {
        
        $Container.Panel2.Controls.Add($NewButton)
        $Container.Panel2.Controls.Add($ServerIP)
        $Container.Panel2.Controls.Add($Type)
        $Container.Panel2.Controls.Add($CompleteStatus)
        $Global:StandLocation = $StandLocation + 25
    }
    else {
        $Container.Panel1.Controls.Add($NewButton)
        $Container.Panel1.Controls.Add($ServerIP)
        $Container.Panel1.Controls.Add($Type)
        $Container.Panel1.Controls.Add($CompleteStatus)
        if (($StandLocation + 20) -gt $MainBox.Height) {
            $MainBox.Height += 25
            $form.Height += 25
            $DeployButton.Top += 25
        }
    }
    
    #New Button Settings
    $NewButton.Add_Click({ ButtonClick })
    $NewButton.Text = "+"
    $NewButton.Width = 20
    $NewButton.Height = 20
    $NewButton.Location = New-Object System.Drawing.Point(5, $Location)

    $ServerIP.Width = 120
    $ServerIP.Location = New-Object System.Drawing.Point(30, $Location)        

    #Type Select Box Setting
    $Type.Width = 80
    $Type.Items.Add("Linux")
    $Type.Items.Add("Windows")
    $Type.Location = New-Object System.Drawing.Point(160, $Location)

    #Progress Bar Settings
    $CompleteStatus.Maximum = 100
    $CompleteStatus.Width = 200
    $CompleteStatus.Height = 20
    $CompleteStatus.Location = New-Object System.Drawing.Point(250, $Location)

    $Global:Stands += $ServerIP
}

########################
# Creating elements
########################

# Linux Image
[System.Windows.Forms.Label]$LinuxLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.TextBox]$LinuxPath = New-Object System.Windows.Forms.TextBox
[System.Windows.Forms.TextBox]$WindowsPath = New-Object System.Windows.Forms.TextBox

# Windows Image
[System.Windows.Forms.Label]$WindowsLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Button]$LinuxButton = New-Object System.Windows.Forms.Button
[System.Windows.Forms.Button]$WindowsButton = New-Object System.Windows.Forms.Button

# vCenter IP address
[System.Windows.Forms.Label]$vCenterLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.TextBox]$vCenterIP = New-Object System.Windows.Forms.TextBox
# Open File Dialog
[System.Windows.Forms.OpenFileDialog]$FileDialog = New-Object System.Windows.Forms.OpenFileDialog

# Main Box
[System.Windows.Forms.SplitContainer]$MainBox = New-Object System.Windows.Forms.SplitContainer

[System.Windows.Forms.Label]$ServerIPLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$NewButtonLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$TypeLabel = New-Object System.Windows.Forms.Label
[System.Windows.Forms.Label]$CompleteStatusLabel = New-Object System.Windows.Forms.Label

[System.Windows.Forms.Button]$DeployButton = New-Object System.Windows.Forms.Button

#########################
# Element Events
#########################

function deploy() {
    for ($i = 0; $i -lt $Global:Stands.Count; $i++) {
        Write-Host $Global:Stands[$i].Text
    }
}
function ButtonClick () {
    $Global:StandCount = $StandCount + 1
    Add-Stand -Count $StandCount -Location $StandLocation -Container $MainBox
}
function WindowsButtonClick () {
    $FileDialog.Title = "Select Windows Template File"
    $null = $FileDialog.ShowDialog()
    $WindowsPath.Text = $FileDialog.FileName
}
function LinuxButtonClick () {
    $FileDialog.Title = "Select Linux Template File"
    $null = $FileDialog.ShowDialog()
    $LinuxPath.Text = $FileDialog.FileName
}

##########################
# Element Description
##########################

$form.Height = 300
$form.Width = 1020
$form.Text = "Deploy Script"
$form.StartPosition = "CenterScreen"
$form.add_FormClosing({
    param($sender,$e)
    $result = [System.Windows.Forms.MessageBox]::Show(`
        "Close?", `
        "Close", [System.Windows.Forms.MessageBoxButtons]::YesNo)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        $e.Cancel= $true
    }
})

$FileDialog.Filter = 'ESXI Images(*.ova)|*.ova'
$FileDialog.AddExtension = $true
$FileDialog.InitialDirectory = "$HOME"

# Select Windows Image
$Position += 20
$WindowsLabel.Text = "Windows File Image"
$WindowsLabel.Width = 140
$WindowsLabel.Location = New-Object System.Drawing.Point(10, $Position)

$WindowsPath.ReadOnly = $true
$WindowsPath.Width = 200
$WindowsPath.Location = New-Object System.Drawing.Point(160, $Position)

$WindowsButton.Width = 20
$WindowsButton.Height = 20
$WindowsButton.Text = "..."
$WindowsButton.Add_Click( { WindowsButtonClick })
$WindowsButton.Location = New-Object System.Drawing.Point(360, $Position)

# Select Linux Image
$Position += 40
$LinuxLabel.Text = "Linux File Image"
$LinuxLabel.Width = 140
$LinuxLabel.Location = New-Object System.Drawing.Point(10, $Position)

$LinuxPath.ReadOnly = $true
$LinuxPath.Width = 200
$LinuxPath.Location = New-Object System.Drawing.Point(160, $Position)

$vCenterLabel.Text = "vCenter IP"
$vCenterLabel.Width = 140
$vCenterLabel.Location = New-Object System.Drawing.Point(400, $Position)

$vCenterIP.Width = 150
$vCenterIP.Location = New-Object System.Drawing.Point(480, $Position)

$LinuxButton.Width = 20
$LinuxButton.Height = 20
$LinuxButton.Text = "..."
$LinuxButton.Add_Click( { LinuxButtonClick })
$LinuxButton.Location = New-Object System.Drawing.Point(360, $Position)

# Main Box
$Position += 30
$MainBox.Width = 960
$MainBox.Height = 85
$MainBox.Location = New-Object System.Drawing.Point(20, $Position)
$MainBox.BorderStyle = 1
$MainBox.IsSplitterFixed = $true

$MainBox.Panel1.Controls.Add($NewButtonLabel)
$MainBox.Panel1.Controls.Add($TypeLabel)
$MainBox.Panel1.Controls.Add($ServerIPLabel)
$MainBox.Panel1.Controls.Add($CompleteStatusLabel)

$MainBox.SplitterDistance = $MainBox.Width - 480

for ($i = 0; $i -lt 2; $i++) {
    
    $NewButtonLabel.Text = "New"
    $NewButtonLabel.Width = 30
    $NewButtonLabel.Height = 18
    $NewButtonLabel.Location = New-Object System.Drawing.Point(0, 5)
    $NewButtonLabel = New-Object System.Windows.Forms.Label
    $MainBox.Panel2.Controls.Add($NewButtonLabel)

    $ServerIPLabel.Width = 120
    $ServerIPLabel.Text = "Server IP-address"
    $ServerIPLabel.Location = New-Object System.Drawing.Point(40, 5)
    $ServerIPLabel = New-Object System.Windows.Forms.Label
    $MainBox.Panel2.Controls.Add($ServerIPLabel)

    $TypeLabel.Width = 80
    $TypeLabel.Text = "Type"
    $TypeLabel.Location = New-Object System.Drawing.Point(160, 5)
    $TypeLabel = New-Object System.Windows.Forms.Label
    $MainBox.Panel2.Controls.Add($TypeLabel)

    $CompleteStatusLabel.Width = 200
    $CompleteStatusLabel.Text = "Progress"
    $CompleteStatusLabel.Location = New-Object System.Drawing.Point(250, 5)
    $CompleteStatusLabel = New-Object System.Windows.Forms.Label
    $MainBox.Panel2.Controls.Add($CompleteStatusLabel)

}

Add-Stand -Count $StandCount -Location $StandLocation -Container $MainBox

$Position += 120
$DeployButton.Location = New-Object System.Drawing.Point(450, $Position)
$DeployButton.Width = 100
$DeployButton.Height = 30
$DeployButton.Text = "Deploy"
$DeployButton.Add_Click( { deploy })

###########################
# Adding element to Form
###########################

$form.Controls.Add($LinuxLabel)
$form.Controls.Add($LinuxPath)
$form.Controls.Add($LinuxButton)
$form.Controls.Add($WindowsLabel)
$form.Controls.Add($WindowsPath)
$form.Controls.Add($WindowsButton)
$form.Controls.Add($vCenterIP)
$form.Controls.Add($vCenterLabel)
$form.Controls.Add($MainBox)
$form.Controls.Add($DeployButton)
$form.ShowDialog()