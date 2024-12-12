# Global informations
$path = Split-Path $script:MyInvocation.MyCommand.Path
$cipUsager = $ENV:UserName

Add-Type -AssemblyName System.Windows.Forms

# Initialize the form and components
$Form = New-Object -TypeName System.Windows.Forms.Form
$GroupBoxInformations = New-Object -TypeName System.Windows.Forms.GroupBox
$LabelCIP = New-Object -TypeName System.Windows.Forms.Label
$LabelPassword = New-Object -TypeName System.Windows.Forms.Label
$TextBoxCIP = New-Object -TypeName System.Windows.Forms.TextBox
$TextBoxPassword = New-Object -TypeName System.Windows.Forms.TextBox
$LabelCIPErreur = New-Object -TypeName System.Windows.Forms.Label
$LabelPasswordErreur = New-Object -TypeName System.Windows.Forms.Label
$GroupBoxServeurs = New-Object -TypeName System.Windows.Forms.GroupBox
$GroupBoxResultats = New-Object -TypeName System.Windows.Forms.GroupBox
$TextBoxResultats = New-Object -TypeName System.Windows.Forms.TextBox
$LinkLabelCSV = New-Object -TypeName System.Windows.Forms.LinkLabel
$LinkLabelMAJ = New-Object -TypeName System.Windows.Forms.LinkLabel
$ButtonValider = New-Object -TypeName System.Windows.Forms.Button

function Get-FormattedString {
    param(
        [string]$string
    )
    return [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($string))
}

