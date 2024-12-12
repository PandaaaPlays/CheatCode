param(
    [Parameter(mandatory=$true)]
    [string]$registryKeyName
)

$path = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Récupération de la clé ajoutée et ses associations..."
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

foreach($association in $currentAssociationsHashtable[$registryKeyName].Associations) {
    $associationPath = $association.Value

    $registryPath = "$associationPath\$registryKeyName"

    Write-Host "Suppression de la clé de registre: $registryPath"
    if (Test-Path $registryPath) {
        Remove-Item -Path $registryPath -Recurse -Force
        Write-Host "Entrée du menu de contexte '$registryKeyName' retirée."
    } else {
        Write-Host "Clé de registre '$registryKeyName' introuvable (répertoire)."
    }
}

$currentAssociationsHashtable.Remove($registryKeyName)
$newAssociationsJson = $currentAssociationsHashtable | ConvertTo-Json -Depth 5
$newAssociationsJson | Out-File -FilePath $currentAssociationsJson -Force -Encoding UTF8