function Invoke-JenkinsCommand
{
    [CmdLetBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(
            Position = 1,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
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
        [ValidateSet('rest', 'command', 'restcommand', 'pluginmanager')]
        [System.String]
        $Type = 'rest',

        [parameter(
            Position = 5,
            Mandatory = $false)]
        [System.String]
        $Api = 'json',

        [parameter(
            Position = 6,
            Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Command,

        [parameter(
            Position = 7,
            Mandatory = $false)]
        [ValidateSet('default', 'delete', 'get', 'head', 'merge', 'options', 'patch', 'post', 'put', 'trace')]
        [System.String]
        $Method,

        [parameter(
            Position = 8,
            Mandatory = $false)]
        [System.Collections.Hashtable]
        $Headers = @{},

        [parameter(
            Position = 9,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContentType,

        [parameter(
            Position = 10,
            Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Body
    )

    if ($PSBoundParameters.ContainsKey('Credential') -and $Credential -ne [System.Management.Automation.PSCredential]::Empty)
    {
        # Jenkins Credentials were passed so create the Authorization Header
        $Username = $Credential.Username

        # Decrypt the secure string password
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Username + ':' + $Password)
        $Base64Bytes = [System.Convert]::ToBase64String($Bytes)

        $Headers += @{ "Authorization" = "Basic $Base64Bytes" }
    } # if

    if ($PSBoundParameters.ContainsKey('Crumb'))
    {
        Write-Verbose -Message $($LocalizedData.UsingCrumbMessage -f
            $Crumb)

        # Support both Jenkins and Cloudbees Jenkins Enterprise
        $Headers += @{ "Jenkins-Crumb" = $Crumb }
        $Headers += @{ ".crumb" = $Crumb }
    } # if

    $null = $PSBoundParameters.remove('Uri')
    $null = $PSBoundParameters.remove('Credential')
    $null = $PSBoundParameters.remove('Crumb')
    $null = $PSBoundParameters.remove('Type')
    $null = $PSBoundParameters.remove('Headers')

    switch ($Type)
    {
        'rest'
        {
            $FullUri = "$Uri/api/$Api"
            if ($PSBoundParameters.ContainsKey('Command'))
            {
                $FullUri = $FullUri + '/' + $Command
            } # if

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try
            {
                Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
                    $FullUri)

                Set-JenkinsTLSSupport

                $Result = Invoke-RestMethod `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch
            {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'rest'

        'restcommand'
        {
            $FullUri = "$Uri/$Command"

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try
            {
                Write-Verbose -Message $($LocalizedData.InvokingRestApiCommandMessage -f
                    $FullUri)

                Set-JenkinsTLSSupport

                $Result = Invoke-RestMethod `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch
            {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'restcommand'

        'command'
        {
            $FullUri = $Uri
            if ($PSBoundParameters.ContainsKey('Command'))
            {
                $FullUri = $FullUri + '/' + $Command
            } # if

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            Write-Verbose -Message $($LocalizedData.InvokingCommandMessage -f
                $FullUri)

            Set-JenkinsTLSSupport

            $Result = Invoke-WebRequest `
                -Uri $FullUri `
                -Headers $Headers `
                -MaximumRedirection 0 `
                @PSBoundParameters `
                -ErrorAction SilentlyContinue `
                -ErrorVariable RequestErrors

            if ($RequestErrors.Count -eq 1 -and $Result.StatusCode -eq 302 `
                    -and $RequestErrors[0].FullyQualifiedErrorId -like "MaximumRedirectExceeded,*")
            {
                Write-Verbose -Message $($LocalizedData.SuppressingRedirectMessage -f $Result.Headers.Location)
            }
            elseif ($RequestErrors.Count -ge 1)
            {
                # Todo: Improve error handling.
                throw $RequestErrors[0].Exception
            }
        } # 'command'

        'pluginmanager'
        {
            $FullUri = $Uri
            if ($PSBoundParameters.ContainsKey('Command'))
            {
                $FullUri = "$FullUri/pluginManager/api/$api/?$Command"
            } # if (condition) {

            $null = $PSBoundParameters.remove('Command')
            $null = $PSBoundParameters.remove('Api')

            try
            {
                Write-Verbose -Message $($LocalizedData.InvokingCommandMessage -f
                    $FullUri)

                Set-JenkinsTLSSupport

                $Result = Invoke-WebRequest `
                    -Uri $FullUri `
                    -Headers $Headers `
                    @PSBoundParameters `
                    -ErrorAction Stop
            }
            catch
            {
                # Todo: Improve error handling.
                Throw $_
            } # catch
        } # 'pluginmanager'
    } # switch

    Return $Result
} # Invoke-JenkinsCommand
