param (
    [Parameter(mandatory=$true)]
    [string]$inputFile,
    [Parameter(mandatory=$false)]
    [switch]$inLine
)

$keywords = @(
    "A", "ACCESSIBLE", "ADD", "ALL", "ALTER", "ANALYZE", "AND", "AS", "ASC", "ASENSITIVE", "BEFORE", "BETWEEN", "BIGINT", "BINARY", "BLOB", "BOTH", "BY", 
    "CALL", "CASCADE", "CASE", "CHANGE", "CHAR", "CHARACTER", "CHECK", "COLLATE", "COLUMN", "CONDITION", "CONSTRAINT", "CONTINUE", "CONVERT", "CREATE", 
    "CROSS", "CURRENT_DATE", "CURRENT_ROLE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "CURRENT_USER", "CURSOR", "DATABASE", "DATABASES", "DAY_HOUR", 
    "DAY_MICROSECOND", "DAY_MINUTE", "DAY_SECOND", "DEC", "DECIMAL", "DECLARE", "DEFAULT", "DELAYED", "DELETE", "DELETE_DOMAIN_ID", "DESC", "DESCRIBE", 
    "DETERMINISTIC", "DISTINCT", "DISTINCTROW", "DIV", "DO_DOMAIN_IDS", "DOUBLE", "DROP", "DUAL", "EACH", "ELSE", "ELSEIF", "ENCLOSED", "ESCAPED", "EXCEPT", 
    "EXISTS", "EXIT", "EXPLAIN", "FALSE", "FETCH", "FLOAT", "FLOAT4", "FLOAT8", "FOR", "FORCE", "FOREIGN", "FROM", "FULLTEXT", "GENERAL", "GRANT", "GROUP", 
    "HAVING", "HIGH_PRIORITY", "HOUR_MICROSECOND", "HOUR_MINUTE", "HOUR_SECOND", "IF", "IGNORE", "IGNORE_DOMAIN_IDS", "IGNORE_SERVER_IDS", "IN", "INDEX", 
    "INFILE", "INNER", "INOUT", "INSENSITIVE", "INSERT", "INT", "INT1", "INT2", "INT3", "INT4", "INT8", "INTEGER", "INTERSEC", "INTERVAL", "INTO", "IS", 
    "ITERATE", "JOIN", "KEY", "KEYS", "KILL", "LEADING", "LEAVE", "LEFT", "LIKE", "LIMIT", "LINEAR", "LINES", "LOAD", "LOCALTIME", "LOCALTIMESTAMP", "LOCK", 
    "LONG", "LONGBLOB", "LONGTEXT", "LOOP", "LOW_PRIORITY", "MASTER_HEARTBEAT_PERIOD", "MASTER_SSL_VERIFY_SERVER_CERT", "MATCH", "MAXVALUE", "MEDIUMBLOB", 
    "MEDIUMINT", "MEDIUMTEXT", "MIDDLEINT", "MINUTE_MICROSECOND", "MINUTE_SECOND", "MOD", "MODIFIES", "NATURAL", "NOT", "NO_WRITE_TO_BINLOG", "NULL", 
    "NUMERIC", "OFFSE", "ON", "OPTIMIZE", "OPTION", "OPTIONALLY", "OR", "ORDER", "OUT", "OUTER", "OUTFILE", "OVER", "PAGE_CHECKSUM", "PARSE_VCOL_EXPR", 
    "PARTITION", "PRECISION", "PRIMARY", "PROCEDURE", "PURGE", "RANGE", "READ", "READS", "READ_WRITE", "REAL", "RECURSIVE", "REF_SYSTEM_ID", "REFERENCES", 
    "REGEXP", "RELEASE", "RENAME", "REPEAT", "REPLACE", "REQUIRE", "RESIGNAL", "RESTRICT", "RETURN", "RETURNING", "REVOKE", "RIGHT", "RLIKE", "ROW_NUMBE", 
    "ROWS", "SCHEMA", "SCHEMAS", "SECOND_MICROSECOND", "SELECT", "SENSITIVE", "SEPARATOR", "SET", "SHOW", "SIGNAL", "SLOW", "SMALLINT", "SPATIAL", "SPECIFIC", 
    "SQL", "SQLEXCEPTION", "SQLSTATE", "SQLWARNING", "SQL_BIG_RESULT", "SQL_CALC_FOUND_ROWS", "SQL_SMALL_RESULT", "SSL", "STARTING", "STATS_AUTO_RECALC", 
    "STATS_PERSISTENT", "STATS_SAMPLE_PAGES", "STRAIGHT_JOIN", "TABLE", "TERMINATED", "THEN", "TINYBLOB", "TINYINT", "TINYTEXT", "TO", "TRAILING", "TRIGGER", 
    "TRUE", "UNDO", "UNION", "UNIQUE", "UNLOCK", "UNSIGNED", "UPDATE", "USAGE", "USE", "USING", "UTC_DATE", "UTC_TIME", "UTC_TIMESTAMP", "VALUES", 
    "VARBINARY", "VARCHAR", "VARCHARACTER", "VARYING", "WHEN", "WHERE", "WHILE", "WINDOW", "WITH", "WRITE", "XOR", "YEAR_MONTH", "ZEROFILL", "VIEW", 
    "SEQUENCE", "TRUNCATE", "ALGORITHM", "DEFINER", "SQL_SECURITY", "DATE", "TIME", "DATETIME", "TIMESTAMP", "YEAR", "ENUM", "SET", "BEGIN", "END", "COUNT", "NOW", 
    "IFNULL", "CONCAT", "COALESCE", "DELIMITER", "AFTER", "ROW", "GREATEST", "DO", "MD5", "CAST", "CONV", "CONCAT_WS", "CURDATE", "MAX", "LOWER", "EXECUTE",
    "DEALLOCATE", "PREPARE", "TIME_FORMAT", "ISNULL", "MIN", "STR_TO_DATE", "cd DATE_FORMAT", "SUM") 

    function Check-Error {
        param ([string]$line)
    
        if($line -notmatch 'INSERT INTO') {
            $words = $line -split '\s+'
        }

        foreach ($word in $words) {
            if ($word -match "([\w]+)\(") {
                $wordWithoutParenthesis = $matches[1]
                if($keywords -notcontains $wordWithoutParenthesis) {
                    return "-- Erreur: '$wordWithoutParenthesis(' n'est pas connu.`n"
                }
            }
        }
    }
    

