#!/bin/bash
# Le fichier doit être LF (Unix) et non CRLF (Windows)
/opt/mssql/bin/sqlservr &

sleep 10s

# Restorations des fichiers .BAK dans le repertoire backup-files.
echo "Restoration des bases de données..."
for backup_file in /backup-files/*.bak; do
    db_name=$(basename "$backup_file" .bak)
    echo "Restoration de $db_name..."
    /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P $MSSQL_SA_PASSWORD -Q "RESTORE DATABASE [$db_name] FROM DISK = '$backup_file'"
    echo "Base de donnée $db_name restorée."
done

# Exécution des scripts .sql dans le repertoire db-init.
echo "Execution des scripts SQL..."
for sql_file in /db-init/*.sql; do
    echo "Execution de $sql_file..."
    /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U SA -P $MSSQL_SA_PASSWORD -i "$sql_file"
    echo "Script $sql_file executé."
done

wait