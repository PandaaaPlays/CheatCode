. "$(Split-Path $script:MyInvocation.MyCommand.Path)\LogsUtilities.ps1";


function Get-Properties
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $PathFile
    )
    Begin
    {
        if (!(Test-Path "$PathFile"))
         {
            Throw-Custom "Cannot find the file to the path $PathFile";
         }
    }
    Process
    {
        $properties = convertfrom-stringdata (get-content "$PathFile" -raw);
    }
    End
    {
        return $properties;
    }

}