$ServersHashtable = @{}
function InitializeComponent {
    
    # Setup de la GroupBox d'informations.
    $GroupBoxInformations.Controls.AddRange(@($LabelPasswordErreur, $LabelCIPErreur, $GroupBoxServeurs, $TextBoxPassword, $TextBoxCIP, $LabelPassword, $LabelCIP, $ButtonValider))
    $GroupBoxInformations.Font = [System.Drawing.Font]::new("Tahoma", 10)
    $GroupBoxInformations.Location = [System.Drawing.Point]::new(12, 12)
    $GroupBoxInformations.Size = [System.Drawing.Size]::new(428, 325)
    $GroupBoxInformations.Text = "Informations"

    # Setup des labels d'informations.
    $LabelCIP.Text = Get-FormattedString -string "Entrez le CIP à vérifier : "
    $LabelCIP.Location = [System.Drawing.Point]::new(15, 25)
    $LabelCIP.Size = [System.Drawing.Size]::new(200, 20)
    $LabelCIP.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $LabelPassword.Text = "Votre mot de passe : "
    $LabelPassword.Location = [System.Drawing.Point]::new(15, 65)
    $LabelPassword.Size = [System.Drawing.Size]::new(200, 20)
    $LabelPassword.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    # Setup des TextBox du CIP et du Password.
    $TextBoxCIP.Location = [System.Drawing.Point]::new(240, 25)
    $TextBoxCIP.Size = [System.Drawing.Size]::new(170, 20)
    $TextBoxCIP.Text = "toue1401"

    $password = "Jumper13*"
    $TextBoxPassword.Location = [System.Drawing.Point]::new(240, 65)
    $TextBoxPassword.Size = [System.Drawing.Size]::new(170, 20)
    $TextBoxPassword.Text = $password
    $TextBoxPassword.PasswordChar = Get-FormattedString -string "•"
    
    # Setup des labels d'erreur.
    $LabelCIPErreur.Text = "* Veuillez entrer un CIP valide."
    $LabelCIPErreur.Font = [System.Drawing.Font]::new("Tahoma", 8)
    $LabelCIPErreur.Size = [System.Drawing.Size]::new(170, 15)
    $LabelCIPErreur.ForeColor = [System.Drawing.Color]::Red
    $LabelCIPErreur.Location = [System.Drawing.Point]::new(240, 50)
    $LabelCIPErreur.Visible = $false

    $LabelPasswordErreur.Text = "* Veuillez entrer un mot de passe."
    $LabelPasswordErreur.Font = [System.Drawing.Font]::new("Tahoma", 8)
    $LabelPasswordErreur.Size = [System.Drawing.Size]::new(170, 15)
    $LabelPasswordErreur.ForeColor = [System.Drawing.Color]::Red
    $LabelPasswordErreur.Location = [System.Drawing.Point]::new(240, 90)
    $LabelPasswordErreur.Visible = $false

    # Setup de la GroupBox des Serveurs (sous GroupBox).
    $GroupBoxServeurs.Text = Get-FormattedString -string "Serveur(s) à vérifier"
    $GroupBoxServeurs.Location = [System.Drawing.Point]::new(8, 123)
    $GroupBoxServeurs.Size = [System.Drawing.Size]::new(410, 164)

    # La liste des serveurs... Peut accueillir jusqu'à 21 serveurs.
    $dbJson = Get-Content -Path "$path/config/database.json" -Raw | ConvertFrom-Json

    $ServerList = $dbJson.PSObject.Properties |
                       Where-Object { $_.Name -ne "ssh_host" } |
                       Select-Object -ExpandProperty Name

    # Setup des Serveurs (à cocher) dynamiquement (automagiquement)
    $yOffset = 20
    $xOffset = 130
    $x = 0
    $y = 0
    foreach ($Server in $ServerList) {
        $CheckBox = New-Object -TypeName System.Windows.Forms.CheckBox
        $CheckBox.Text = $Server -replace "UdS-VEO-", ""
        $ServersHashtable[$CheckBox.Text] = $Server
        $CheckBox.Location = [System.Drawing.Point]::new(15 + $x * $xOffset, 25 + $y * $yOffset)
        $CheckBox.Size = [System.Drawing.Size]::new(125, 15)
        $CheckBox.Checked = $true
        $CheckBox.Font = [System.Drawing.Font]::new("Tahoma", 8)
        $GroupBoxServeurs.Controls.Add($CheckBox)
        $x += 1
        if($x -ge 3) {
            $x = 0
            $y += 1
        }
    }

    # Setup du bouton de soumission.
    $ButtonValider.Text = "Valider"
    $ButtonValider.Location = [System.Drawing.Point]::new(300, 294)
    $ButtonValider.Size = [System.Drawing.Size]::new(117, 20)
    $ButtonValider.Font = [System.Drawing.Font]::new($ButtonValider.Font.FontFamily, $ButtonValider.Font.Size, [System.Drawing.FontStyle]::Bold)

    $ButtonValider.Add_Click({
        # Pattern de CIP
        $CIPPattern = "^[A-Za-z]{4}\d{4}$"

        # CIP correct?
        if ($TextBoxCIP.Text -match $CIPPattern) {
            $LabelCIPErreur.Visible = $false 
        }
        else {
            $LabelCIPErreur.Visible = $true
            return;
        }

        # Password non nul?
        if ([string]::IsNullOrWhiteSpace($TextBoxPassword.Text)) {
            $LabelPasswordErreur.Visible = $true
            return;
        }
        else {
            $LabelPasswordErreur.Visible = $false
        }

        # Serveurs selectionné (vrai nom dans la Hashtable)
        $CheckedServers = @()
        foreach ($control in $GroupBoxServeurs.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $CheckedServers += $ServersHashtable[$control.Text]
            }
        }

        $TextBoxResultats.ForeColor = [System.Drawing.Color]::Black
        $TextBoxResultats.Text = "En cours de chargement..."

        & "$path\init\config.ps1"
        $dbUser, $dbPassword = & "$path\init\PasswordStateMain.ps1"
        $outputs = & "$path\Get-ResultatsPersonne.ps1" -cipUsager $Env:UserName -cipPassword $TextBoxPassword.Text -cipPersonne $TextBoxCIP.Text -dbUser $dbUser -dbPassword $dbPassword -selectedServers $CheckedServers
        if ($outputs -is [System.Collections.IEnumerable] -and -not ($outputs -is [string])) {
            $TextBoxResultats.ForeColor = [System.Drawing.Color]::Red
        } else {
            $TextBoxResultats.ForeColor = [System.Drawing.Color]::Green
        }
        $TextBoxResultats.Text = ""
        foreach ($output in $outputs) {
            $TextBoxResultats.Text += $output
            $TextBoxResultats.Text += "`r`n"
        }
        $LinkLabelCSV.Enabled = $true
    })

    # Setup de la GroupBox des résultats.
    $GroupBoxResultats.Controls.AddRange(@($TextBoxResultats))
    $GroupBoxResultats.Font = [System.Drawing.Font]::new("Tahoma", 10)
    $GroupBoxResultats.Text = Get-FormattedString -string "Résultats"
    $GroupBoxResultats.Location = [System.Drawing.Point]::new(456, 13)
    $GroupBoxResultats.Size = [System.Drawing.Size]::new(438, 325)

    # Label du résultat
    $TextBoxResultats.Location = [System.Drawing.Point]::new(15, 25)
    $TextBoxResultats.Size = [System.Drawing.Size]::new(408, 285)
    $TextBoxResultats.Multiline = $true
    $TextBoxResultats.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $TextBoxResultats.WordWrap = $true

    # Setup des liens pour CSV et MAJ.
    $LinkLabelCSV.Text = Get-FormattedString -string "Voir le fichier CSV exporté"
    $LinkLabelCSV.Location = [System.Drawing.Point]::new(755, 345)
    $LinkLabelCSV.Size = [System.Drawing.Size]::new(170, 15)
    $LinkLabelCSV.Enabled = $true # FALSE NORMALEMENT
    $LinkLabelCSV.Add_Click({
        # Si on veut ouvrir le fichier du CIP
        #$cipVerifie = $TextBoxCIP.Text
        #$csvFilePath = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("C:/Users/${cipUsager}/Desktop/VEO_Vérif_Accès_CIP/VEO_access_CIP_${cipVerifie}.csv"))
        # Si on veut ouvrir le folder des CSV
        $csvFilePath = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("C:/Users/${cipUsager}/Desktop/VEO_Vérif_Accès_CIP/"))
        Invoke-Item $csvFilePath
    })

    $LinkLabelMAJ.Text = Get-FormattedString -string "Mettre à jour l'outil de vérification"
    $LinkLabelMAJ.Location = [System.Drawing.Point]::new(10, 345)
    $LinkLabelMAJ.Size = [System.Drawing.Size]::new(170, 15)
    $LinkLabelMAJ.Add_Click({
        # DANGER, WIPES EVERYTHING THAT IS NOT COMMITED
        # Start-Process -FilePath "git" -ArgumentList "reset", "hard" -WorkingDirectory $path
        Start-Process -FilePath "git" -ArgumentList "pull" -WorkingDirectory $path
    })

    # Setup de la page globale.
    $Form.Text = Get-FormattedString -string "UdS - Vérification des accès administratifs"
    $Form.ClientSize = [System.Drawing.Size]::new(905, 375)
    $Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$path/icon.ico")
    $Form.Controls.AddRange(@($GroupBoxInformations, $GroupBoxResultats, $LinkLabelCSV, $LinkLabelMAJ))
    $Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
}

# Création du GUI
$allowedUsagers = @(
    "danj2005"
    "loug2702"
    "rous1803"
    "benm2924"
    "toue1401"
)

if (-not ($cipUsager -in $allowedUsagers)) {
    throw "Vous n'êtes pas autorisé à exécuter ce script."
}

InitializeComponent
[void]$Form.ShowDialog()
