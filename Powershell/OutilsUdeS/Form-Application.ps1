param(
    [Parameter(mandatory=$true)]
    [string]$cibleDirectory
)

Write-Host "Cette page doit rester ouverte pour que l'application PowerShell fonctionne."

# Directory ou CSV
if ((Get-Item $cibleDirectory).PSIsContainer) {
    $isDirectory = $true
    $destinationDirectory = (Get-Item $cibleDirectory).Parent.FullName
} else {
    $isDirectory = $false
    $destinationDirectory = (Get-Item $cibleDirectory).DirectoryName
}

# Global informations
$path = Split-Path $script:MyInvocation.MyCommand.Path
Add-Type -AssemblyName System.Windows.Forms

# Initialisation des components
$Form = New-Object -TypeName System.Windows.Forms.Form
$DirectoryGroupBox = (New-Object -TypeName System.Windows.Forms.GroupBox)
$CibleDirectoryLabel = (New-Object -TypeName System.Windows.Forms.Label)
$CibleDirectoryTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$ChangeCibleDirectoryButton = (New-Object -TypeName System.Windows.Forms.Button)
$DestinationDirectoryLabel = (New-Object -TypeName System.Windows.Forms.Label)
$DestinationDirectoryTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$ChangeDestinationDirectoryButton = (New-Object -TypeName System.Windows.Forms.Button)
$OptionsGroupBox = (New-Object -TypeName System.Windows.Forms.GroupBox)
$ConfirmButton = (New-Object -TypeName System.Windows.Forms.Button)

# CSV to SQL form et Merge SQL
$OutputFileNameLabel = (New-Object -TypeName System.Windows.Forms.Label)
$OutputFileNameTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$DatabaseNameLabel = (New-Object -TypeName System.Windows.Forms.Label)
$DatabaseNameTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$TableNameLabel = (New-Object -TypeName System.Windows.Forms.Label)
$TableNameTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$SplitterGroupBox = (New-Object -TypeName System.Windows.Forms.GroupBox)
$ColumnsLabel = (New-Object -TypeName System.Windows.Forms.Label)
$ColumnsTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$FilterLabel = (New-Object -TypeName System.Windows.Forms.Label)
$FilterTextBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$ToolTip = New-Object System.Windows.Forms.ToolTip
$ColumnsToolTipIcon = New-Object System.Windows.Forms.PictureBox
$FilterToolTipIcon = New-Object System.Windows.Forms.PictureBox
$OutputFileToolTipIcon = New-Object System.Windows.Forms.PictureBox

function Get-FormattedString {
    param(
        [string]$string
    )
    return [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($string))
}

