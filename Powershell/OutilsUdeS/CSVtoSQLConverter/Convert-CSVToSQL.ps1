param (
    [Parameter(mandatory=$true)]
    [string]$CSVFile,
	[Parameter(mandatory=$true)]
    [string]$OutputDirectory,
    [Parameter(mandatory=$true)]
    [string]$OutputFileName,
    [Parameter(mandatory=$true)]
    [string]$DatabaseName,
	[Parameter(mandatory=$true)]
    [string]$SQLTableName,
    [Parameter(mandatory=$true)]
    [string]$Columns
)

# ------------------------------------------------ #
# Conversion d'un fichier CSV en script SQL INSERT #
#   ( Version spécifique MS SQL Server (T-SQL) )   #
# ------------------------------------------------ #

# Global informations
$ReadingFileEncoding = "Default"
$OutputFileEncoding = "utf8" 		# UTF-8 with BOM par défaut (Windows PowerShell)

# ---------------------------- #
# Test du script de conversion #
# ---------------------------- #
<#$path = Split-Path $script:MyInvocation.MyCommand.Path
$CSVFile = "$path\Test.csv"
$OutputDirectory = $path
Write-Host " - Fichier source (CSV) : $CSVFile"
Write-Host " - Table : $SQLTableName"
Write-Host " - Colonnes : $Columns"#>

# ---------- #
# Préalables #
# ---------- #
$FileName = $(Split-Path $CSVFile -leaf)
$FullOutputPath = $OutputDirectory + "\" + $OutputFileName + ".sql"
#  - Full Output Path : $FullOutputPath"

# On supprime le fichier converti s'il existe deja
if (Test-Path $FullOutputPath) {
	Remove-Item -Path $FullOutputPath
}

# ------------------------ #
# Préparation des colonnes #
# ------------------------ #
$ColumnsDefinition = @()

# Ajout d'un Line ID, pour se repérer #
$LineID = "LID INT IDENTITY PRIMARY KEY"
$ColumnsDefinition += $LineID

foreach ($Column in $Columns) {
	# On défini tout en VARCHAR pour plus de simplicité 
	$ColumnDefinition = ($Column + " VARCHAR(MAX)")
	$ColumnsDefinition += $ColumnDefinition
}

# -------------------------- #
# Formatage SQL des colonnes #
# -------------------------- #
$Columns = ($Columns -join ', ')
$ColumnsDefinition = ($ColumnsDefinition -join ', ')

# ---------------------- #
# Import des données CSV #
# ---------------------- #
# On ne prends que les valeurs, en écartant la 1ère ligne (entêtes de colonnes) #
$CSVDataRows = Get-Content $CSVFile -Encoding $ReadingFileEncoding | Select-Object -Skip 1

# -------------------- #
# Génération du script #
# -------------------- #
$CSVDataRows = $CSVDataRows.Trim()
# Initialize the output content with a multi-line string
$OutputContent = @"
/*******************************************************************************************
    Fichier source : $FileName
    Généré par : $ENV:UserName
    Date création : $(Get-Date)
*******************************************************************************************/
USE $DatabaseName;
GO

/* Création de la table */
DROP TABLE IF EXISTS $SQLTableName;
CREATE TABLE $SQLTableName ($ColumnsDefinition);
GO

/* Vérifications */
-- SELECT * FROM $SQLTableName;
-- SELECT COUNT(*) AS Nb_Rows FROM $SQLTableName;

/* Ajout des données */
BEGIN TRANSACTION;

SET NOCOUNT ON;


"@

# Désactivation du comptage de lignes #
foreach ($LineValue in $CSVDataRows) {
	# Nettoyage single quotes #
	$LineValue = $LineValue.Replace("'", "''")
	# Formatage SQL des valeurs #
	$SQLLine = "'" + $LineValue.Replace(";", "', '") + "'"
	# Syntaxe SQL finale #
	$SQLScript = "INSERT INTO $SQLTableName ($Columns) VALUES ($SQLLine);`r`n"
	$OutputContent += "$SQLScript"
}

# Finalize transaction
$OutputContent += @"

COMMIT TRANSACTION;
"@

# ------------------------- #
# Création du fichier final #
# ------------------------- #
Out-File -InputObject $OutputContent -Encoding $OutputFileEncoding -FilePath $FullOutputPath
Write-Host " - Script SQL enregistré à : $FullOutputPath"

