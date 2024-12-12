# Légende : 
# - "A" -> "B" veut dire que "A" sera remplacé en "B"

# Trucs de déboggage :
# - Il est parfois très dur de déterminer quel "regex" créer une erreur car plusieurs parties de ce code en génèrent. Il est facile de trouver rapidement lequel
#   fait une erreur en changeant la valeur de ceux-ci en ajoutant des numéros à la fin par exemple.

$path = Split-Path $script:MyInvocation.MyCommand.Path
# Récupération du fichier de listes de keywords SQL
$jsonContent = Get-Content -Path "$path/SQL-Keywords.json" -Raw | ConvertFrom-Json
# Liste des mots-clés SQL génériques (compatibles avec toutes les bases de données SQL)
$sqlGenericKeywords = $jsonContent.sqlGenericKeywords
# Liste des mots-clés spécifiques à MySQL
$mysqlSpecificKeywords = $jsonContent.mysqlSpecificKeywords

# Fonction pour vérifier les erreurs dans une ligne SQL.
function Check-Error {
    param ([string]$line)

    # Vérifie si la ligne n'est pas une requête 'INSERT INTO'
    if ($line -notmatch 'INSERT INTO' -and $line -notmatch "TABLE") {
        # Divise la ligne en mots en utilisant les espaces comme séparateurs.
        $words = $line -split '\s+'
    }

    # Boucle à travers chaque mot détecté.
    foreach ($word in $words) {
        # Identifie les mots avec une parenthèse ouvrante.
        if ($word -match "([\w]+)\(") {
            $wordWithoutParenthesis = $matches[1]
            
            # Vérifie si le mot sans parenthèse n'est pas dans les mots-clés.
            if (($mysqlSpecificKeywords -notcontains $wordWithoutParenthesis) -and 
                ($sqlGenericKeywords -notcontains $wordWithoutParenthesis)) {
                # Retourne un message d'erreur si le mot n'est pas connu.
                return "-- Erreur: '$wordWithoutParenthesis(' n'est pas connu.`n"
            }
        }
    }
}   

# Liste pour contenir les valeurs entres '' et les commentaires.
# Ceux-ci sont stockés au début et remis à la fin (pour ne pas les formatter!)
$escapedStrings = New-Object System.Collections.ArrayList
$escapedComments = New-Object System.Collections.ArrayList

# Remplacement des chaines sensible (commentaires, '') par des placeholders.
function Escape-Strings {
    param ([string]$sql)

    $sql = [regex]::Replace($sql, "(--[^\r\n]*|/\*[\s\S]*?\*/)", { 
        param ($match)  
        $escapedComments.Add("`n" + $match.Value + "`n") | Out-Null  # Sauvegarde du match (entre /* */ ou --)
        "ESCAPED_COMMENT_$($escapedComments.Count - 1)"  # Remplacer avec un placeholder temporaire
    })

    $sql = [regex]::Replace($sql, "(['""])(.*?)(\1)", { 
        param ($match)  
        $escapedStrings.Add($match.Value) | Out-Null  # Sauvegarde du match (entre '' ou "")
        "ESCAPED_QUOTES_$($escapedStrings.Count - 1)"  # Remplacer avec un placeholder temporaire
    })

    return $sql
}

