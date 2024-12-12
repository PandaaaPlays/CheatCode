# Administrator check
function Is-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Is-Administrator)) {
    $scriptPath = $MyInvocation.MyCommand.Path

    Start-Process powershell -ArgumentList "-File", $scriptPath -Verb RunAs
    exit
}

# Global informations
$path = Split-Path $script:MyInvocation.MyCommand.Path
Add-Type -AssemblyName System.Windows.Forms

# Initialisation des components
$Form = New-Object -TypeName System.Windows.Forms.Form
$TabControl = New-Object -TypeName System.Windows.Forms.TabControl
$ToolTip = New-Object -TypeName System.Windows.Forms.ToolTip

$TabPageAdd = New-Object -TypeName System.Windows.Forms.TabPage
$LabelName = New-Object -TypeName System.Windows.Forms.Label
$LabelDisplayName = New-Object -TypeName System.Windows.Forms.Label
$DisplayNameToolTipIcon = New-Object System.Windows.Forms.PictureBox
$LabelAssociation = New-Object -TypeName System.Windows.Forms.Label
$TextBoxName = New-Object -TypeName System.Windows.Forms.TextBox
$TextBoxDisplayName = New-Object -TypeName System.Windows.Forms.TextBox
$GroupBoxAssociation = New-Object -TypeName System.Windows.Forms.GroupBox
$GroupBoxOptions = New-Object -TypeName System.Windows.Forms.GroupBox
$LabelCommande = New-Object -TypeName System.Windows.Forms.Label
$CommandeToolTipIcon = New-Object System.Windows.Forms.PictureBox
$TextBoxCommande = New-Object -TypeName System.Windows.Forms.TextBox
$LabelIcone = New-Object -TypeName System.Windows.Forms.Label
$IconeToolTipIcon = New-Object System.Windows.Forms.PictureBox
$TextBoxIcone = New-Object -TypeName System.Windows.Forms.TextBox
$ChangeIconeButton = New-Object -TypeName System.Windows.Forms.Button
$LabelPosition = New-Object -TypeName System.Windows.Forms.Label
$PositionToolTipIcon = New-Object System.Windows.Forms.PictureBox
$ComboBoxPosition = New-Object -TypeName System.Windows.Forms.ComboBox
$Link = New-Object -TypeName System.Windows.Forms.LinkLabel
$ConfirmButton = New-Object -TypeName System.Windows.Forms.Button

$TabPageEdit = New-Object -TypeName System.Windows.Forms.TabPage
$LabelNameEdit = New-Object -TypeName System.Windows.Forms.Label
$LabelDisplayNameEdit = New-Object -TypeName System.Windows.Forms.Label
$DisplayNameTooltipIconEdit = New-Object System.Windows.Forms.PictureBox
$LabelAssociationEdit = New-Object -TypeName System.Windows.Forms.Label
$ComboBoxNameEdit = New-Object -TypeName System.Windows.Forms.ComboBox
$TextBoxDisplayNameEdit = New-Object -TypeName System.Windows.Forms.TextBox
$GroupBoxAssociationEdit = New-Object -TypeName System.Windows.Forms.GroupBox
$GroupBoxOptionsEdit = New-Object -TypeName System.Windows.Forms.GroupBox
$LabelCommandeEdit = New-Object -TypeName System.Windows.Forms.Label
$CommandeToolTipIconEdit = New-Object System.Windows.Forms.PictureBox
$TextBoxCommandeEdit = New-Object -TypeName System.Windows.Forms.TextBox
$LabelIconeEdit = New-Object -TypeName System.Windows.Forms.Label
$IconeToolTipIconEdit = New-Object System.Windows.Forms.PictureBox
$TextBoxIconeEdit = New-Object -TypeName System.Windows.Forms.TextBox
$ChangeIconeButtonEdit = New-Object -TypeName System.Windows.Forms.Button
$LabelPositionEdit = New-Object -TypeName System.Windows.Forms.Label
$PositionToolTipIconEdit = New-Object System.Windows.Forms.PictureBox
$ComboBoxPositionEdit = New-Object -TypeName System.Windows.Forms.ComboBox
$LinkEdit = New-Object -TypeName System.Windows.Forms.LinkLabel
$ConfirmButtonEdit = New-Object -TypeName System.Windows.Forms.Button

$TabPageRemove = New-Object -TypeName System.Windows.Forms.TabPage
$LabelNameRemove = New-Object -TypeName System.Windows.Forms.Label
$LabelDisplayNameRemove = New-Object -TypeName System.Windows.Forms.Label
$DisplayNameTooltipIconRemove = New-Object System.Windows.Forms.PictureBox
$LabelAssociationRemove = New-Object -TypeName System.Windows.Forms.Label
$ComboBoxNameRemove = New-Object -TypeName System.Windows.Forms.ComboBox
$TextBoxDisplayNameRemove = New-Object -TypeName System.Windows.Forms.TextBox
$GroupBoxAssociationRemove = New-Object -TypeName System.Windows.Forms.GroupBox
$GroupBoxOptionsRemove = New-Object -TypeName System.Windows.Forms.GroupBox
$LabelCommandeRemove = New-Object -TypeName System.Windows.Forms.Label
$CommandeToolTipIconRemove = New-Object System.Windows.Forms.PictureBox
$TextBoxCommandeRemove = New-Object -TypeName System.Windows.Forms.TextBox
$LabelIconeRemove = New-Object -TypeName System.Windows.Forms.Label
$IconeToolTipIconRemove = New-Object System.Windows.Forms.PictureBox
$TextBoxIconeRemove = New-Object -TypeName System.Windows.Forms.TextBox
$ChangeIconeButtonRemove = New-Object -TypeName System.Windows.Forms.Button
$LabelPositionRemove = New-Object -TypeName System.Windows.Forms.Label
$PositionToolTipIconRemove = New-Object System.Windows.Forms.PictureBox
$ComboBoxPositionRemove = New-Object -TypeName System.Windows.Forms.ComboBox
$LinkRemove = New-Object -TypeName System.Windows.Forms.LinkLabel
$ConfirmButtonRemove = New-Object -TypeName System.Windows.Forms.Button

