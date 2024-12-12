param (
    [Parameter(mandatory=$true)]
    [string]$inputFile,
    [Parameter(mandatory=$false)]
    [switch]$inLine,
    [Parameter(mandatory=$false)]
    [switch]$addAlias
)
# Activation du deboggage du script.
$debugMode = $false

$path = Split-Path $script:MyInvocation.MyCommand.Path
. ($path + "\Format-SQL.ps1")

# Gestion de fichier d'entrée (erreur lorsqu'il n'est pas SQL)
if(-not ($inputFile -like "*.sql")) {
    Write-Warning "(!) Le fichier $inputFile n'est pas un fichier .sql valide."
    return
}
    
# Nécessaire pour conserver les accents.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$sqlScript = Get-Content $inputFile -Raw


if($addAlias) {
    $formattedSQL = Escape-Strings -sql $sqlScript
    $formattedSQL = Add-Aliases -sql $formattedSQL
    $formattedSQL = Apply-Escaped -sql $formattedSQL 
} else {
    if($debugMode) {
        Write-Host "`n-- --------------------------- -- "
        Write-Host "-- DOCUMENT RECU EN POWERSHELL -- "
        Write-Host "-- --------------------------- -- "
        Write-Host $sqlScript
    }

    $formattedSQL = Escape-Strings -sql $sqlScript
    $formattedSQL = Refactor-SQL -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- --------------------------------- -- "
        Write-Host "-- DOCUMENT REFACTORED SUR UNE LIGNE -- "
        Write-Host "-- --------------------------------- -- "
        Write-Host $formattedSQL
    }

    $formattedSQL = Split-SQL -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- --------------------------------- -- "
        Write-Host "-- DOCUMENT SPLIT AVEC FORMAT SIMPLE -- "
        Write-Host "-- --------------------------------- -- "
        Write-Host $formattedSQL
    }

    $formattedSQL = Reformat-SQL -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- ----------------------------------------------- -- "
        Write-Host "-- DOCUMENT AVEC FORMAT CORRECT SANS L'INDENTATION -- "
        Write-Host "-- ----------------------------------------------- -- "
        Write-Host $formattedSQL
    }

    $formattedSQL = Reindent-SQL -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- --------------------------------------------------- -- "
        Write-Host "-- DOCUMENT REINDENTE AVEC LES ; DANS FORMAT INCORRECT -- "
        Write-Host "-- --------------------------------------------------- -- "
        Write-Host $formattedSQL
    }

    $formattedSQL = Reindent-SemiColon -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- ------------------------------------------- -- "
        Write-Host "-- DOCUMENT REINDENTE SANS LES ESCAPED STRINGS -- "
        Write-Host "-- ------------------------------------------- -- "
        Write-Host $formattedSQL
    }

    $formattedSQL = Apply-Escaped -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- ---------------------------------------------------- -- "
        Write-Host "-- DOCUMENT REINDENTE AVEC DES RETOURS DE LIGNE EN TROP -- "
        Write-Host "-- ---------------------------------------------------- -- "
        Write-Host $formattedSQL
    }

    $formattedSQL = Remove-Extra -sql $formattedSQL
    if($debugMode) {
        Write-Host "`n-- -------------- -- "
        Write-Host "-- DOCUMENT FINAL -- "
        Write-Host "-- -------------- -- "
    }

    if($escapedComments.Count -gt 0) {
        $formattedSQL = "-- Attention : Les commentaires initialement en fin de ligne peuvent être mal placé(s).`n`n" + $formattedSQL
    }
}

return $formattedSQL