# Mettre l'input sur une seule ligne.
function Refactor-SQL {
    param ([string]$sql)

    # =================================== #
    #  Casse du script (mot-clés en MAJ)  #
    # =================================== #
    foreach ($keyword in $sqlGenericKeywords) {
        $keywordPattern = "(?i)\b$keyword\b" # Remplacement des keywords détectés (insensible à la case) par leur version en majuscule.
        $sql = $sql -replace $keywordPattern, $keyword.ToUpper()
    }

    # ====================================== #
    #  Mettre le script sur une seule ligne  #
    # ====================================== #
    $sql = $sql -replace "\r\n", " "        # Linebreak (retour de ligne) -> Espace
    $sql = $sql -replace "\s+", " "         # Plusieurs espaces -> Un seul espace
    # ( (avec des espaces) -> (
    # AS( -> AS (
    # IF( -> IF (
    # IN( -> IN (
    # AND( -> AND (
    # =( -> = (
    # = (avec des espaces) -> ' = ' (trim pour 1 espaces avant et après)
    # := (avec des espaces) -> ' := ' (trim pour 1 espaces avant et après)
    # , (avec des espaces) -> , 
    $sql = $sql -replace "\s*\(\s*", "(" `
                -replace "AS\(", "AS (" `
                -replace "IF\(", "IF (" `
                -replace "IN\(", "IN (" `
                -replace "AND\(", "AND (" `
                -replace "=\(", "= (" `
                -replace "\s*=\s*", " = " `
                -replace "\s*:=\s*", " := " `
                -replace "\s*,\s*", "," 
    $sql = $sql -replace "\s*\)", ")"       # ) avec des espaces avant -> )

    # ===================================== #
    #  Corrections des mots-clés du script  #
    # ===================================== #
    # Remplacement des JOIN sans type pour des INNER JOIN
    $sql = $sql -replace "(?<!INNER|LEFT|RIGHT|CROSS)\sJOIN\b", " INNER JOIN"

    return $sql
}

# Split du scripts sur plusieurs lignes (sans les parenthèses de splitté)
function Split-SQL {
    param ([string]$sql)

    # Liste des mots-clés SQL génériques (compatibles avec toutes les bases de données SQL)
    $sqlGenericKeywordsToReturnLine = $jsonContent.sqlGenericKeywordsToReturnLine
    # Liste des mots-clés spécifiques à MySQL
    $mysqlKeywordsToReturnLine = $jsonContent.mysqlKeywordsToReturnLine

    # ====================================================== #
    #      Gestion des retours de lignes dans le script      #
    #  (Ici, aucun espace n'est inséré au début des lignes)  #
    # ====================================================== #
    foreach ($keyword in $sqlGenericKeywordsToReturnLine) {
        $sql = $sql -replace "\b$keyword\b", "`n$keyword"
    }
    foreach ($keyword in $mysqlKeywordsToReturnLine) {
        $sql = $sql -replace "\b$keyword\b", "`n$keyword"
    }

    # Retour de ligne avant les SELECT précédés d'un ';'
    # Retour de ligne entre les FOR et SELECT
    # Retour de ligne entre les AS et SELECT
    # Retour de ligne entre les ) et SELECT
    # Retour de ligne entre les "UNION" et les SELECT
    # Retour de ligne après = ( suivi d'un SELECT
    $sql = $sql -replace ";\s+SELECT\b", ";`n`nSELECT" `
                -replace "\bFOR SELECT\b", "FOR`nSELECT" `
                -replace "\bAS SELECT\b", "AS`nSELECT" `
                -replace "\b\) SELECT\b", ")`nSELECT" `
                -replace "(UNION\s*\S*)\sSELECT\b", "`$1`nSELECT" `
                -replace "= \(SELECT", "= (`nSELECT"
    # Retour de ligne avant les INSERT précédés d'un ';'
    $sql = $sql -replace "; INSERT\b", "; `nINSERT"

    # Retour de ligne avant les UPDATE qui ne sont pas précédé de "AFTER"
    $sql = $sql -replace "(?<!AFTER )\bUPDATE\b", "`nUPDATE"
    # Retour de ligne avant les IF qui ne sont pas après des END ni avant des EXISTS
    $sql = $sql -replace "(?<!END |,)\bIF\b(?! EXISTS)", "`nIF"
    # Retour de ligne entre les VIEW et AS
    $sql = $sql -replace "(VIEW\s+.+?\s)AS", "`$1`nAS"
    # Retour de ligne entre = et CASE.
    $sql = $sql -replace "= CASE", "= `nCASE"
    # Retirer espace inutile au début de la ligne.
    $sql = $sql -replace "^\s*", ""
    # Retour de ligne avant les INTO non précédés d'un 'INSERT'
    $sql = $sql -replace "(?<!\bINSERT\s+)INTO", "`nINTO"

    # Ajout de retour de ligne avant et après les ESPCAPED_COMMENTS
    $sql = $sql -replace "(ESCAPED_COMMENT_[0-9]*)\s*(\S+)", "`$1`n`$2"
    $sql = $sql -replace "(\S+\s+)(ESCAPED_COMMENT_[0-9]*)", "`$1`n`$2"

    # Ajout de retour de ligne avant et après les UNION et UNION ALL
    $sql = $sql -replace "\bUNION ALL\b", "`nUNION ALL`n"
    $sql = $sql -replace "\bUNION\b(?!\s+ALL)", "`nUNION`n"

    return $sql
}

