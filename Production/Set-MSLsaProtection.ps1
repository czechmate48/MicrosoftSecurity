Function Set-MSLsaProtection {

<#
.SYNOPSIS
This cmdlet enables or disables the Local Security Authority's ability to run as a Protection Process Light
.DESCRIPTION
The cmdlet enables or disables addition protection to prevent code injection that could be used to compromise user credentials on a Windows system. 
When enabled, this cmdlet ensures the local security authority server services is running as a protected process light, and prevents malicious 
programs from reading user credentials stored in memory. This protection is achieved by  adding a registry value called 'RunAsPPL' to the LSA key 
located at HKLM:\SYSTEM\CurrentControlSet\Control\Lsa
.PARAMETER $State
This required parameter sets the value of 'RunAsPPL'
.EXAMPLE
Set-LsaProtection -State Disable
.EXAMPLE
Set-LsaProtection Enable
.NOTES
This cmdlet has been tested on the Windows 10 operating system. Functionality not guaranteed on other operating systems. Visit my github 
at https://github.com/czechmate48 for more cmdlets and scripts related to windows security. Please visit the follow windows webpage
for more information about configuring LSA protection 
https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [ValidateSet('Enable','Disable')]
        [string] $State
    )

    BEGIN {}
    
    PROCESS {

        if ($State -eq 'Enable'){
            $registryValue=1
        } else {
            $registryValue=0
        }
        
        $FinalState=$State+'d'

        Try {
            Write-Verbose "Setting 'RunAsPPL' value in 'Lsa' key to $registryValue"
            Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name RunAsPPL -Value $registryValue -ErrorAction Stop
            Write-Verbose "RunAsPPL successfully set to $registryValue"
            Write-Verbose "LSA Protection is now $FinalState"
        } Catch {
            Try {
                Write-Warning "Unable to set value 'RunAsPPL' to $registryValue because it does not exist. Attempting to create 'RunAsPPL' in the registry."
                New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\ -Name RunAsPPL -Value $registryValue -PropertyType DWord -ErrorAction Stop
                Write-Verbose "RunAsPPL successfully set to $registryValue"
                Write-Verbose "LSA Protection is now $FinalState"
            } Catch {
                Write-Warning "Unable to create 'RunAsPPL' in the registry"
                Write-Error "Aborting operation. Unable to set 'RunAsPPL' to $registryValue"
            }
        }
    }
    
    END {}
}
