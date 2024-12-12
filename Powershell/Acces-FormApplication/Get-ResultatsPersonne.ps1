

param (
    [Parameter(mandatory=$true)]
    [string]$cipUsager,
    [Parameter(mandatory=$true)]
    [string]$cipPassword,
    [Parameter(mandatory=$true)]
    [string]$cipPersonne,
    [Parameter(mandatory=$true)]
    [string]$dbUser,
    [Parameter(mandatory=$true)]
    [string]$dbPassword
)

$dbJson = Get-Content -Path "$path/config/database.json" -Raw | ConvertFrom-Json

$dbList = $dbJson.PSObject.Properties |
                   Where-Object { $_.Name -ne "ssh_host" } |
                   Select-Object -ExpandProperty Name

# Paramètres SSH
$sshHost = $dbJson.ssh_host

# JsonObject
$jsonString = @{
    databaseConnections = @(
        foreach ($database in $dbList) {
            $connection = @{
                name     = $database
                server   = $dbJson.$database.db_host
                port     = $dbJson.$database.db_port
                user     = $dbUser
                password = $dbPassword
            }

            if ($dbJson.$database.ssh_db_port) {
                $connection.sshServer = $sshHost
                $connection.sshPort = $dbJson.$database.ssh_db_port
                $connection.sshUser = $cipUsager
                $connection.sshPassword = $cipPassword
            }

            $connection
        }
    )
}

$jsonObject = $jsonString | ConvertTo-Json

# Execution de la procédure sur tous les environnements.
$results = & "$path/Get-AccesPersonne.ps1" -json $jsonObject

$allResults = @()
$resultsAcces = @()
foreach ($result in $results) {
    $object = [PSCustomObject]@{
        Serveur                = $result.Serveur
        CIP                    = $result.Result.CIP
        Intervenants           = $result.Result.Intervenants
        Profils_Responsabilite = $result.Result.Profils_Responsabilite
        Date_Verification      = $result.Result.Date_Verification
        Acces_Administratif    = $result.Result.Acces_Administratif
    }
    
    $allResults += $object
    if($result.Result.Acces_Administratif -gt 0) {
        $resultsAcces += $result.Serveur
    }
}

Write-Host "`n------------------------------------------"
Write-Host "-               Résultats                -" -foreground Green
Write-Host "------------------------------------------"
$allResults | Format-Table -AutoSize

$exportPath = "C:/Users/$cipUsager/Desktop/VEO_Vérif_Accès_CIP/VEO_access_CIP_$cipPersonne.csv"
$allResults | Export-Csv -Path $exportPath -NoTypeInformation -Delimiter ';'

$count = $resultsAcces.Count
if($count -eq 0) {
    Write-Host "Le CIP [$cipPersonne] n'a aucun accès administratif VEO1." -foreground Green
} else {
    Write-Host "Le CIP [$cipPersonne] possède des accès administratifs sur $count environnement(s) VEO1 :" -foreground Red
    foreach ($result in $resultsAcces) {
        Write-Host " - $result" -foreground Red
    }
}

Write-Host "`nFichier exporté : $exportPath`n"