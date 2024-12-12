param(
    [Parameter(mandatory=$true)]
    [string]$RegistryKeyName,      
    [Parameter(mandatory=$true)]
    [string]$RegistryKeyDisplayName,  
    [Parameter(mandatory=$true)]
    [string]$Command,  
    [Parameter(mandatory=$true)]
    [PSCustomObject[]]$Associations,   
    [Parameter(mandatory=$false)]     
    [string]$Icon,
    [Parameter(mandatory=$false)]     
    [string]$Position
)

Write-Host "Création des clés de registres: "
foreach ($Association in $Associations) {
    # Déclaration des Paths
    $associationPath = $Association.Value
    $registryPath = "$associationPath\$RegistryKeyName"
    $commandPath = "$registryPath\command"
    
    Write-Host " - $registryPath (Command : $command)"

    # Création des registres
    New-Item -Path $registryPath -Force | Out-Null
    New-Item -Path $commandPath -Force | Out-Null

    # Command
    Set-ItemProperty -Path $commandPath -Name "(Default)" -Value $command -Force

    # Display Name
    Set-ItemProperty -Path $registryPath -Name "(Default)" -Value $RegistryKeyDisplayName -Force
    
    # Position
    if($Position -and $Position -eq "Top") {
        Set-ItemProperty -Path $registryPath -Name "Position" -Value "Top" -Force
    } elseif ($Position -eq "Bottom") {
        Set-ItemProperty -Path $registryPath -Name "Position" -Value "Bottom" -Force
    }

    # Icon
    if($Icon -and $Icon -ne "") {
        Set-ItemProperty -Path $registryPath -Name "Icon" -Value $Icon -Force
    }
}

Write-Host "Sauvergarde de la clé ajoutée et ses associations..."
$currentAssociationsJson = "$path/Configuration/CurrentAssociations.json"

if (Test-Path $currentAssociationsJson) {
    $currentAssociationsString = Get-Content $currentAssociationsJson | ConvertFrom-Json
} else {
    Write-Host "Le fichier JSON n'existe pas. Création du fichier."
    New-Item -Path $currentAssociationsJson -ItemType File -Force
}    

$currentAssociationsHashtable = @{}

# Copy all properties of the PSObject into the hashtable
foreach ($property in $currentAssociationsString.PSObject.Properties) {
    $currentAssociationsHashtable[$property.Name] = $property.Value
}

$currentAssociationsHashtable[$RegistryKeyName] = @{
    DisplayName = $RegistryKeyDisplayName
    Command = $Command
}

if ($Icon -and $Icon -ne "") {
    $currentAssociationsHashtable[$RegistryKeyName]["Icon"] = $Icon
}

if ($Position -and ($Position -eq "Top" -or $Position -eq "Bottom")) {
    $currentAssociationsHashtable[$RegistryKeyName]["Position"] = $Position
}

if ($Associations -and $Associations.Count -gt 0) {
    $currentAssociationsHashtable[$RegistryKeyName]["Associations"] = @()

    foreach ($association in $Associations) {
        $currentAssociationsHashtable[$RegistryKeyName]["Associations"] += @{
            Key = $association.Key
            Value = $association.Value
        }
    }
}

# Conversion vers JSON
$newAssociationsJson = $currentAssociationsHashtable | ConvertTo-Json -Depth 5
$newAssociationsJson | Out-File -FilePath $currentAssociationsJson -Force -Encoding UTF8

Write-Host "Les entrées du menu de contexte ont été ajoutées et sauvegardées."