function Refactor-SQL {
    param ([string]$sql)
    # Changement des keyword spécifique à MariaDB en majuscule. 
    $sqlWithoutComments = $sql -replace "--.*?(\r?\n|$)", "`n" # Remove single-line comments
    $sqlWithoutComments = $sqlWithoutComments -replace "/\*[\s\S]*?\*/", "" # Remove multi-line comments

    $sql = $sqlWithoutComments

    foreach ($keyword in $keywords) {
        $keywordPattern = "(?i)\b$keyword\b" 
        $sql = $sql -replace $keywordPattern, $keyword.ToUpper()
    }

    # Tout mettre sur une ligne au départ.
    $sql = $sql -replace "\r\n", " "
    $sql = $sql -replace "\s+", " "
    $sql = $sql -replace "\s*\(\s*", "(" -replace "AS\(", "AS (" -replace "=\(", "= ("
    $sql = $sql -replace "\s*\)", ")"

    # Join -> Inner Join
    $sql = $sql -replace "(?<!INNER|LEFT|RIGHT|CROSS)\sJOIN\b", " INNER JOIN"

    # Ajout des Alias (AS) dans le WITH.
    $sql = $sql -replace "(WITH\s\S+)\(", "`$1 AS ("
    # Ajout des Alias (AS) dans le JOIN.
    $sql = $sql -replace "(JOIN\s+\S+\s+)(?!AS\b|ON|WHERE)(\S+)", "`$1AS `$2"

    return $sql
}