function InitializeComponents {
    # GroupBox des directories.
    $DirectoryGroupBox.Controls.AddRange(@($CibleDirectoryLabel, $CibleDirectoryTextBox, $ChangeCibleDirectoryButton, $DestinationDirectoryLabel, $DestinationDirectoryTextBox, $ChangeDestinationDirectoryButton))
    $DirectoryGroupBox.Location = [System.Drawing.Point]::new(10, 10)
    $DirectoryGroupBox.Size = [System.Drawing.Size]::new(680, 75)
    $DirectoryGroupBox.TabStop = $false
    $DirectoryGroupBox.Text = Get-FormattedString 'Répertoires de travail' 
    
    # Répertoire cible
    $CibleDirectoryLabel.Location = [System.Drawing.Point]::new(10, 20)
    $CibleDirectoryLabel.Size = [System.Drawing.Size]::new(110, 20)
    if($isDirectory) {
        $CibleDirectoryLabel.Text = Get-FormattedString 'Répertoire cible :'
    } else {
        $CibleDirectoryLabel.Text = Get-FormattedString 'Fichier cible :'
    }
    $CibleDirectoryLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $CibleDirectoryTextBox.Location = [System.Drawing.Point]::new(160, 20)
    $CibleDirectoryTextBox.Size = [System.Drawing.Size]::new(480, 20)
    $CibleDirectoryTextBox.TabIndex = 1
    $CibleDirectoryTextBox.Text = $cibleDirectory

    $ChangeCibleDirectoryButton.Location = [System.Drawing.Point]::new(645, 19) # Décalage de 1 vers le haut car c'est bizarre
    $ChangeCibleDirectoryButton.Size = [System.Drawing.Size]::new(25, 20)
    $ChangeCibleDirectoryButton.TabIndex = 2
    $ChangeCibleDirectoryButton.Text = '...'
    $ChangeCibleDirectoryButton.Add_Click({
        if((Get-Item $cibleDirectory).PSIsContainer) {
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderDialog.Description = Get-FormattedString "Choisir un répertoire"
            $folderDialog.SelectedPath = $destinationDirectory
            $folderDialog.ShowNewFolderButton = $true

            if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $CibleDirectoryTextBox.Text = $folderDialog.SelectedPath
            }
        } else {
            $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
            $fileDialog.Title = "Choisir un fichier"
            $fileDialog.InitialDirectory = $destinationDirectory
            $fileDialog.Filter = "CSV Files (*.csv)|*.csv"    

            if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $CibleDirectoryTextBox.Text = $fileDialog.FileName
            }
        }
    })

    # Répertoire de destination
    $DestinationDirectoryLabel.Location = [System.Drawing.Point]::new(10, 45)
    $DestinationDirectoryLabel.Size = [System.Drawing.Size]::new(140, 20)
    $DestinationDirectoryLabel.Text = Get-FormattedString 'Répertoire de destination :'
    $DestinationDirectoryLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

    $DestinationDirectoryTextBox.Location = [System.Drawing.Point]::new(160, 45)
    $DestinationDirectoryTextBox.Size = [System.Drawing.Size]::new(480, 20)
    $DestinationDirectoryTextBox.TabIndex = 3
    $DestinationDirectoryTextBox.Text = $destinationDirectory

    $ChangeDestinationDirectoryButton.Location = [System.Drawing.Point]::new(645, 44) # Décalage de 1 vers le haut car c'est bizarre
    $ChangeDestinationDirectoryButton.Size = [System.Drawing.Size]::new(25, 20)
    $ChangeDestinationDirectoryButton.TabIndex = 4
    $ChangeDestinationDirectoryButton.Text = '...'
    $ChangeDestinationDirectoryButton.Add_Click({
        $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderDialog.Description = Get-FormattedString "Choisir un répertoire"
        $folderDialog.SelectedPath = $destinationDirectory
        $folderDialog.ShowNewFolderButton = $true
        if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $DestinationDirectoryTextBox.Text = $folderDialog.SelectedPath
        }
    })

    # GroupBox des options
    $OptionsGroupBox.Location = [System.Drawing.Point]::new(10, 90)
    $OptionsGroupBox.Text = 'Options'

    if($isDirectory) {
        # Merge SQL
        $OptionsGroupBox.Size = [System.Drawing.Size]::new(680, 50)
        $OptionsGroupBox.Controls.AddRange(@($OutputFileNameLabel, $OutputFileNameTextBox, $SplitterGroupBox, $FilterLabel, $FilterTextBox, $FilterToolTipIcon, $OutputFileToolTipIcon))

        # Nom du fichier en Output
        $OutputFileNameLabel.Location = [System.Drawing.Point]::new(10, 20)
        $OutputFileNameLabel.Size = [System.Drawing.Size]::new(124, 20)
        $OutputFileNameLabel.Text = Get-FormattedString 'Nom du fichier exporté :'
        $OutputFileNameLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $OutputFileToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
        $OutputFileToolTipIcon.Location = [System.Drawing.Point]::new(134, 24)
        $OutputFileToolTipIcon.SizeMode = 'StretchImage'
        $OutputFileToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
        $ToolTip.SetToolTip($OutputFileToolTipIcon, "Entrez le nom du fichier de sortie sans mentionner l'extension de celui-ci.")

        $OutputFileNameTextBox.Location = [System.Drawing.Point]::new(160, 20)
        $OutputFileNameTextBox.Size = [System.Drawing.Size]::new(160, 20)
        $OutputFileNameTextBox.Text = "All_Merged_" + (Get-Item $CibleDirectoryTextBox.Text).Name
        $OutputFileNameTextBox.TabIndex = 5

        # Splitter
        $SplitterGroupBox.Location = [System.Drawing.Point]::new(330, 10)
        $SplitterGroupBox.Size = [System.Drawing.Point]::new(2, 30)

        # Column names
        $FilterLabel.Location = [System.Drawing.Point]::new(342, 20)
        $FilterLabel.Size = [System.Drawing.Size]::new(104, 20)
        $FilterLabel.Text = "Filtre d'extensions :"
        $FilterLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $FilterToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
        $FilterToolTipIcon.Location = [System.Drawing.Point]::new(446, 24)
        $FilterToolTipIcon.SizeMode = 'StretchImage'
        $FilterToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
        $ToolTip.SetToolTip($FilterToolTipIcon, (Get-FormattedString "Entrez les extensions qui doivent être détectées séparées d'une virgule (ex.: *.sql, *.upd)"))

        $FilterTextBox.Location = [System.Drawing.Point]::new(470, 20)
        $FilterTextBox.Size = [System.Drawing.Size]::new(200, 20)
        $FilterTextBox.Text = "*.sql, *gdl, *.upd"
        $FilterTextBox.TabIndex = 6

        # Button de confirmation
        $ConfirmButton.Location = [System.Drawing.Point]::new(615, 145)
        $ConfirmButton.Size = [System.Drawing.Size]::new(75, 20)
        $ConfirmButton.TabIndex = 7
        $ConfirmButton.Text = 'Confirmer'
        $ConfirmButton.Add_Click( {
            if ([string]::IsNullOrWhiteSpace($CibleDirectoryTextBox.Text) -or
                [string]::IsNullOrWhiteSpace($DestinationDirectoryTextBox.Text) -or 
                [string]::IsNullOrWhiteSpace($OutputFileNameTextBox.Text) -or
                [string]::IsNullOrWhiteSpace($FilterTextBox.Text)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Veuillez remplir tous les champs.",
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

            & "$path/SQLMerger/Exec-SQLMergeFiles.ps1" -SourceDirectory $CibleDirectoryTextBox.Text `
                                                       -OutputDirectory $DestinationDirectoryTextBox.Text `
                                                       -OutputFileName  $OutputFileNameTextBox.Text `
                                                       -SearchPattern $FilterTextBox.Text 
        })

        $Form.ClientSize = [System.Drawing.Size]::new(700, 175)
    } else {
        # CSV to SQL
        $OptionsGroupBox.Size = [System.Drawing.Size]::new(680, 100)
        $OptionsGroupBox.Controls.AddRange(@($OutputFileNameLabel, $OutputFileNameTextBox, $DatabaseNameLabel, $DatabaseNameTextBox, 
            $TableNameLabel, $TableNameTextBox, $SplitterGroupBox, $ColumnsLabel, $ColumnsTextBox, $ColumnsToolTipIcon, $OutputFileToolTipIcon))

        # Nom du fichier en Output
        $OutputFileNameLabel.Location = [System.Drawing.Point]::new(10, 20)
        $OutputFileNameLabel.Size = [System.Drawing.Size]::new(124, 20)
        $OutputFileNameLabel.Text = Get-FormattedString 'Nom du fichier exporté :'
        $OutputFileNameLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $OutputFileToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
        $OutputFileToolTipIcon.Location = [System.Drawing.Point]::new(134, 24)
        $OutputFileToolTipIcon.SizeMode = 'StretchImage'
        $OutputFileToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
        $ToolTip.SetToolTip($OutputFileToolTipIcon, "Entrez le nom du fichier de sortie sans mentionner l'extension de celui-ci.")

        $OutputFileNameTextBox.Location = [System.Drawing.Point]::new(160, 20)
        $OutputFileNameTextBox.Size = [System.Drawing.Size]::new(160, 20)
        $OutputFileNameTextBox.Text = "Converted_" + (Get-Item $CibleDirectoryTextBox.Text).BaseName
        $OutputFileNameTextBox.TabIndex = 5

        # Nom de la base de donnée
        $DatabaseNameLabel.Location = [System.Drawing.Point]::new(10, 45)
        $DatabaseNameLabel.Size = [System.Drawing.Size]::new(150, 20)
        $DatabaseNameLabel.Text = Get-FormattedString 'Nom de la base de donnée :'
        $DatabaseNameLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $DatabaseNameTextBox.Location = [System.Drawing.Point]::new(160, 45)
        $DatabaseNameTextBox.Size = [System.Drawing.Size]::new(160, 20)
        $DatabaseNameTextBox.TabIndex = 6

        # Nom de la table
        $TableNameLabel.Location = [System.Drawing.Point]::new(10, 70)
        $TableNameLabel.Size = [System.Drawing.Size]::new(150, 20)
        $TableNameLabel.Text = Get-FormattedString 'Nom de la table :'
        $TableNameLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $TableNameTextBox.Location = [System.Drawing.Point]::new(160, 70)
        $TableNameTextBox.Size = [System.Drawing.Size]::new(160, 20)
        $TableNameTextBox.TabIndex = 7

        # Splitter
        $SplitterGroupBox.Location = [System.Drawing.Point]::new(330, 10)
        $SplitterGroupBox.Size = [System.Drawing.Point]::new(2, 80)

        # Column names
        $ColumnsLabel.Location = [System.Drawing.Point]::new(342, 20)
        $ColumnsLabel.Size = [System.Drawing.Size]::new(58, 20)
        $ColumnsLabel.Text = 'Colonnes :'
        $ColumnsLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

        $ColumnsToolTipIcon.Image = [System.Drawing.Image]::FromFile("$path\circle-info-solid.png") # Path to the icon
        $ColumnsToolTipIcon.Location = [System.Drawing.Point]::new(400, 24)
        $ColumnsToolTipIcon.SizeMode = 'StretchImage'
        $ColumnsToolTipIcon.Size = [System.Drawing.Size]::new(12, 12)
        $ToolTip.SetToolTip($ColumnsToolTipIcon, (Get-FormattedString "Entrez le nom des différentes colonnes à associer avec le CSV en les séparant d'une virgule (e.g: colA, colB)"))

        $ColumnsTextBox.Location = [System.Drawing.Point]::new(342, 45)
        $ColumnsTextBox.Size = [System.Drawing.Size]::new(328, 45)
        $ColumnsTextBox.Multiline = $true
        $ColumnsTextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $ColumnsTextBox.TabIndex = 8

        # Button de confirmation
        $ConfirmButton.Location = [System.Drawing.Point]::new(615, 195)
        $ConfirmButton.Size = [System.Drawing.Size]::new(75, 20)
        $ConfirmButton.TabIndex = 9
        $ConfirmButton.Text = 'Confirmer'
        $ConfirmButton.Add_Click( {
            if ([string]::IsNullOrWhiteSpace($CibleDirectoryTextBox.Text) -or
                [string]::IsNullOrWhiteSpace($DestinationDirectoryTextBox.Text) -or 
                [string]::IsNullOrWhiteSpace($OutputFileNameTextBox.Text) -or
                [string]::IsNullOrWhiteSpace($DatabaseNameTextBox.Text) -or
                [string]::IsNullOrWhiteSpace($TableNameTextBox.Text) -or
                [string]::IsNullOrWhiteSpace($ColumnsTextBox.Text)) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Veuillez remplir tous les champs.",
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

            & "$path/CSVConverter/Convert-CSVToSQL.ps1" -CSVFile $CibleDirectoryTextBox.Text `
                                                        -OutputDirectory $DestinationDirectoryTextBox.Text `
                                                        -OutputFileName  $OutputFileNameTextBox.Text `
                                                        -DatabaseName $DatabaseNameTextBox.Text `
                                                        -SQLTableName $TableNameTextBox.Text `
                                                        -Columns $ColumnsTextBox.Text 
        })

        $Form.ClientSize = [System.Drawing.Size]::new(700, 225)
    }
    
    # Form
    $Form.Controls.AddRange(@($DirectoryGroupBox, $OptionsGroupBox, $ConfirmButton))
    $Form.MaximizeBox = $false
    $Form.FormBorderStyle = 'FixedDialog'

    if((Get-Item $cibleDirectory).PSIsContainer) {
        $Form.Text = Get-FormattedString 'UdeS - Outil de merge SQL'
    } else {
        $Form.Text = Get-FormattedString 'UdeS - Outil de conversion CSV vers SQL'
    }
    $Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$path/icon.ico")
    $Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
}

InitializeComponents
[void]$Form.ShowDialog()