# Process le format du script SQL (gestion des comportements spécifique sans indentation)
function Reformat-SQL {
    param ([string]$sql)

    # Split du script pour le process ligne par ligne
    $lines = $sql -split "`n"
    $processedLines = @()

    $keywordsToSkip = @("DECLARE", "SET", "IF", "ELSEIF", "AND", "DECIMAL", "\(")
    foreach ($line in $lines) {
        # Ajout d'un espace après les virgules qui n'en ont pas.
        $line = $line -replace ",(?!\s)", ", "
        # Retour de ligne pour les AND qui ne sont pas dans les IF.
        if($line -notmatch "\bIF\b" -and $line -notmatch "\bELSEIF\b") {
            $line = $line -replace "AND", "`nAND"
        }

        # Verification si on ne veut pas formatter la ligne (dans la liste de keywords a skip)
        $skipLine = $false
        foreach ($keyword in $keywordsToSkip) {
            if ($line -match "\b$keyword\b") {
                $processedLines += $line
                $skipLine = $true
                break
            }
        }

        # Skip si on ne veut pas formatter la ligne.
        if ($skipLine) {
            continue
        }

        # Formattage de la ligne actuelle.
        if (-not $inLine) {
            # Remplacement '(word1,' sans ')' avant la fin pour ajouter un retour de ligne avant la ','. 
            # Ceci permet de remplacer les paranthèses qui ont au moins une , dans la formule pour ajouter le retour de ligne.
            $line = $line -replace "\(([\w.:' ]+,(?<!\)))", " (`n `$1"              
            $line = $line -replace "([,=][\w.:' ]+)\)", "`$1`n)"                    # Remplacement ', word1) pour ajouter un retour de ligne avant le ')'
            $line = $line -replace "\(\)\)", "()`n)"                                # ()) -> ()`n) (retour de ligne avant la deuxieme paranthese)
            $line = $line -replace "(TABLE\s\S+)\((\S+)", "`$1(`n`$2"               # TABLE ...(...) -> TABLE ...(`n...   (retour de ligne avant le texte de definition de la table)
            $line = $line -replace "AS\s\(", "AS (`n"                               # Retourner la ligne après les "AS ("
            $line = $line -replace "(\S+)\);", "`$1`n);"                            # Retourner la ligne avant les ); dans (...));
            $line = $line -replace "\(\(", "(`n("                                   # Retourner la ligne entre les ((
            $line = $line -replace "\)\)", ")`n)"                                   # Retourner la ligne entre les ))
            $line = $line -replace "\bSELECT\b\s([\w.:, ]+)\)", "SELECT `$1`n)"     # Retourner la ligne entre les SELECT ...) (avant le ')')
            $line = $line -replace "\bFROM\b\s([\w.:, ]+)\)", "FROM `$1`n)"         # Retourner la ligne entre les FROM ...) (avant le ')')
        } else {
            $line = $line -replace "\), \(", ")`n, (" # Lorsque InLine, on ne fait que retourner entre les ), (
        }

        # Retour de ligne après le ;
        $line = $line -replace "\s*;", ";`n"

        # Retour de ligne avant les , lorsque non InLine
        if (-not $inLine) {
            $line = $line -replace ",", "`n,"
        } else {
            $line = $line -replace "\s+,", ","
        }

        # Remplacements spécifiques
        $line = $line -replace "(INSERT INTO\s+\S+)(\()", '$1 $2'           # Ajout espace entre INSERT INTO et (
        $line = $line -replace "VALUES\(", 'VALUES ('                       # Ajout espace entre VALUES et (
        $line = $line -replace "\bDELIMITER\b(\s*\S*)", "`nDELIMITER`$1`n"  # Retour de ligne avant et apres les DELIMITER
        $line = $line -replace "\bTHEN\b", "THEN`n"                         # Retour de ligne apres le THEN
        $line = $line -replace "\bELSE\b", "ELSE`n"                         # Retour de ligne apres le ELSE
        $line = $line -replace "\bBEGIN\b", "BEGIN`n"                       # Retour de ligne apres le BEGIN

        $processedLines += $line
    }

    # Remettre les lignes ensemble
    return $processedLines -join "`n"
}

