Function Set-MSEnumerateAdministratorOnElevation {
<#
.SYNOPSIS
This cmdlet enables or disables the windows setting 'Enumerate Administrator on Elevation'
.DESCRIPTION
Use this cmdlet to enable or disable the 'Enumerate Administrator on Elevation' setting in the windows operating system. 
Doing so prevents a list of administrator accounts from being displayed when a user activates the UAC prompt for administrator elevation.
Disabling the enumeration provides a layer of protection from bad actors that are attempting to learn the usernames for administrative accounts.
The cmdlet works by accessing the 'CredUI' registry key and setting the 'EnumerateAdministrators' value to 0(disable) or 1(enable). If 
no 'CredUI' registry key exists, the script creates the registry key as well as the 'EnumerateAdministrators' value.  
.PARAMETER $State
This required parameter sets the value of 'EnumerateAdministrators'
.EXAMPLE
Set-EnumerateAdministratorOnElevation -State Disable
.EXAMPLE
Set-EnumerateAdministratorOnElevation Enable
.NOTES
This cmdlet has been tested on the Windows 10 operating system. Functionality not guaranteed on other operating systems.
#>

    [Cmdletbinding()]
    param (
        [Parameter(Mandatory =$True, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Validateset('Enable','Disable')]
        [String] $State
    )

    BEGIN{}
    
    PROCESS{

        if ($State -eq 'Disable'){

            Try {
                Write-Verbose "Setting EnumerateAdministrators value in CredUI registry key to 0"
                Set-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI -Name EnumerateAdministrators -value 0 -ErrorAction stop
                Write-Verbose "CredUI registry key successfully set to 0"
            } catch {
                Write-Warning "Unable to set property 'EnumerateAdministrators'. Attempting to create new registry subkey, CredUI, and set value for EnumerateAdministrators.'"
                New-Item -Name CredUI -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ | Out-File .\Null
                Write-Verbose "Creating EnumerateAdministrators value and setting to 0"
                New-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI -Name EnumerateAdministrators -PropertyType DWORD -value 0 | Out-File .\Null
                Write-Verbose "CredUI registry key successfully set to 0"
            }

        } elseif ($State -eq 'Enable'){

            Try {
                Write-Verbose "Setting EnumerateAdministrators value in CredUI registry key to 1"
                Set-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI -Name EnumerateAdministrators -value 1 -ErrorAction Stop
                Write-Verbose "CredUI registry key successfully set to 1"
            } Catch {
                Write-Warning "Unable to set property 'EnumerateAdministrators'. Attempting to create new registry subkey, CredUI, and set value for EnumerateAdministrators."
                New-Item -Name CredUI -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ | Out-File .\Null
                Write-Verbose "Creating EnumerateAdministrators value and setting to 1"
                New-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI -Name EnumerateAdministrators -PropertyType DWORD -value 1 | Out-File .\Null
                Write-Verbose "CredUI registry key successfully set to 1"
            }
        }
    }
    
    END{}
    
}
