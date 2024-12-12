function Write-HostCustom
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"
###  $(Get-Date) - $StringToWrite       
"@; 
    }
    Process
    {
        Write-Host $str;
    }
    End
    {
    }
}

function Write-VerboseCustom
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"
###  $(Get-Date) - $StringToWrite       
"@; 
    }
    Process
    {
        Write-Verbose $str;
    }
    End
    {
    }
}


function Write-HostCustomHashtable
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"
###  $(Get-Date)
$($StringToWrite | Out-String)
### 
"@; 
    }
    Process
    {
        Write-Host $str;
    }
    End
    {
    }
}


function Write-HostCustomHeader
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"
###################################################################################################
###  $(Get-Date) - $StringToWrite
################################################################################################### 
 
"@; 
    }
    Process
    {
        Write-Host $str;
    }
    End
    {
    }
}


function Write-HostCustomHeaderSub
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"
###################################################################################################
###  $(Get-Date) - $StringToWrite
"@; 
    }
    Process
    {
        Write-Host $str;
    }
    End
    {
    }
}


function Write-HostCustomFooterSub
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"
###  $(Get-Date) - $StringToWrite
###################################################################################################
"@; 
    }
    Process
    {
        Write-Host $str;
    }
    End
    {
    }
}


function Throw-Custom
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $StringToWrite
    )
    Begin
    {
        $str = @"

###  $(Get-Date) - $StringToWrite

"@; 
    }
    Process
    {
        throw $str;
    }
    End
    {
    }
}

function Write-HostError
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ErrorObj
    )
    Begin
    {
        $str = @"

###  Type : $($_.FullyQualifiedErrorId)
      
###  Stack Trace : $($_.ScriptStackTrace)

###  Exception : $($_.Exception)
 
"@; 


    }
    Process
    {
        Write-Host $str;
    }
    End
    {
        Write-HostCustomHeader -StringToWrite "ERROR ERROR ERROR ERROR ERROR ERROR";
        Write-Host $str;
    }
}