# La réindentation du fichier (espaces).
function Reindent-SQL { 
    param ([string]$sql)
    
    # Séparation du script ligne par ligne.
    $lines = $sql -split "`n" | ForEach-Object { $_.Trim() }

    # Déclaration des flags, un flag veut dire qu'on est dans l'instruction.
    # Par exemple, si joinFlag = 1 (true), nous sommes actuellement dans un JOIN.
    $niveau = 0
    
    $joinFlag = 0
    $selectFlag = 0 
    $updateFlag = 0 
    $caseFlag = 0
    $insertFlag = 0
    $beginFlag = 0
    $ifFlag = 0
    $cursorFlag = 0
    $valuesFlag = 0
    $intoFlag = 0
    $withFlag = 0

    $formattedSQL = ""

    # ==================================================================== #
    #  Indentation ligne par ligne intelligente (se souvient du contexte)  #
    # ==================================================================== #
    foreach ($line in $lines) {
        # Détection des )
        if ($line -match "(?<!\()\)" -and $line -notmatch "\(+(?!\))") {
            if($niveau -eq 0) {
                # Gestion des erreurs (parenthèses fermantes sans aucune ouvrante).
                $formattedSQL += "-- La ligne suivante a un comportement inattendu : `n"
            } else {
                $niveau -= 1
            }
        }

        $formattedSQL += Check-Error -line $line
        
        # Explication : 
        #   Selon le contexte, on prend le nombre d'espace avant le début de ligne.
        #   Les flags permettent de se souvenir du contexte actuel.
        #   Le niveau permet de se souvenir des choses imbriquées (SELECT INTO SELECT... par exemple) 

        # Détection du AS de l'entête
        if ($line -eq "AS") {
            $formattedSQL += "`t" * ($niveau) + $line + "`n"
            $niveau += 1

        # Détection des BEGIN / END
        } elseif ($line -match "\bBEGIN\b") {
            $formattedSQL += "`t" * ($niveau) + $line + "`n"
            $beginFlag = 1
        } elseif ($line -match "END;") {
            $formattedSQL += "`t" * ($niveau) + $line + "`n"
            $beginFlag = 0

        # Détection des INSERT
        } elseif ($line -match "\bINSERT INTO\b") {
            $formattedSQL += "`t" * ($niveau + $ifFlag + $beginFlag) + $line + "`n"
            $insertFlag = 1
            
        # Détection des IF
        } elseif ($line -notmatch "\bEND IF\b" -and ($line -match "\bIF\b" -or $line -match "ELSEIF" -or $line -match "ELSE" -or $line -match "\bTHEN\b" -and $line -notmatch "\bEXISTS\b")) {
            $formattedSQL += "`t" * ($niveau + $selectFlag + $beginFlag + $caseFlag) + $line + "`n"
            $ifFlag = 1
        # Fin du IF / ELSEIF(
        } elseif ($ifFlag -eq 1 -and ($line -match "\bEND IF\b")) {
            $formattedSQL += "`t" * ($niveau + $beginFlag) + $line + "`n"
            $ifFlag = 0

        # Détection des VALUES
        } elseif ($line -match "\bVALUES\b") {
            # Ajout d'espaces si on est dans le contexte d'un insert.
            $insertSpace = ""
            if ($insertFlag -ne 0) {
                if ($line -match "," -and -not $inline) {
                    $insertSpace = "  "
                } else {
                    $insertSpace = "`t"
                }
                $insertFlag = 0
            }
            $formattedSQL += " " * ($niveau + $beginFlag - $insertFlag) + $insertSpace + $line + "`n"
            $valuesFlag = 1

        # Détection des JOIN / WHERE
        } elseif ($line -match "\bJOIN\b" -or $line -match "\bWHERE\b") {
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag + $cursorFlag) + ($selectSpace * $selectFlag) + $insertSpace + $line + "`n"
            $joinFlag = 1
            $updateFlag = 0
        # Fin du ORDER/GROUP BY
        } elseif ($joinFlag -eq 1 -and ($line -match "\bORDER BY\b" -or $line -match "\bGROUP BY\b")) {
            $joinFlag = 0
            $formattedSQL += "`t" * ($niveau + $beginFlag + $joinFlag + $cur) + $line + "`n"

        # Détection des CASE WHEN
        } elseif ($line -match "\bCASE\b") {
            $formattedSQL += "`t" * ($niveau + $selectFlag + $joinFlag) + $selectSpace + $line + "`n"
            $caseFlag = 1
        } elseif ($line -match "\bWHEN\b") {
            $formattedSQL += "`t" * ($niveau + $selectFlag + $joinFlag + 1) + $selectSpace + $line + "`n"
            $caseFlag = 2
        # Fin du CASE WHEN
        } elseif ($caseFlag -gt 0 -and ($line -match "\bEND\b")) {
            $words = $line -split "\s+"
            $line = $words -join ' '
            $formattedSQL += "`t" * ($niveau + $selectFlag) + "   " + $line + "`n"
            $caseFlag = 0

        # Détection des CURSOR FOR
        } elseif ($line -match "\bCURSOR FOR\b") {
            $formattedSQL += "`t" * ($niveau + $beginFlag) + $line + "`n"
            $cursorFlag = 1

        # Détection des UPDATE
        } elseif ($line -match "\bUPDATE\b" -and $line -notmatch "\bAFTER\b") {
            $formattedSQL += "`t" * ($niveau + $updateFlag + $beginFlag + $valuesFlag + $ifFlag) + $line + "`n"
            $updateFlag = 1

        # Détection des SET
        } elseif ($line -match "\bSET\b") {
            $formattedSQL += "`t" * ($niveau + $beginFlag + $valuesFlag + $ifFlag) + $line + "`n"
            $updateFlag = 0

        # Détection des UNION
        } elseif ($line -match "\bUNION\b") {
            $formattedSQL += "`t" * ($niveau + $ifFlag + $beginFlag) + $line + "`n"
            if($selectFlag -gt 0) {
                $selectFlag -= 1
            }
            $joinFlag = 0

        # Detection des WITH 
        } elseif ($line -match "\bWITH\b") {
            $withFlag = 1
            $formattedSQL += "`t" * ($niveau + $ifFlag + $beginFlag) + $line + "`n"
        
        # Détection des SELECT
        } elseif ($line -match "\bSELECT\b") {
            $insertSpace = ""
            if ($insertFlag -ne 0) {
                if ($line -match "," -and -not $inline) {
                    $insertSpace = "  "
                } else {
                    $insertSpace = "`t"
                }
            }
            $joinFlag = 0
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag + $cursorFlag) + ($selectSpace * $selectFlag) + $insertSpace + $line + "`n"
            $selectFlag += 1
        # Fin du SELECT (FROM)
        } elseif ($selectFlag -gt 0 -or $intoFlag -gt 0 -and ($line -match "\bFROM\b")) {
            if ($insertFlag -ne 0) {
                $insertFlag = 0
            }
            if($intoFlag -eq 0 -and $selectFlag -gt 0) {
                $selectFlag -= 1
            }
            $intoFlag = 0
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag + $cursorFlag) + ($selectSpace * $selectFlag) + $line + "`n"
        # Fin du SELECT (INTO)
        } elseif ($selectFlag -gt 0 -and $line -match "\bINTO\b") {
            if ($insertFlag -ne 0) {
                $insertFlag = 0
            }
            $intoFlag = 1
            $selectFlag -= 1
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag + $cursorFlag) + ($selectSpace * $selectFlag) + $line + "`n"
        # Fin (tous les ')' seuls) 
        } elseif ($selectFlag -gt 0 -or $joinFlag -gt 0 -and $line -eq ")") {
            if ($insertFlag -ne 0) {
                $insertFlag = 0
            }
            if($selectFlag -gt 0) {
                $selectFlag -= 1
            }
            if($joinFlag -gt 0) {
                $joinFlag = 0
            }
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag + $cursorFlag) + ($selectSpace * $selectFlag) + $line + "`n"
        

        # ======================================================= #
        #  Gestion des lignes gèrées avec un comportement global  #
        # ======================================================= #
        } else {
            # Ajout d'un espace si le contexte est un SELECT
            $selectSpace = ""
            if ($selectFlag -ne 0) {
                $selectSpace = " "
                # Dans le contexte d'un INSERT, l'indention du SELECT est spéciale
                if ($insertFlag -ne 0) {
                    $selectSpace = "`t   "
                }
            }

            # Ajout d'un espace si le contexte est un INTO
            $intoSpace = ""
            if ($intoFlag -ne 0) {
                $intoSpace = "   "
            }

            # Ajout d'un espace si le contexte est un VALUES
            $valuesSpace = ""
            if ($valuesFlag -ne 0) {
                if ($line -match "," -and -not $inline) {
                    $valuesSpace = "  "
                } else {
                    $valuesSpace = "`t"
                }
            }

            # Ajout d'un espace avant les , si le contexte est un INSERT et qu'on est pas inLine
            $insertSpace = ""
            if ($insertFlag -ne 0 -and $line -ne ")") {
                if ($line -match "," -and -not $inline) {
                    $insertSpace = "  "
                } else {
                    $insertSpace = "`t"
                }
            }

            # Ajout d'un espace avant les , si le contexte est un UPDATE et qu'on est pas inLine
            $updateSpace = ""
            if ($updateFlag -ne 0) {
                if ($line -match "," -and -not $inline) {
                    $updateSpace = "   "
                }
            }

            # Espace pour tous les cas non gerés par autre chose spécifiquement
            $adjustingSpace = ""
            $adjustingFlag = 0
            if($selectSpace -eq "" -and $intoSpace -eq "" -and $valuesSpace -eq "" -and $insertFlag -eq "" -and $updateSpace -eq "" -and $withFlag -eq 0) {
                if($line -match "^\s*,") {
                    $adjustingSpace = "  "
                    $adjustingFlag = 1
                }
            }

            if($line -match "\)\s+\bAS\b" -and $selectFlag -gt 0) {
                $line = "  " + $line
            }

            # Reset du JOIN flag
            if($line -eq ";" -or $line -eq ");" -or $line -match "\)\s+AS\s+\S+") {
                $joinFlag = 0
            }

            # Déboggage pour voir quelles lignes ont quelles valeurs de flag et d'espaces. Fonctionne seulement pour celles globales (pas SELECT par exemple)
            #$formattedSQL += "$niveau : $joinFlag : $updateFlag : $selectFlag : $caseFlag : $ifFlag : $insertFlag : $beginFlag : $intoFlag : $adjustingFlag"
            #$formattedSQL += "$insertSpace : $selectSpace : $valuesSpace"

            # Ajout de la ligne avec les bons espaces et flag.
            if($niveau + $joinFlag + $updateFlag + $cursorFlag + $selectFlag + $caseFlag + $ifFlag - $insertFlag + $beginFlag - $adjusting -gt 0) {
                $formattedSQL += "`t" * ($niveau + $joinFlag + $updateFlag + $cursorFlag + $selectFlag + $caseFlag + $ifFlag - $insertFlag + $beginFlag - $adjustingFlag)
            }
            $formattedSQL += $selectSpace + $intoSpace + $insertSpace + $valuesSpace + $updateSpace + $adjustingSpace + $line + "`n"
        }

        # Le ; reset presque tout.
        if ($line -match ";") {
            $niveau = 0
            $joinFlag = 0
            $selectFlag = 0 
            $updateFlag = 0
            $caseFlag = 0
            $insertFlag = 0
            $valuesFlag = 0
            $cursorFlag = 0
            $intoFlag = 0
            $withFlag = 0
        }

        # Détection des (
        if ($line -match "\(+(?!\))" -and $line -notmatch "(?<!\()\)") {
            $niveau += 1
        }
    }


    return $formattedSQL
}   

