<#########################################################################################################
Résumé      :	Lancement de la vérification des accès sous VEO 1
----------------------------------------------------------------------------------------------------------
Description :	Exécution du script Python 'VEO_acces_CIP.py' dans l'environnement virtuel dédié.
----------------------------------------------------------------------------------------------------------
/!\ NOTE /!\:   ... 
#########################################################################################################>

$path = Split-Path $script:MyInvocation.MyCommand.Path

# Pour info #
Write-Host "------------------------------------------"
Write-Host "- Vérification des accès VEO pour un CIP -" -foreground Green
Write-Host "------------------------------------------"

# Récupération du Cip de l'usager
$cipUsager = $Env:UserName

# Récupération du pwd utilisateur
Invoke-Expression -Command ". $path\init\config.ps1"

# Exécution du script de vérification des accès
$continue = $true

# Loop de demande si on veut executer le script à nouveau
while ($continue) {
    # Demande du CIP à vérifier
    $cipPersonne = Read-Host -Prompt 'Entrez le CIP à vérifier :'

    # Récupération des infos dans PasswordState
    Invoke-Expression -Command ". $path\init\PasswordStateMain.ps1"

    # Execution du script
    & "$path\Get-ResultatsPersonne.ps1" -cipUsager $cipUsager -cipPassword $cipPassword -cipPersonne $cipPersonne -dbUser $dbUser -dbPassword $dbPassword

    $response = $(Write-Host "Souhaitez vous vérifier un autre CIP? (O/N): " -ForegroundColor Blue -NoNewline; Read-Host)
    if ($response -ne 'O' -and $response -ne 'o') {
        $continue = $false
    }
}

Write-Host "------------------------------------------"
Write-Host "-                Terminé                 -" -foreground Green
Write-Host "------------------------------------------"

Write-Host "Appuyez sur [Entrée] pour fermer la fenêtre." -foreground Blue
Read-Host # Attend pour Enter

exit