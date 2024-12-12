
$ErrorActionPreference = "Stop";
#$VerbosePreference = "continue";
$VerbosePreference = "SilentlyContinue";

$cwd = Split-Path $script:MyInvocation.MyCommand.Path


################################################################################
####   INCLUDE
################################################################################
. "$cwd\common\LogsUtilities.ps1";
. "$cwd\common\AESUtilities.ps1";
###############################################

# Managing Error
trap{
    Write-HostError -ErrorObj $_
    Write-Error "`n - - > For more information, see the previous log`n $($_.Exception)"
    exit 1;
}


$myFileName = "5443joig435gvh.conf";

$key = (Get-Content "$cwd\common\Utilities.ps1");

if(!(Test-Path "$cwd\$myFileName")){
        
        # Get Info 
        $CipUsager = $Env:UserName
        $s1= Read-Host -Prompt "Mot de passe usager [$CipUsager]" -AsSecureString

        # Objet credential
        $credentials = New-Object System.Net.NetworkCredential("UNKNOW", $s1, "UNKNOW")

        $encryptedKey = Set-EncryptedString -AESKey $key -StringToConvert $credentials.Password;


        ## Création du fichier .conf ##
        New-Item -Path "$cwd" -Name $myFileName -ItemType "file" -Value $encryptedKey | Out-Null;

}


$cred_id = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "UNKNOW", (Get-Content -Path "$cwd\$myFileName" | ConvertTo-SecureString -Key $key);

$cipPassword = $cred_id.GetNetworkCredential().Password