function Reindent-SemiColon {
    param ([string]$sql)

    $sql = $sql -replace "\s+;", ";"

    # Ligne par ligne
    $lines = $sql -split "`n"
    $processedLines = @()
    foreach ($line in $lines) {
        if ($line -match [regex]::Escape("DECLARE")) {
            $processedLines += $line
            continue
        }

        # Ajout d'un retour de ligne apres les ; si ce n'est pas un DECLARE
        $line = $line -replace ";", ";`n"

        $processedLines += $line
    }

    return $processedLines -join "`n";
}


# Remettre les escaped avec les valeurs initiales.
function Apply-Escaped {
    param ([string]$sql)

    # Va chercher la valeur stocké au départ pour la remettre.
    $formattedSQL = [regex]::Replace($sql, "ESCAPED_QUOTES_(\d+)", { 
        param ($match) 
        $escapedStrings[$match.Groups[1].Value] 
    })

    # Va chercher la valeur stocké au départ pour la remettre.
    $formattedSQL = [regex]::Replace($formattedSQL, "ESCAPED_COMMENT_(\d+)", { 
        param ($match) 
        $escapedComments[$match.Groups[1].Value] 
    })

    return $formattedSQL
}


# ============================================================================================================ #
# L'ajout des alias est très dangereux. Il peut en ajouter à des endroits non souhaités et briser des scripts. #
# ============================================================================================================ #

