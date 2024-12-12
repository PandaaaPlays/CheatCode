function Set-AESKEY
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $FilePath
    )

    Begin
    {
        $AESKey  = New-Object Byte[] 32;
    }
    Process
    {
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey );
    }
    End
    {
        $AESKey  | out-file $FilePath;
    }
}


function Set-EncryptedString
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $AESKey,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
        $StringToConvert
    )

    Begin
    {
    }
    Process
    {
        $StringSecureString = $StringToConvert | ConvertTo-SecureString -AsPlainText -Force
        $StringToConverted = $StringSecureString | ConvertFrom-SecureString -key $AESKey
    }
    End
    {
        return $StringToConverted;
    }
}