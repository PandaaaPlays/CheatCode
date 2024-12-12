param (
    [Parameter(mandatory=$true)]
    [string]$SourceDirectory,
	[Parameter(mandatory=$true)]
    [string]$OutputDirectory,
    [Parameter(mandatory=$true)]
    [string]$OutputFileName,
	[Parameter(mandatory=$true)]
    [string]$SearchPattern
)

# --------------------------------------------------- #
# Merge de tous les sous-fichiers SQL d'un répertoire #
#         ( Récursif dans les sous-dossiers )         #
# --------------------------------------------------- #

# Global informations
$ReadingFileEncoding = "Default"
$OutputFileEncoding = "utf8" 		# UTF-8 with BOM par défaut (Windows PowerShell)

# ----------------------- #
# Test du script de merge #
# ----------------------- #
# Répertoire source contenant les fichiers à fusionner
<#$path = Split-Path $script:MyInvocation.MyCommand.Path
$SourceDirectory = "$path\test_merge"
$OutputDirectory = "$path"
$OutputFileName = "merge_all_test"
$SearchPattern = @('*.sql', '*.gdl', '*.upd')
Write-Host "Source Dir Path: $SourceDirectory"#>

# Type de fichiers ciblés 
$SearchPatternList = $SearchPattern -split ',' | ForEach-Object { $_.Trim() }

$FullOutputPath = $OutputDirectory + "\" + $OutputFileName + ".sql"
# Write-Host "Full Output Path: $FullOutputPath"

# ---------- #
# Préalables #
# ---------- #
# On supprime le fichier de merge s'il existe déjà #
if (Test-Path $FullOutputPath) {
	Remove-Item -Path $FullOutputPath
}

#------------------------#
# Préparation du résulat #
#------------------------#
# Ajout du répertoire principal dans la liste des dossiers à explorer #
$FolderList = @($SourceDirectory)

# Liste des sous-dossiers dans le répertoire #
$FolderList += @(Get-ChildItem -Path $SourceDirectory -Recurse -Directory | ForEach-Object{Write-Output ($_.FullName)})
#Write-Host "Folder List : $FolderList"

#------------------------------#
# Création du contenu du merge #
#------------------------------#
$OutputContent = @"
/*************$("*" * $SourceDirectory.Length)
`tSQL Merge : $(Get-Date)
--------------$("-" * $SourceDirectory.Length)
`tSource : $SourceDirectory
`tSearched file types : $SearchPattern
--------------$("-" * $SourceDirectory.Length)

`t------------------
`t:: Merged files ::
`t------------------
$(
	# Liste des répertoires et de leurs contenus, par niveau
	ForEach-Object -InputObject $FolderList {
		foreach ($Folder in $FolderList) {
			$FileList = Get-ChildItem -Path ($Folder + "\*") -include $SearchPatternList

			$FileCount = $FileList.Count

			# Répertoire principal #
			if ($Folder -eq $SourceDirectory) {
				$Folder_Indent_Level = "`t.\"
				$File_Indent_Level = "`t|`t|- "
			} 
			# Sous-répertoires #
			else {
				$Folder_Indent_Level = "`t|`t+ \"
				$File_Indent_Level = "`t|`t|`t|- "
			}

			# Écriture de l'arborescence #
			Write-Output $($Folder_Indent_Level + (Split-Path $Folder -Leaf) + " ($FileCount files)")`r`n
			foreach ($File in $FileList) {
				Write-Output $($File_Indent_Level + $File.Name)`r`n
			}

		}
	}
)
*************$("*"*$SourceDirectory.Length)/

$(
	ForEach-Object -InputObject $FolderList {
		foreach ($Folder in $FolderList) {
			$FileList = Get-ChildItem -Path ($Folder + "\*") -Include $SearchPatternList
				foreach ($File in $FileList) {

					# Nom du fichier (pour affichage) #
					if ($Folder -eq $SourceDirectory) {
						$ScriptName = ".\$($File.Name)"
					} 
					else {
						$ScriptName = ".\$(Split-Path $Folder -Leaf)\$($File.Name)"
					}

					# Écriture du contenu du script
					Write-Output `r`n"-- -----------------$("-"*$ScriptName.Length) --"
					Write-Output `r`n"/* DÉBUT - Script : $ScriptName */"
					Write-Output `r`n"-- -----------------$("-"*$ScriptName.Length) --"
					Write-Output `r`n
					Write-Output `r`n"$(Get-Content $File -Encoding $ReadingFileEncoding -Raw)"
					Write-Output `r`n
					Write-Output `r`n"/* FIN - Script : $ScriptName */"
					Write-Output `r`n
					Write-Output `r`n
				}
		}
	}
)

$(
	Write-Output `r`n"/***************************************************************************"
	Write-Output `r`n"-- FIN de Merge --"
	Write-Output `r`n"**************************************************************************/"
	Write-Output `r`n"COMMIT;"
	Write-Output `r`n
)
"@

#-------------------------------#
# Nettoyage du contenu du merge #
#-------------------------------#
# Extras space produits par l'ajout des caractères spéciaux lors de la contruction du contenu #
# espace + CRLF --> CRLF #
$OutputContent = $OutputContent -replace " `r`n", "`r`n"

# espace + TAB --> TAB #
$OutputContent = $OutputContent -replace " `t", "`t"

# ----------------------- #
# Création du merge final #
# ----------------------- #
Out-File -InputObject $OutputContent -Encoding $OutputFileEncoding -FilePath $FullOutputPath
Write-Host " - Fichiers SQL fusionné à : $FullOutputPath"

