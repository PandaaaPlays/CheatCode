function Get-Password {
[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $true,
    Position = 0)]
    $Id,
    [Parameter(Mandatory = $true,
    Position = 1)]
    $APIKey
)
    $objrequest = Invoke-RestMethod -Method Get -Uri "https://secret.usherbrooke.ca/api/passwords/$Id" -Header @{"APIKey"="$APIKey"};
    return $objrequest
}