# Liste des "mots" qui ne devrait pas pouvoir avoir d'alias.
# Par exemple, on ne devrait pas avoir "= AS total"
# Tous les mots (keywords) sont également exclus.
$nonAliasable = @("=", ",", ":", "-", "+", "/", "*", "%", ":=")
function Add-AliasOnWords {
    param ([string[]]$words)

    if($words.Count -ge 2) {
        if($words[-2] -ne "AS" -and ($sqlGenericKeywords -notcontains $words[-2] -and $mysqlSpecificKeywords -notcontains $words[-2] -and $nonAliasable -notcontains $words[-2] -and $words[-2] -notmatch "SELECT")) {
            $words[-2] += " AS"
        }
    }

    return $words;
}

function Add-Aliases {
    param ([string]$sql)

    # Séparation du script ligne par ligne.
    $lines = $sql -split "`n"
    $inAliasableBloc = $false
    $formattedSQL = ""

    # Ligne par ligne... 
    foreach ($line in $lines) {
        # Ces mots veulent dire qu'on est dans un bloc aliasable (tant que c'est des virgules apres)
        if($line -match "\bSELECT\b|\bJOIN\b|\bFROM\b|\bEND\b|\bUPDATE\b|\bDELETE\b") {
            if($line -match ",") {
                $inLine = $true
            }
            $inAliasableBloc = $true
        # Si on ne march pas une virgule ou une parenthese, on reset le aliasable bloc flag.
        } elseif($inAliasableBloc -and $line -notmatch ",|\(|\)") {
            $inAliasableBloc = $false
        }

        # Lorsqu'on est dans un bloc aliasable
        if($inAliasableBloc) {
            $leadingSpace = ""
            if($line -match "^\s*") {
                $leadingSpace = $matches[0]
            }

            # Ajout des alias ligne par ligne.
            if(-not $inLine) {
                $words = $line.Trim() -split "\s+"
                $formattedSQL += $leadingSpace + (Add-AliasOnWords $words -join " ") + "`n"
            # Ajout des alias portion par portion (portions séparées d'une virgule)
            } else {
                $parts = $line.Trim() -split ", "
                $processedParts = @()
                foreach($part in $parts) {
                    $words = $part -split " "
                    $processedParts += (Add-AliasOnWords $words) -join " "
                }
                $formattedSQL += $leadingSpace + ($processedParts -join ", ") + "`n"
            }
        } else {
            $formattedSQL += $line + "`n"
        }
    }

    return $formattedSQL
}

# Retirer les espaces en trop
function Remove-Extra {
    param ([string]$sql)

    $sql = $sql -replace "`n\s*`n\s*`n", "`n`n" 
    $sql = $sql -replace "\(\s*`n\s*`n(\s*)\bSELECT\b", "(`n`$1SELECT" 
    $sql = $sql.TrimEnd()
    return $sql
}