function Reformat-SQL {
    param ([string]$sql)

    $keywordsToReturnLine = @("CREATE", "WITH", "FROM", "INNER JOIN", "LEFT JOIN", "RIGHT JOIN", "CROSS JOIN", "ON", "AND", "ELSE", "END", "GROUP BY", "WHERE", 
    "UNION ALL", "DELIMITER", "AFTER", "BEGIN", "DELETE", "SET", "CALL", "ELSEIF", "DECLARE", "DROP", "DETERMINISTIC", "NO SQL", "RETURN", "WHILE", "THEN", "WHEN", 
    "STARTS", "EXECUTE", "DEALLOCATE", "PREPARE", "ORDER BY", "OPEN", "LOOP", "FETCH", "VALUES")

    foreach ($keyword in $keywordsToReturnLine) {
        $sql = $sql -replace "\b$keyword\b", "`n$keyword"
    }
    $sql = $sql -replace ";", "`n;"
    $sql = $sql -replace "; SELECT\b", ";`nSELECT" -replace "\bFOR SELECT\b", "FOR`nSELECT" -replace "\bAS SELECT\b", "AS`nSELECT"
    $sql = $sql -replace "(?<!AFTER )\bINSERT\b", "`nINSERT"
    $sql = $sql -replace "(?<!AFTER )\bUPDATE\b", "`nUPDATE"
    $sql = $sql -replace "(?<!END )\bIF\b(?! EXISTS)", "`nIF"
    $sql = $sql -replace ",(?!\s)", ", " 
    if (-not $inLine) {
        $sql = $sql -replace ",", "`n,"
    } else {
        $sql = $sql -replace "\s+,", ","
    }
    if (-not $inLine) {
        $sql = $sql -replace "(?<!\()\)", "`n)"
    } else {
        $sql = $sql -replace "(?<!\()\),\s", ")`n,   "
    }
    if (-not $inLine) {
        $sql = $sql -replace "\(", "(`n"
    }
    $sql = $sql -replace "(INSERT INTO\s+\S+)(\()", '$1 $2'
    $sql = $sql -replace "VALUES\(", 'VALUES ('
    $sql = $sql -replace "(VIEW\s+.+?\s)AS", "`$1`nAS"
    $sql = $sql -replace "= CASE", "= `nCASE"

    $lines = $sql -split "`n" | ForEach-Object { $_.Trim() }

    $niveau = 0
    $joinFlag = 0
    $selectFlag = 0 
    $caseFlag = 0
    $insertFlag = 0
    $beginFlag = 0
    $ifFlag = 0
    $valuesFlag = 0
    $formattedSQL = ""

    foreach ($line in $lines) {
        # Détection des )
        if ($line -match "(?<!\()\)" -and $line -notmatch "\(+(?!\))") {
            if($niveau -eq 0) {
                $formattedSQL += "-- La ligne suivante a un comportement inattendu : `n"
            } else {
                $niveau -= 1
            }
            $insertFlag = 0
        }

        $formattedSQL += Check-Error -line $line

        # Détection du ; de la fin
        if ($line -match "^;\s*$") {
            $formattedSQL += $line
            continue
        }
        
        # Détection du AS de l'entête
        if ($line -eq "AS") {
            $formattedSQL += "`t" * ($niveau) + $line + "`n"
            $niveau += 1

        # Détection des BEGIN
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
        } elseif ($line -match "\bIF\b.*\bTHEN\b" -or $line -match "\) THEN") {
            $formattedSQL += "`t" * ($niveau + $beginFlag) + $line + "`n"
            $ifFlag = 1
        # Fin du IF
        } elseif ($ifFlag -eq 1 -and ($line -match "\bEND IF\b" -or $line -match "ELSEIF\(")) {
            $formattedSQL += "`t" * ($niveau + $beginFlag) + $line + "`n"
            $ifFlag = 0
        # Détection des VALUES
        } elseif ($line -match "\bVALUES\b") {

            $insertSpace = ""
            if ($insertFlag -ne 0) {
                if ($line -match "," -and -not $inline) {
                    $insertSpace = "  "
                } else {
                    $insertSpace = "`t"
                }
            }

            $formattedSQL += " " * ($niveau + $beginFlag - $insertFlag) + $insertSpace + $line + "`n"
            $valuesFlag = 1
        # Détection des JOIN/WHERE
        } elseif ($line -match "\bJOIN\b" -or $line -match "\bWHERE\b") {
            $formattedSQL += "`t" * ($niveau + $ifFlag + $beginFlag) + $line + "`n"
            $joinFlag = 1
        # Fin du JOIN/WHERE
        } elseif ($joinFlag -eq 1 -and ($line -match "\bJOIN\b" -or $line -match "\bORDER BY\b" -or $line -match "\bUNION\b" -or $line -match "\bWHERE\b" -or $line -match "\bGROUP BY\b" -or $line -match ";")) {
            $formattedSQL += "`t" * ($niveau + $beginFlag) + $line + "`n"
            $joinFlag = 0
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
            if ($words.Count -gt 1 -and ($words[0] -eq "END" -and $words[-1] -notmatch "\(")) { 
                if ($words[-2] -ne "AS" -and $words[-2] -ne "=") {
                    $words[-2] += " AS"
                }
            }
            $line = $words -join ' '
            $formattedSQL += "`t" * ($niveau + $selectFlag) + "   " + $line + "`n"
            $caseFlag = 0
        # Détection des SELECT
        } elseif ($line -match "\bSELECT\b") {
            $words = $line -split "\s+"
            if ($words.Count -gt 2) {
                if ($words[-2] -ne "AS" -and $words[-2] -ne "DISTINCT" -and $words[-1] -notmatch "\(") {
                    $words[-2] += " AS"
                }
            }
            $line = $words -join ' '
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag) + ($selectSpace * $selectFlag) + $line + "`n"
            $selectFlag += 1
        # Fin du SELECT (FROM)
        } elseif ($selectFlag -gt 0 -and $line -match "\bFROM\b") {
            $selectFlag -= 1
            $words = $line -split "\s+"
            if ($words.Count -gt 2) {
                if ($words[-2] -ne "AS" -and $words[-2] -ne "INNER" -and $words[-2] -ne "WHERE" -and $words[-2] -ne "LEFT" -and $words[-2] -ne "RIGHT" -and $words[-2] -ne "CROSS") {
                    $words[-2] += " AS"
                }
            }
            $line = $words -join ' '
            $formattedSQL += "`t" * ($niveau + $selectFlag + $ifFlag + $beginFlag) + ($selectSpace * $selectFlag) + $line + "`n"

        } else {
            $selectSpace = ""
            if ($selectFlag -ne 0) {
                $selectSpace = " "
            }

            $valuesSpace = ""
            if ($valuesFlag -ne 0) {
                $valuesSpace = " "
            }

            $insertSpace = ""
            if ($insertFlag -ne 0) {
                if ($line -match "," -and -not $inline) {
                    $insertSpace = "  "
                } else {
                    $insertSpace = "`t"
                }
            }

            $words = $line -split "\s+"
            if ($words.Count -gt 2 -and ($words[0] -eq "," -and $words[-1] -notmatch "\(" -and $words[-2] -notmatch "INTO" -and $words[-2] -notmatch "'")) { 
                if ($words[-2] -ne "AS" -and $words[-2] -ne "=") {
                    $words[-2] += " AS"
                }
            }
            if ($words[0] -eq ")" -and $line -ne ")" -and $line -notmatch "\(") {
                if ($words[-2] -ne "AS" -and $words[-2] -notmatch "=" -and $words[-2] -ne "<" -and $words[-2] -ne ">" -and $words[-1] -ne "THEN" -and 
                    $words[-1] -ne "DO" -and $words[-2] -ne "COLLATE" -and $words[-1] -ne ";" -and $words[-1] -ne "^" -and $words[-1] -ne "NULL") {
                    $words[-2] += " AS"
                }
            }
            $line = $words -join ' '
            #$formattedSQL += "$niveau : $joinFlag : $selectFlag : $caseFlag : $ifFlag : $insertFlag : $beginFlag "
            $formattedSQL += "`t" * ($niveau + $joinFlag + $selectFlag + $caseFlag + $ifFlag - $insertFlag + $beginFlag) 
            #$formattedSQL += "$insertSpace : $selectSpace"
            $formattedSQL += $insertSpace + $selectSpace + $valuesSpace + $line + "`n"
        }

        # Détection des (
        if ($line -match "\(+(?!\))") {
            $niveau += 1
        }
    }

    return $formattedSQL
}   

if(-not ($inputFile -like "*.sql")) {
    Write-Warning "(!) Le fichier $inputFile n'est pas un fichier .sql valide."
    return
}
    
# Nécessaire pour conserver les accents.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$sqlScript = Get-Content $inputFile -Raw

$formattedSQL = Refactor-SQL -sql $sqlScript
$formattedSQL = Reformat-SQL -sql $formattedSQL

return $formattedSQL