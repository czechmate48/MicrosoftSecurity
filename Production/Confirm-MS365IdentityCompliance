Function Confirm-MS365IdentityCompliance{

    <#
    .SYNOPSIS
    This cmdlet determines if a cloud identity is enabled, licensed, and has MFA turned on.
    .DESCRIPTION
    This cmdlet determines if a cloud identity is enabled, licensed, and has MFA turned on. These three properties are 
    used to determine whether the account is compliant or not. 
    .PARAMETER $MsolUsers
    Obtains user objects using the Get-MsolUser cmdlet
    .EXAMPLE
    Confirm-MS365IdentityComplaince -msolUsers $users
    .NOTES
    Requires the Msol module
    #>

    [Cmdletbinding()]
    param (
        [Parameter(Position=0)]
        [System.Object[]] $msolUsers
    )

    BEGIN {
        if ($msolUsers.count -eq 0){
            Connect-MsolService
            $msolUsers = Get-MsolUser -All
        }
    }

    PROCESS {

        foreach ($msolUser in $msolUsers){

            # OBTAIN LICENSE, MFA, AND ENABLED
            $authenticationMethods = ($msolUser | Select-Object -Property StrongAuthenticationMethods).StrongAuthenticationMethods
            if ($authenticationMethods.count -eq 0){
                $mfa = 'Off'
            } else {
                $mfa = 'On'
            }
    
            $licensed = $msolUser.IsLicensed
            if ($licensed -eq $false){
                $license = 'Not Licensed'
            } else {
                $license = 'Licensed'
            }
    
            $status = $msolUser.BlockCredential
            if ($status -eq $false){
                $status = 'Enabled'
            } else {
                $status = 'Not Enabled'
            }

            # DETERMINE COMPLIANCE
            if (($license -like 'Licensed') -and ($mfa -like 'Off') -and ($status -like 'Enabled')) {
                $Compliance = 'Not Compliant'
                $Reason = 'MFA turned off'
            } elseif (($license -like 'Not Licensed') -and ($mfa -like 'On') -and ($status -like 'Enabled')){
                $Compliance = 'Compliant'
                $Reason = ''
            } elseif (($license -like 'Licensed') -and ($mfa -like 'Off') -and ($status -like 'Not Enabled')){
                $Compliance = 'Compliant'
                $Reason = ''
            } elseif (($license -like 'Not Licensed') -and ($mfa -like 'Off') -and ($status -like 'Enabled')){
                $Compliance = 'Not Compliant'
                $Reason = 'MFA turned off'
            } elseif (($license -like 'Licensed') -and ($mfa -like 'On') -and ($status -like 'Not Enabled')){
                $Compliance = 'Compliant'
                $Reason = ''
            } elseif (($license -like 'Not Licensed') -and ($mfa -like 'On') -and ($status -like 'Not Enabled')){
                $Compliance = 'Compliant'
                $Reason = ''
            } elseif (($license -like 'Licensed') -and ($mfa -like 'On') -and ($status -like 'Enabled')){
                $Compliance = 'Compliant'
                $Reason = ''
            } elseif (($license -like 'Not Licensed') -and ($mfa -like 'Off') -and ($status -like 'Not Enabled')){
                $Compliance = 'Compliant'
                $Reason = ''
            } else {
                $Compliance = 'Not Compliant'
                $Reason = 'Unable to determine compliance level'
            }
    
            # OUTPUT OBJECT
            $obj = [PSCustomObject] @{
                Name = $msolUser.UserPrincipalName
                Type = $msolUser.usertype
                MfaStatus = $mfa
                AccountEnabled = $status
                LicenseStatus = $license
                Compliance = $compliance
                Reason = $Reason
            }
    
            $obj
        }

    }

    END {}

}
