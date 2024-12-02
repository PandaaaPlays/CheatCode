
$ErrorActionPreference = "Stop";
#$VerbosePreference = "continue";
$VerbosePreference = "SilentlyContinue";

################################################################################
####   INCLUDE
################################################################################
. "$(Split-Path $script:MyInvocation.MyCommand.Path)\common\LogsUtilities.ps1";
. "$(Split-Path $script:MyInvocation.MyCommand.Path)\common\FileUtilities.ps1";
. "$(Split-Path $script:MyInvocation.MyCommand.Path)\PasswordStateAPI\API.ps1";
###############################################

# Managing Error
trap{
    Write-HostError -ErrorObj $_
    Write-Error "`n - - > For more information, see the previous log`n $($_.Exception)"
    exit 1;
}


$config_path = "$(Split-Path $script:MyInvocation.MyCommand.Path)\PasswordStateAPI\API.conf";

# Load Configuration File into hashtable
$PROPERTIES = Get-Properties -PathFile $config_path;

$key = (Get-Content "$(Split-Path $script:MyInvocation.MyCommand.Path)\common\Utilities.ps1");

$cred_id = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "UNKNOW", ($($PROPERTIES.'001') | ConvertTo-SecureString -Key $key);
$id = $cred_id.GetNetworkCredential().Password
$cred_token = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "UNKNOW", ($($PROPERTIES.'002') | ConvertTo-SecureString -Key $key);
$token = $cred_token.GetNetworkCredential().Password
$resutlt_api = Get-Password -Id $id -APIKey $token

# Use $resutlt_api.Password , $resutlt_api.UserName
$dbUser = $resutlt_api.UserName
$dbPassword = $resutlt_api.Password

return $dbUser, $dbPassword