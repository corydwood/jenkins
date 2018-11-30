function Get-JenkinsJobBuild
{
    [CmdLetBinding()]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $true)]
        [System.String]
        $Uri,

        [parameter(
            Position = 2,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [parameter(
            Position = 3,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Crumb,

        [parameter(
            Position = 4,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Folder,

        [parameter(
            Position = 5,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [parameter(
            Position = 6,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $BuildNumber
    )

    $null = $PSBoundParameters.Add('Type', 'RestCommand')

    $Command = Resolve-JenkinsCommandUri -Folder $Folder -JobName $Name -Command "$BuildNumber/api/json"

    $null = $PSBoundParameters.Remove('Folder')
    $null = $PSBoundParameters.Remove('Name')
    $null = $PSBoundParameters.Remove('BuildNumber')
    $null = $PSBoundParameters.Remove('Confirm')
    $null = $PSBoundParameters.Add('Command', $Command)
    $null = $PSBoundParameters.Add('Method', 'get')

    Invoke-JenkinsCommand @PSBoundParameters
} # Invoke-JenkinsJob