$TabPageRemove = New-Object -TypeName System.Windows.Forms.TabPage

function Get-FormattedString {
    param(
        [string]$string
    )
    return [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($string))
}

Write-Host "Cette page doit rester ouverte pour que l'application PowerShell fonctionne."

# Global "CSS"
$pageWidth = 440 # Changer cette valeur va briser des choses 
$margin = 10 # Changer cette valeur va briser des choses
$verticalSpace = 5
$componentsHeight = 20

# JSON
$jsonPossibleAssociations = "$path/Configuration/PossibleAssociations.json" 
if (Test-Path $jsonPossibleAssociations) {
    $jsonContent = Get-Content -Path $jsonPossibleAssociations | ConvertFrom-Json
    # Dictionnaire Key -> value
    $possibleAssociations = @{}
    
    foreach ($key in $jsonContent.PSObject.Properties.Name) {
        $possibleAssociations[$key] = $jsonContent.$key
    }
} else {
    [System.Windows.Forms.MessageBox]::Show(
        "Le fichier JSON des associations est introuvable.",
        "Erreur",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit
}

$jsonCurrentAssociations = "$path/Configuration/CurrentAssociations.json" 

# Refresh de la liste des registry keys actuelles
function Refresh-CurrentAssociations {
    if (-not (Test-Path $jsonCurrentAssociations)) {
        Write-Host "Le fichier JSON n'existe pas. Création du fichier."
        New-Item -Path $jsonCurrentAssociations -ItemType File -Force
    }    

    # Récupérer les données stockées en JSON
    $global:currentAssociations = Get-Content -Path $jsonCurrentAssociations | ConvertFrom-Json

    if (-not $global:currentAssociationsHashtable) {
        $global:currentAssociationsHashtable = @{}
    } else {
        $global:currentAssociationsHashtable.Clear()
    }    

    foreach ($property in $global:currentAssociations.PSObject.Properties) {
        $global:currentAssociationsHashtable[$property.Name] = $property.Value
    }

    # Appliquer les différentes associations existantes.
    $ComboBoxNameEdit.Items.Clear()
    $ComboBoxNameRemove.Items.Clear()

    $names = $global:currentAssociations.PSObject.Properties.Name

    if ($null -ne $names -and $names.Size -ne 0) {
        $ComboBoxNameEdit.Items.AddRange($names)
        $ComboBoxNameRemove.Items.AddRange($names)
    }
}

<# ############################# #
 #  Page de création de Registre #
 # ############################# #>

function Initialize-PageAdd {
    # Page créer
    $TabPageAdd.Controls.AddRange(@(
        $LabelName, $TextBoxName,
        $LabelDisplayName, $DisplayNameToolTipIcon, $TextBoxDisplayName, 
        $LabelAssociation, $GroupBoxAssociation,
        $GroupBoxOptions,
        $Link, $ConfirmButton
    ))
    $TabPageAdd.Text = Get-FormattedString "Créer"

    # Name
    $LabelName.Location = [System.Drawing.Point]::new($margin, $margin)
    $LabelName.Size = [System.Drawing.Size]::new(150, $componentsHeight)
    $LabelName.Text = Get-FormattedString "*Nom de la clé de registre :"
    $LabelName.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $TextBoxName.Location = [System.Drawing.Point]::new(225, $margin)
    $TextBoxName.Size = [System.Drawing.Size]::new(195, $componentsHeight)

    # Display Name
    $LabelDisplayName.Location = [System.Drawing.Point]::new($margin, $margin + $componentsHeight + $verticalSpace)
    $LabelDisplayName.Size = [System.Drawing.Size]::new(196, $componentsHeight)
    $LabelDisplayName.Text = Get-FormattedString "*Nom de l'entrée du menu contextuel :"
    $LabelDisplayName.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $DisplayNameToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $DisplayNameToolTipIcon.Location = [System.Drawing.Point]::new(206, $margin + $componentsHeight + $verticalSpace + 4)
    $DisplayNameToolTipIcon.SizeMode = 'StretchImage'
    $DisplayNameToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($DisplayNameToolTipIcon, (Get-FormattedString "Modifie le nom de l'option qui sera affiché dans le menu contextuel de l'explorateur de fichiers."))

    $TextBoxDisplayName.Location = [System.Drawing.Point]::new(225, $margin + $componentsHeight + $verticalSpace)
    $TextBoxDisplayName.Size = [System.Drawing.Size]::new(195, $componentsHeight)

    # Associations
    $assocationGroupBoxLocationHeight = $margin + $componentsHeight * 2 + $verticalSpace * 2
    $GroupBoxAssociation.Location = [System.Drawing.Point]::new($margin, $assocationGroupBoxLocationHeight)
    $GroupBoxAssociation.Text = Get-FormattedString "Associations de la clé"
    
    # Associations checkboxes
    $positionAssociation = 0
    foreach($association in $possibleAssociations.GetEnumerator()) {
        $AssociationCheckBox = New-Object -TypeName System.Windows.Forms.CheckBox    
        $AssociationCheckBox.Text = $association.Key
        $AssociationCheckBox.Location = [System.Drawing.Point]::new(
            $margin + ($positionAssociation % 3) * 130, 
            $margin + 10 + ([math]::Floor($positionAssociation / 3)) * ($verticalSpace + $componentsHeight)
        )
        $AssociationCheckBox.Size = [System.Drawing.Point]::new(125, 20) # 390 de large / 3 colonnes (on enleve 5 a la fin de chacuns)
        $GroupBoxAssociation.Controls.Add($AssociationCheckBox)
        $positionAssociation += 1
    }

    $associationGroupBoxHeight = $margin + 10 + ([math]::Floor($positionAssociation / 3) + 1) * ($verticalSpace + $componentsHeight)
    $GroupBoxAssociation.Size = [System.Drawing.Size]::new(
        $pageWidth - 3 * $margin, 
        $associationGroupBoxHeight
    )

    # Options 
    $GroupBoxOptionsLocationHeight = $associationGroupBoxHeight + $assocationGroupBoxLocationHeight + $verticalSpace
    $GroupBoxOptionsHeight = $margin * 2 + 10 + $componentsHeight * 3 + $verticalSpace * 2
    $GroupBoxOptions.Controls.AddRange(@(
        $LabelCommande, $CommandeToolTipIcon, $TextBoxCommande,
        $LabelIcone, $IconeToolTipIcon, $TextBoxIcone, $ChangeIconeButton,
        $LabelPosition, $PositionToolTipIcon, $ComboBoxPosition
    ))
    $GroupBoxOptions.Location = [System.Drawing.Point]::new($margin, $GroupBoxOptionsLocationHeight)
    $GroupBoxOptions.Text = 'Options'
    $GroupBoxOptions.Size = [System.Drawing.Size]::new($pageWidth - 3 * $margin, $GroupBoxOptionsHeight)

    # Commande
    $LabelCommande.Location = [System.Drawing.Point]::new($margin, $margin + 10)
    $LabelCommande.Size = [System.Drawing.Size]::new(129, $componentsHeight)
    $LabelCommande.Text = Get-FormattedString '*Commande à exécuter :'
    $LabelCommande.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $CommandeToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $CommandeToolTipIcon.Location = [System.Drawing.Point]::new(139, $margin + 14)
    $CommandeToolTipIcon.SizeMode = 'StretchImage'
    $CommandeToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($CommandeToolTipIcon, (Get-FormattedString @("Commande à executer lors du clic sur l'option dans le menu contextuel."
    "`n - Pour rouler un script PowerShell : 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"C:/Votre/Path/Complet.ps1`"'"
    "`n - Pour rouler un script Batch : 'C:/Votre/Path/Complet.bat'"
    "`n - Utilisez %V pour passer le répertoire cible en paramètre, ou encore %1 pour passer le fichier cible."
    )))

    $TextBoxCommande.Location = [System.Drawing.Point]::new(165, $margin + 10)
    $TextBoxCommande.Size = [System.Drawing.Size]::new(230, $componentsHeight)

    # Icone
    $LabelIcone.Location = [System.Drawing.Point]::new($margin, $margin + $componentsHeight + $verticalSpace + 10)
    $LabelIcone.Size = [System.Drawing.Size]::new(90, $componentsHeight)
    $LabelIcone.Text = " Modifier l'icone : "
    $LabelIcone.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $IconeToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $IconeToolTipIcon.Location = [System.Drawing.Point]::new(100, $margin + $componentsHeight + $verticalSpace + 13)
    $IconeToolTipIcon.SizeMode = 'StretchImage'
    $IconeToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($IconeToolTipIcon, (Get-FormattedString "(Optionnel) Change le logo de à coté de l'entrée dans le menu contextuel. `nVeuillez entrer le chemin d'accès de l'image à afficher."))

    $TextBoxIcone.Location = [System.Drawing.Point]::new(165, $margin + $componentsHeight + $verticalSpace + 10)
    $TextBoxIcone.Size = [System.Drawing.Size]::new(200, $componentsHeight)

    $ChangeIconeButton.Location = [System.Drawing.Point]::new(369, $margin + $componentsHeight + $verticalSpace + 9) # Décalage de 1 vers le haut car c'est bizarre
    $ChangeIconeButton.Size = [System.Drawing.Size]::new(25, $componentsHeight)
    $ChangeIconeButton.Text = '...'
    $ChangeIconeButton.Add_Click({
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Title = "Choisir une image"
        $fileDialog.InitialDirectory = $destinationDirectory
        $fileDialog.Filter = "All Files (*.*)|*.*|Image Files (*.jpg;*.png;*.ico)|*.jpg;*.png;*.ico"

        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $TextBoxIcone.Text = $fileDialog.FileName
        }
    })

    # Position
    $LabelPosition.Location = [System.Drawing.Point]::new($margin, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 10)
    $LabelPosition.Size = [System.Drawing.Size]::new(110, $componentsHeight)
    $LabelPosition.Text = Get-FormattedString ' Modifier la position :'
    $LabelPosition.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $PositionToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $PositionToolTipIcon.Location = [System.Drawing.Point]::new(120, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 14)
    $PositionToolTipIcon.SizeMode = 'StretchImage'
    $PositionToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($PositionToolTipIcon, (Get-FormattedString "(Optionnel) Change la position de l'entrée dans le menu contextuel."))

    $ComboBoxPosition.Location = [System.Drawing.Point]::new(225, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 10)
    $ComboBoxPosition.Size = [System.Drawing.Size]::new(170, $componentsHeight)
    $ComboBoxPosition.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $positions = @((Get-FormattedString "Ordre alphabétique (défaut)"), "Top", "Bottom")
    $ComboBoxPosition.Items.AddRange($positions)
    $ComboBoxPosition.SelectedItem = Get-FormattedString  "Ordre alphabétique (défaut)"

    # Bouton de confirmation
    $ConfirmButtonLocationHeight = $GroupBoxOptionsLocationHeight + $GroupBoxOptionsHeight + $verticalSpace
    $ConfirmButton.Location = [System.Drawing.Point]::new($pageWidth - $margin * 2 - 75, $ConfirmButtonLocationHeight)
    $ConfirmButton.Size = [System.Drawing.Size]::new(75, $componentsHeight)
    $ConfirmButton.Text = 'Confirmer'
    $ConfirmButton.Add_Click( {
        Write-Host (Get-FormattedString "Confirmation de création...")

        if ([string]::IsNullOrWhiteSpace($TextBoxName.Text) -or
            [string]::IsNullOrWhiteSpace($TextBoxDisplayName.Text) -or 
            [string]::IsNullOrWhiteSpace($TextBoxCommande.Text)) {
            [System.Windows.Forms.MessageBox]::Show(
                (Get-FormattedString "Veuillez remplir tous les champs obligatoires (notés avec '*')."),
                "Erreur",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }

        $selectedAssociations = @()
        foreach ($control in $GroupBoxAssociation.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $associationKey = $control.Text
                $associationValue = $possibleAssociations[$associationKey]
                $selectedAssociations += [PSCustomObject]@{
                    Key   = $associationKey
                    Value = $associationValue
                }
            }
        }

        if ($selectedAssociations.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show(
                (Get-FormattedString "Veuillez sélectionner au moins une association."),
                "Erreur",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }

        if($currentAssociationsHashtable.ContainsKey($TextBoxName.Text)) {
            [System.Windows.Forms.MessageBox]::Show(
                (Get-FormattedString "Cette clé existe dejà sur cet ordinateur."),
                "Erreur",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }
    
        [System.Windows.Forms.MessageBox]::Show(
            (Get-FormattedString "Tous les champs sont valide, début de l'exécution."),
            (Get-FormattedString "Succès"),
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        & "$path/Add-RegistryKey.ps1" -RegistryKeyName $TextBoxName.Text `
                                      -RegistryKeyDisplayName $TextBoxDisplayName.Text `
                                      -Command $TextBoxCommande.Text `
                                      -Associations $selectedAssociations `
                                      -Icon $TextBoxIcone.Text `
                                      -Position $ComboBoxPosition.SelectedItem

        # Refresh de la liste des registry keys actuelles
        Refresh-CurrentAssociations
    })

    # Link
    $Link.Text = "Voir les configurations"
    $Link.Location = [System.Drawing.Point]::new($margin, $ConfirmButtonLocationHeight)
    $Link.Size = [System.Drawing.Point]::new(150, $componentsHeight)
    $Link.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $Link.add_LinkClicked({
        $linkPath = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("$path/Configuration/"))
        Invoke-Item $linkPath
    })

    # Taille de la page
    $global:pageHeight = $ConfirmButtonLocationHeight + $componentsHeight + $margin * 3
}

<# ################################# #
 #  Page de modification de Registre #
 # ################################# #>

function Initialize-PageEdit {
    # Page modifier
    $TabPageEdit.Controls.AddRange(@(
        $LabelNameEdit, $ComboBoxNameEdit,
        $LabelDisplayNameEdit, $DisplayNameTooltipIconEdit, $TextBoxDisplayNameEdit, 
        $LabelAssociationEdit, $GroupBoxAssociationEdit,
        $GroupBoxOptionsEdit,
        $LinkEdit, $ConfirmButtonEdit
    ))
    $TabPageEdit.Text = Get-FormattedString "Modifier"

    # Name
    $LabelNameEdit.Location = [System.Drawing.Point]::new($margin, $margin)
    $LabelNameEdit.Size = [System.Drawing.Size]::new(150, $componentsHeight)
    $LabelNameEdit.Text = Get-FormattedString "*Nom de la clé de registre :"
    $LabelNameEdit.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $ComboBoxNameEdit.Location = [System.Drawing.Point]::new(225, $margin)
    $ComboBoxNameEdit.Size = [System.Drawing.Size]::new(195, $componentsHeight)
    $ComboBoxNameEdit.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $ComboBoxNameEdit.Add_SelectedIndexChanged({
        $selectedName = $ComboBoxNameEdit.SelectedItem
        $selectedItem = $currentAssociationsHashtable[$selectedName]

        # Enable fields
        $TextBoxDisplayNameEdit.Enabled = $true
        $TextBoxCommandeEdit.Enabled = $true
        $TextBoxIconeEdit.Enabled = $true
        $ChangeIconeButtonEdit.Enabled = $true
        $ComboBoxPositionEdit.Enabled = $true
        if(-not [string]::IsNullOrWhiteSpace($selectedName)) {
            $ConfirmButtonEdit.Enabled = $true
        } else {
            $ConfirmButtonEdit.Enabled = $false
        }

        foreach ($control in $GroupBoxAssociationEdit.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox]) {
                $control.Enabled = $true
            }
        }
        
        # Set values to the fields
        $TextBoxDisplayNameEdit.Text = $selectedItem.DisplayName
        $TextBoxCommandeEdit.Text = $selectedItem.Command
        $TextBoxIconeEdit.Text = $selectedItem.Icon
        $ComboBoxPositionEdit.SelectedItem = $selectedItem.Position

        # Check the corresponding associations
        foreach ($control in $GroupBoxAssociationEdit.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox]) {
                $key = $control.Text
        
                # Recocher les bonnes valeurs
                $control.Checked = $selectedItem.Associations | Where-Object { $_.key -eq $key }
            }
        }
    })

    # Display Name
    $LabelDisplayNameEdit.Location = [System.Drawing.Point]::new($margin, $margin + $componentsHeight + $verticalSpace)
    $LabelDisplayNameEdit.Size = [System.Drawing.Size]::new(196, $componentsHeight)
    $LabelDisplayNameEdit.Text = Get-FormattedString "*Nom de l'entrée du menu contextuel :"
    $LabelDisplayNameEdit.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $DisplayNameTooltipIconEdit.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $DisplayNameTooltipIconEdit.Location = [System.Drawing.Point]::new(206, $margin + $componentsHeight + $verticalSpace + 4)
    $DisplayNameTooltipIconEdit.SizeMode = 'StretchImage'
    $DisplayNameTooltipIconEdit.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($DisplayNameTooltipIconEdit, (Get-FormattedString "Modifie le nom de l'option qui sera affiché dans le menu contextuel de l'explorateur de fichiers."))

    $TextBoxDisplayNameEdit.Location = [System.Drawing.Point]::new(225, $margin + $componentsHeight + $verticalSpace)
    $TextBoxDisplayNameEdit.Enabled = $false
    $TextBoxDisplayNameEdit.Size = [System.Drawing.Size]::new(195, $componentsHeight)

    # Associations
    $assocationGroupBoxLocationHeight = $margin + $componentsHeight * 2 + $verticalSpace * 2
    $GroupBoxAssociationEdit.Location = [System.Drawing.Point]::new($margin, $assocationGroupBoxLocationHeight)
    $GroupBoxAssociationEdit.Text = Get-FormattedString "Associations de la clé"
    
    # Associations checkboxes
    $positionAssociation = 0
    foreach($association in $possibleAssociations.GetEnumerator()) {
        $AssociationCheckBox = New-Object -TypeName System.Windows.Forms.CheckBox    
        $AssociationCheckBox.Text = $association.Key
        $AssociationCheckBox.Enabled = $false
        $AssociationCheckBox.Location = [System.Drawing.Point]::new(
            $margin + ($positionAssociation % 3) * 130, 
            $margin + 10 + ([math]::Floor($positionAssociation / 3)) * ($verticalSpace + $componentsHeight)
        )
        $AssociationCheckBox.Size = [System.Drawing.Point]::new(125, 20) # 390 de large / 3 colonnes (on enleve 5 a la fin de chacuns)
        $GroupBoxAssociationEdit.Controls.Add($AssociationCheckBox)
        $positionAssociation += 1
    }

    $associationGroupBoxHeight = $margin + 10 + ([math]::Floor($positionAssociation / 3) + 1) * ($verticalSpace + $componentsHeight)
    $GroupBoxAssociationEdit.Size = [System.Drawing.Size]::new(
        $pageWidth - 3 * $margin, 
        $associationGroupBoxHeight
    )

    # Options 
    $GroupBoxOptionsEditLocationHeight = $associationGroupBoxHeight + $assocationGroupBoxLocationHeight + $verticalSpace
    $GroupBoxOptionsEditHeight = $margin * 2 + 10 + $componentsHeight * 3 + $verticalSpace * 2
    $GroupBoxOptionsEdit.Controls.AddRange(@(
        $LabelCommandeEdit, $CommandeToolTipIconEdit, $TextBoxCommandeEdit,
        $LabelIconeEdit, $IconeToolTipIconEdit, $TextBoxIconeEdit, $ChangeIconeButtonEdit,
        $LabelPositionEdit, $PositionToolTipIconEdit, $ComboBoxPositionEdit
    ))
    $GroupBoxOptionsEdit.Location = [System.Drawing.Point]::new($margin, $GroupBoxOptionsEditLocationHeight)
    $GroupBoxOptionsEdit.Text = 'Options'
    $GroupBoxOptionsEdit.Size = [System.Drawing.Size]::new($pageWidth - 3 * $margin, $GroupBoxOptionsEditHeight)

    # Commande
    $LabelCommandeEdit.Location = [System.Drawing.Point]::new($margin, $margin + 10)
    $LabelCommandeEdit.Size = [System.Drawing.Size]::new(129, $componentsHeight)
    $LabelCommandeEdit.Text = Get-FormattedString '*Commande à exécuter :'
    $LabelCommandeEdit.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $CommandeToolTipIconEdit.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $CommandeToolTipIconEdit.Location = [System.Drawing.Point]::new(139, $margin + 14)
    $CommandeToolTipIconEdit.SizeMode = 'StretchImage'
    $CommandeToolTipIconEdit.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($CommandeToolTipIconEdit, (Get-FormattedString @("Commande à executer lors du clic sur l'option dans le menu contextuel."
    "`n - Pour rouler un script PowerShell : 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"C:/Votre/Path/Complet.ps1`"'"
    "`n - Pour rouler un script Batch : 'C:/Votre/Path/Complet.bat'"
    "`n - Utilisez %V pour passer le répertoire cible en paramètre, ou encore %1 pour passer le fichier cible."
    )))

    $TextBoxCommandeEdit.Location = [System.Drawing.Point]::new(165, $margin + 10)
    $TextBoxCommandeEdit.Enabled = $false
    $TextBoxCommandeEdit.Size = [System.Drawing.Size]::new(230, $componentsHeight)

    # Icone
    $LabelIconeEdit.Location = [System.Drawing.Point]::new($margin, $margin + $componentsHeight + $verticalSpace + 10)
    $LabelIconeEdit.Size = [System.Drawing.Size]::new(90, $componentsHeight)
    $LabelIconeEdit.Text = " Modifier l'icone : "
    $LabelIconeEdit.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $IconeToolTipIconEdit.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $IconeToolTipIconEdit.Location = [System.Drawing.Point]::new(100, $margin + $componentsHeight + $verticalSpace + 13)
    $IconeToolTipIconEdit.SizeMode = 'StretchImage'
    $IconeToolTipIconEdit.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($IconeToolTipIconEdit, (Get-FormattedString "(Optionnel) Change le logo de à coté de l'entrée dans le menu contextuel. `nVeuillez entrer le chemin d'accès de l'image à afficher."))

    $TextBoxIconeEdit.Location = [System.Drawing.Point]::new(165, $margin + $componentsHeight + $verticalSpace + 10)
    $TextBoxIconeEdit.Enabled = $false
    $TextBoxIconeEdit.Size = [System.Drawing.Size]::new(200, $componentsHeight)

    $ChangeIconeButtonEdit.Location = [System.Drawing.Point]::new(369, $margin + $componentsHeight + $verticalSpace + 9) # Décalage de 1 vers le haut car c'est bizarre
    $ChangeIconeButtonEdit.Size = [System.Drawing.Size]::new(25, $componentsHeight)
    $ChangeIconeButtonEdit.Text = '...'
    $ChangeIconeButtonEdit.Enabled = $false
    $ChangeIconeButtonEdit.Add_Click({
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Title = "Choisir une image"
        $fileDialog.InitialDirectory = $destinationDirectory
        $fileDialog.Filter = "All Files (*.*)|*.*|Image Files (*.jpg;*.png;*.ico)|*.jpg;*.png;*.ico"

        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $TextBoxIconeEdit.Text = $fileDialog.FileName
        }
    })

    # Position
    $LabelPositionEdit.Location = [System.Drawing.Point]::new($margin, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 10)
    $LabelPositionEdit.Size = [System.Drawing.Size]::new(110, $componentsHeight)
    $LabelPositionEdit.Text = Get-FormattedString ' Modifier la position :'
    $LabelPositionEdit.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $PositionToolTipIconEdit.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $PositionToolTipIconEdit.Location = [System.Drawing.Point]::new(120, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 14)
    $PositionToolTipIconEdit.SizeMode = 'StretchImage'
    $PositionToolTipIconEdit.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($PositionToolTipIconEdit, (Get-FormattedString "(Optionnel) Change la position de l'entrée dans le menu contextuel."))

    $ComboBoxPositionEdit.Location = [System.Drawing.Point]::new(225, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 10)
    $ComboBoxPositionEdit.Size = [System.Drawing.Size]::new(170, $componentsHeight)
    $ComboBoxPositionEdit.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $positions = @((Get-FormattedString "Ordre alphabétique (défaut)"), "Top", "Bottom")
    $ComboBoxPositionEdit.Items.AddRange($positions)
    $ComboBoxPositionEdit.Enabled = $false
    $ComboBoxPositionEdit.SelectedItem = Get-FormattedString  "Ordre alphabétique (défaut)"

    # Bouton de confirmation
    $ConfirmButtonEditLocationHeight = $GroupBoxOptionsEditLocationHeight + $GroupBoxOptionsEditHeight + $verticalSpace
    $ConfirmButtonEdit.Location = [System.Drawing.Point]::new($pageWidth - $margin * 2 - 75, $ConfirmButtonEditLocationHeight)
    $ConfirmButtonEdit.Size = [System.Drawing.Size]::new(75, $componentsHeight)
    $ConfirmButtonEdit.Text = 'Confirmer'
    $ConfirmButtonEdit.Enabled = $false
    $ConfirmButtonEdit.Add_Click( {
        Write-Host "Confirmation de modification..."
        if ([string]::IsNullOrWhiteSpace($TextBoxDisplayNameEdit.Text) -or 
            [string]::IsNullOrWhiteSpace($TextBoxCommandeEdit.Text)) {
            [System.Windows.Forms.MessageBox]::Show(
                (Get-FormattedString "Veuillez remplir tous les champs obligatoires (notés avec '*')."),
                "Erreur",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }

        $selectedAssociations = @()
        foreach ($control in $GroupBoxAssociationEdit.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $associationKey = $control.Text
                $associationValue = $possibleAssociations[$associationKey]
                $selectedAssociations += [PSCustomObject]@{
                    Key   = $associationKey
                    Value = $associationValue
                }
            }
        }

        if ($selectedAssociations.Size -ge 1) {
            [System.Windows.Forms.MessageBox]::Show(
                (Get-FormattedString "Veuillez sélectionner au moins une association."),
                "Erreur",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }
    

        [System.Windows.Forms.MessageBox]::Show(
            (Get-FormattedString "Tous les champs sont valide, début de l'exécution."),
            (Get-FormattedString "Succès"),
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        & "$path/Remove-RegistryKey.ps1" -registryKeyName $ComboBoxNameEdit.Text

        & "$path/Add-RegistryKey.ps1" -RegistryKeyName $ComboBoxNameEdit.Text `
                                      -RegistryKeyDisplayName $TextBoxDisplayNameEdit.Text `
                                      -Command $TextBoxCommandeEdit.Text `
                                      -Associations $selectedAssociations `
                                      -Icon $TextBoxIconeEdit.Text `
                                      -Position $ComboBoxPositionEdit.SelectedItem
    })

    # Link
    $LinkEdit.Text = "Voir les configurations"
    $LinkEdit.Location = [System.Drawing.Point]::new($margin, $ConfirmButtonEditLocationHeight)
    $LinkEdit.Size = [System.Drawing.Point]::new(150, $componentsHeight)
    $LinkEdit.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $LinkEdit.add_LinkClicked({
        $linkPath = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("$path/Configuration/"))
        Invoke-Item $linkPath
    })
}

<# ################################# #
 #  Page de supression de Registre #
 # ################################# #>

 function Initialize-PageRemove {
    # Page supprimer
    $TabPageRemove.Controls.AddRange(@(
        $LabelNameRemove, $ComboBoxNameRemove,
        $LabelDisplayNameRemove, $DisplayNameTooltipIconRemove, $TextBoxDisplayNameRemove, 
        $LabelAssociationRemove, $GroupBoxAssociationRemove,
        $GroupBoxOptionsRemove,
        $LinkRemove, $ConfirmButtonRemove
    ))
    $TabPageRemove.Text = Get-FormattedString "Supprimer"

    # Name
    $LabelNameRemove.Location = [System.Drawing.Point]::new($margin, $margin)
    $LabelNameRemove.Size = [System.Drawing.Size]::new(150, $componentsHeight)
    $LabelNameRemove.Text = Get-FormattedString "*Nom de la clé de registre :"
    $LabelNameRemove.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $ComboBoxNameRemove.Location = [System.Drawing.Point]::new(225, $margin)
    $ComboBoxNameRemove.Size = [System.Drawing.Size]::new(195, $componentsHeight)
    $ComboBoxNameRemove.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $ComboBoxNameRemove.Add_SelectedIndexChanged({
        $selectedName = $ComboBoxNameRemove.SelectedItem
        $selectedItem = $currentAssociationsHashtable[$selectedName]
        
        # Set values to the fields
        $TextBoxDisplayNameRemove.Text = $selectedItem.DisplayName
        $TextBoxCommandeRemove.Text = $selectedItem.Command
        $TextBoxIconeRemove.Text = $selectedItem.Icon
        $ComboBoxPositionRemove.SelectedItem = $selectedItem.Position
        if(-not [string]::IsNullOrWhiteSpace($selectedName)) {
            $ConfirmButtonRemove.Enabled = $true
        } else {
            $ConfirmButtonRemove.Enabled = $false
        }

        # Check the corresponding associations
        foreach ($control in $GroupBoxAssociationRemove.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox]) {
                $key = $control.Text
        
                # Recocher les bonnes valeurs
                $control.Checked = $selectedItem.Associations | Where-Object { $_.key -eq $key }
            }
        }
    })

    # Display Name
    $LabelDisplayNameRemove.Location = [System.Drawing.Point]::new($margin, $margin + $componentsHeight + $verticalSpace)
    $LabelDisplayNameRemove.Size = [System.Drawing.Size]::new(196, $componentsHeight)
    $LabelDisplayNameRemove.Text = Get-FormattedString "*Nom de l'entrée du menu contextuel :"
    $LabelDisplayNameRemove.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $DisplayNameTooltipIconRemove.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $DisplayNameTooltipIconRemove.Location = [System.Drawing.Point]::new(206, $margin + $componentsHeight + $verticalSpace + 4)
    $DisplayNameTooltipIconRemove.SizeMode = 'StretchImage'
    $DisplayNameTooltipIconRemove.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($DisplayNameTooltipIconRemove, (Get-FormattedString "Modifie le nom de l'option qui sera affiché dans le menu contextuel de l'explorateur de fichiers."))

    $TextBoxDisplayNameRemove.Location = [System.Drawing.Point]::new(225, $margin + $componentsHeight + $verticalSpace)
    $TextBoxDisplayNameRemove.Enabled = $false
    $TextBoxDisplayNameRemove.Size = [System.Drawing.Size]::new(195, $componentsHeight)

    # Associations
    $assocationGroupBoxLocationHeight = $margin + $componentsHeight * 2 + $verticalSpace * 2
    $GroupBoxAssociationRemove.Location = [System.Drawing.Point]::new($margin, $assocationGroupBoxLocationHeight)
    $GroupBoxAssociationRemove.Text = Get-FormattedString "Associations de la clé"
    
    # Associations checkboxes
    $positionAssociation = 0
    foreach($association in $possibleAssociations.GetEnumerator()) {
        $AssociationCheckBox = New-Object -TypeName System.Windows.Forms.CheckBox    
        $AssociationCheckBox.Text = $association.Key
        $AssociationCheckBox.Enabled = $false
        $AssociationCheckBox.Location = [System.Drawing.Point]::new(
            $margin + ($positionAssociation % 3) * 130, 
            $margin + 10 + ([math]::Floor($positionAssociation / 3)) * ($verticalSpace + $componentsHeight)
        )
        $AssociationCheckBox.Size = [System.Drawing.Point]::new(125, 20) # 390 de large / 3 colonnes (on enleve 5 a la fin de chacuns)
        $GroupBoxAssociationRemove.Controls.Add($AssociationCheckBox)
        $positionAssociation += 1
    }

    $associationGroupBoxHeight = $margin + 10 + ([math]::Floor($positionAssociation / 3) + 1) * ($verticalSpace + $componentsHeight)
    $GroupBoxAssociationRemove.Size = [System.Drawing.Size]::new(
        $pageWidth - 3 * $margin, 
        $associationGroupBoxHeight
    )

    # Options 
    $GroupBoxOptionsRemoveLocationHeight = $associationGroupBoxHeight + $assocationGroupBoxLocationHeight + $verticalSpace
    $GroupBoxOptionsRemoveHeight = $margin * 2 + 10 + $componentsHeight * 3 + $verticalSpace * 2
    $GroupBoxOptionsRemove.Controls.AddRange(@(
        $LabelCommandeRemove, $CommandeToolTipIconRemove, $TextBoxCommandeRemove,
        $LabelIconeRemove, $IconeToolTipIconRemove, $TextBoxIconeRemove, $ChangeIconeButtonRemove,
        $LabelPositionRemove, $PositionToolTipIconRemove, $ComboBoxPositionRemove
    ))
    $GroupBoxOptionsRemove.Location = [System.Drawing.Point]::new($margin, $GroupBoxOptionsRemoveLocationHeight)
    $GroupBoxOptionsRemove.Text = 'Options'
    $GroupBoxOptionsRemove.Size = [System.Drawing.Size]::new($pageWidth - 3 * $margin, $GroupBoxOptionsRemoveHeight)

    # Commande
    $LabelCommandeRemove.Location = [System.Drawing.Point]::new($margin, $margin + 10)
    $LabelCommandeRemove.Size = [System.Drawing.Size]::new(129, $componentsHeight)
    $LabelCommandeRemove.Text = Get-FormattedString '*Commande à exécuter :'
    $LabelCommandeRemove.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $CommandeToolTipIconRemove.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $CommandeToolTipIconRemove.Location = [System.Drawing.Point]::new(139, $margin + 14)
    $CommandeToolTipIconRemove.SizeMode = 'StretchImage'
    $CommandeToolTipIconRemove.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($CommandeToolTipIconRemove, (Get-FormattedString @("Commande à executer lors du clic sur l'option dans le menu contextuel."
    "`n - Pour rouler un script PowerShell : 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"C:/Votre/Path/Complet.ps1`"'"
    "`n - Pour rouler un script Batch : 'C:/Votre/Path/Complet.bat'"
    "`n - Utilisez %V pour passer le répertoire cible en paramètre, ou encore %1 pour passer le fichier cible."
    )))

    $TextBoxCommandeRemove.Location = [System.Drawing.Point]::new(165, $margin + 10)
    $TextBoxCommandeRemove.Enabled = $false
    $TextBoxCommandeRemove.Size = [System.Drawing.Size]::new(230, $componentsHeight)

    # Icone
    $LabelIconeRemove.Location = [System.Drawing.Point]::new($margin, $margin + $componentsHeight + $verticalSpace + 10)
    $LabelIconeRemove.Size = [System.Drawing.Size]::new(90, $componentsHeight)
    $LabelIconeRemove.Text = " Modifier l'icone : "
    $LabelIconeRemove.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $IconeToolTipIconRemove.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $IconeToolTipIconRemove.Location = [System.Drawing.Point]::new(100, $margin + $componentsHeight + $verticalSpace + 13)
    $IconeToolTipIconRemove.SizeMode = 'StretchImage'
    $IconeToolTipIconRemove.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($IconeToolTipIconRemove, (Get-FormattedString "(Optionnel) Change le logo de à coté de l'entrée dans le menu contextuel. `nVeuillez entrer le chemin d'accès de l'image à afficher."))

    $TextBoxIconeRemove.Location = [System.Drawing.Point]::new(165, $margin + $componentsHeight + $verticalSpace + 10)
    $TextBoxIconeRemove.Enabled = $false
    $TextBoxIconeRemove.Size = [System.Drawing.Size]::new(200, $componentsHeight)

    $ChangeIconeButtonRemove.Location = [System.Drawing.Point]::new(369, $margin + $componentsHeight + $verticalSpace + 9) # Décalage de 1 vers le haut car c'est bizarre
    $ChangeIconeButtonRemove.Size = [System.Drawing.Size]::new(25, $componentsHeight)
    $ChangeIconeButtonRemove.Text = '...'
    $ChangeIconeButtonRemove.Enabled = $false
    $ChangeIconeButtonRemove.Add_Click({
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Title = "Choisir une image"
        $fileDialog.InitialDirectory = $destinationDirectory
        $fileDialog.Filter = "All Files (*.*)|*.*|Image Files (*.jpg;*.png;*.ico)|*.jpg;*.png;*.ico"

        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $TextBoxIconeRemove.Text = $fileDialog.FileName
        }
    })

    # Position
    $LabelPositionRemove.Location = [System.Drawing.Point]::new($margin, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 10)
    $LabelPositionRemove.Size = [System.Drawing.Size]::new(110, $componentsHeight)
    $LabelPositionRemove.Text = Get-FormattedString ' Modifier la position :'
    $LabelPositionRemove.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $PositionToolTipIconRemove.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
    $PositionToolTipIconRemove.Location = [System.Drawing.Point]::new(120, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 14)
    $PositionToolTipIconRemove.SizeMode = 'StretchImage'
    $PositionToolTipIconRemove.Size = [System.Drawing.Size]::new(12, 12)
    $ToolTip.SetToolTip($PositionToolTipIconRemove, (Get-FormattedString "(Optionnel) Change la position de l'entrée dans le menu contextuel."))

    $ComboBoxPositionRemove.Location = [System.Drawing.Point]::new(225, $margin + 2 * $componentsHeight + 2 * $verticalSpace + 10)
    $ComboBoxPositionRemove.Size = [System.Drawing.Size]::new(170, $componentsHeight)
    $ComboBoxPositionRemove.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $positions = @((Get-FormattedString "Ordre alphabétique (défaut)"), "Top", "Bottom")
    $ComboBoxPositionRemove.Items.AddRange($positions)
    $ComboBoxPositionRemove.Enabled = $false
    $ComboBoxPositionRemove.SelectedItem = Get-FormattedString  "Ordre alphabétique (défaut)"

    # Bouton de confirmation
    $ConfirmButtonRemoveLocationHeight = $GroupBoxOptionsRemoveLocationHeight + $GroupBoxOptionsRemoveHeight + $verticalSpace
    $ConfirmButtonRemove.Location = [System.Drawing.Point]::new($pageWidth - $margin * 2 - 75, $ConfirmButtonRemoveLocationHeight)
    $ConfirmButtonRemove.Size = [System.Drawing.Size]::new(75, $componentsHeight)
    $ConfirmButtonRemove.Text = 'Confirmer'
    $ConfirmButtonRemove.Enabled = $false
    $ConfirmButtonRemove.Add_Click( {
        Write-Host "Confirmation de suppression..."

        [System.Windows.Forms.MessageBox]::Show(
            (Get-FormattedString "Tous les champs sont valide, début de l'exécution."),
            (Get-FormattedString "Succès"),
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        & "$path/Remove-RegistryKey.ps1" -registryKeyName $ComboBoxNameRemove.Text

        # Retirer tous les champs qui sont maintenant inexistants (supprimés)
        $TextBoxDisplayNameRemove.Text = ""
        $TextBoxCommandeRemove.Text = ""
        $TextBoxIconeRemove.Text = ""
        $ComboBoxPositionRemove.SelectedItem = ""
        $ConfirmButtonRemove.Enabled = $false

        foreach ($control in $GroupBoxAssociationRemove.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox]) {
                $control.Checked = $false
            }
        }

        $TextBoxDisplayNameEdit.Text = ""
        $TextBoxCommandeEdit.Text = ""
        $TextBoxIconeEdit.Text = ""
        $ComboBoxPositionEdit.SelectedItem = ""
        $ConfirmButtonEdit.Enabled = $false

        foreach ($control in $GroupBoxAssociationEdit.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox]) {
                $control.Checked = $false
            }
        }
        
        # Refresh de la liste des registry keys actuelles
        Refresh-CurrentAssociations
    })

    # Link
    $LinkRemove.Text = "Voir les configurations"
    $LinkRemove.Location = [System.Drawing.Point]::new($margin, $ConfirmButtonRemoveLocationHeight)
    $LinkRemove.Size = [System.Drawing.Point]::new(150, $componentsHeight)
    $LinkRemove.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $LinkRemove.add_LinkClicked({
        $linkPath = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("$path/Configuration/"))
        Invoke-Item $linkPath
    })
}

function InitializePages {
    # TabControl
    $TabControl.Controls.AddRange(@($TabPageAdd, $TabPageEdit, $TabPageRemove))
    $TabControl.Location = [System.Drawing.Point]::new(0, 0)
    $TabControl.SelectedIndex = 0

    # Refresh de la liste des registry keys actuelles
    Refresh-CurrentAssociations

    # Ajout des pages
    Initialize-PageAdd
    Initialize-PageEdit
    Initialize-PageRemove

    # Form
    
    $TabControl.Size = [System.Drawing.Point]::new($pageWidth, $pageHeight)
    $Form.ClientSize = [System.Drawing.Point]::new($pageWidth, $pageHeight)
    $Form.Controls.Add($TabControl)
    $Form.MaximizeBox = $false
    $Form.FormBorderStyle = 'FixedDialog'
    $Form.Text = Get-FormattedString 'UdeS - Outil de manipulation de clés de registres'
    $Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$path/../icon.ico")
    $Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
}

InitializePages
$Form.ShowDialog()
