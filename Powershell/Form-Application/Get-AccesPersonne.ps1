param (
    [Parameter(mandatory=$true)]
    [string]$json
)

$path = Split-Path $script:MyInvocation.MyCommand.Path
[void][system.reflection.Assembly]::LoadFrom("$path/lib/MySql.Data.dll");

function Start-SSHConnection {
    param($sshUser, $sshServer, $sshPort, $sshPassword, $server, $port)
    
    Write-Host "Tentative de connexion au serveur SSH via PuTTY : ${sshPort}:${server}:${port}"
    $puttyProcess = Start-Process -FilePath "$path/lib/putty.exe" `
    -ArgumentList "-ssh $sshUser@$sshServer -pw $sshPassword -L ${sshPort}:${server}:${port}" `
    -WindowStyle Hidden `
    -PassThru
    
    return $puttyProcess
}

function Stop-SSHConnection {
    param($puttyProcess, $sshPort, $server, $port)
    
    if ($null -ne $puttyProcess) {
        Stop-Process -Id $puttyProcess.Id -Force
        Write-Host "Fermeture de la connexion SSH : ${sshPort}:${server}:${port}"
    }
}

function Connect-MySQL {
    param($connectionString, $server, $port)
    
    Write-Host "Tentative de connexion à la base de données : ${server}:${port} ..."
    try {
        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
        $connection.Open()
        Write-Host "La connexion MySQL a été établie."
        return $connection
    } catch {
        Write-Warning $_.Exception.GetType().FullName
        throw "Impossible d'établir la connexion MySQL. Vérifiez votre mot de passe."
    }
}

function Disconnect-MySQL {
    param($connection, $server, $port)
    
    $connection.Close()
    Write-Host "Fermeture de la connexion MySQL : ${server}:${port}" 
}

function Execute-SQLQuery {
    param($sqlFile, $connection)

    Write-Host "Vérification des accès dans la base de données."

    $sqlQuery = Get-Content -Path "$path/sql/CALL_ps_gestion_systeme_liste_acces_cip.sql" -Raw
    $sqlQuery = $sqlQuery -replace "cipPersonne", "$cipPersonne"
    $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand($sqlQuery, $connection)
    $reader = $cmd.ExecuteReader()
    
    $results = @()
    while ($reader.Read()) {
        $row = @{}
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $row[$reader.GetName($i)] = $reader.GetValue($i)
        }
        $results += New-Object PSObject -Property $row
    }
    
    $reader.Close()
    return $results
}

function Get-DatabaseCredentials {
    param($globalCredentials, $databaseConnection)

    $user = $databaseConnection.user
    $password = $databaseConnection.password
    if ($null -eq $user) {
        $user = $globalCredentials.user
    }
    if ($null -eq $password) {
        $password = $globalCredentials.password
    }

    if ($null -eq $user -and $null -eq $password) {
        Write-Warning "Connexion impossible, les informations de connexion à la base de donnée sont manquant."
        return $null
    }
    return $user, $password
}

function Get-SSHCredentials {
    param($globalCredentials, $databaseConnection)

    $sshUser = $databaseConnection.sshUser
    $sshPassword = $databaseConnection.sshPassword
    if ($null -eq $sshUser) {
        $sshUser = $globalCredentials.sshUser
    }
    if ($null -eq $sshPassword) {
        $sshPassword = $globalCredentials.sshPassword
    }

    if ($null -eq $sshUser -or $null -eq $sshPassword) {
        Write-Warning "Connexion SSH impossible, les informations de connexion ou le port sont manquant."
        return $null
    }
    return $sshUser, $sshPassword
}

$jsonObject = $json | ConvertFrom-Json
$databaseConnections = $jsonObject.databaseConnections

$results = @()
# Logique globale pour toutes les connexions aux bases de données
foreach ($databaseConnection in $databaseConnections) {
    # Vérification que le serveur et port sont présents.
    $server = $databaseConnection.server
    $port = $databaseConnection.port
    $name = $databaseConnection.name
    Write-Host "`n[$name]"

    if ($null -eq $server -or $null -eq $port) {
        Write-Warning "Connexion invalide, le serveur et le port doivent être indiqués."
        continue
    } 

    $user, $password = Get-DatabaseCredentials -globalCredentials $globalCredentials -databaseConnection $databaseConnection
    if ($null -eq $user -or $null -eq $password) { continue } 

    # Vérification si le serveur SSH est présent pour cette connexion. 
    $sshServer = $databaseConnection.sshServer
    $sshPort = $databaseConnection.sshPort
    $puttyProcess = $null
    if ($null -ne $sshServer) {
        if ($null -eq $sshPort) {
            Write-Warning "Connexion invalide, le serveur et le port doivent être indiqués."
            continue
        }

        $sshUser, $sshPassword = Get-SSHCredentials -globalCredentials $globalCredentials -databaseConnection $databaseConnection
        if ($null -eq $sshUser -or $null -eq $sshPassword) { continue } 
    
        # Connexion au serveur SSH dans le cas échéant.
        $puttyProcess = Start-SSHConnection -sshUser $sshUser -sshServer $sshServer -sshPort $sshPort -sshPassword $sshPassword -server $server -port $port
        $connectionString = "server=localhost;port=$sshPort;user=$user;password=$password;SslMode=None;"
    } else {
        $connectionString = "server=$server;port=$port;user=$user;password=$password;SslMode=None;"
    }

    $connection = Connect-MySQL -connectionString $connectionString -server $server -port $port
    if ($null -eq $connection) { continue } 
    
    $results += [PSCustomObject]@{ 
        Serveur = $name
        Result = Execute-SQLQuery -connection $connection
    }

    Disconnect-MySQL -connection $connection -server $server -port $port
    Stop-SSHConnection -puttyProcess $puttyProcess -sshPort $sshPort -server $server -port $port
}

return $results