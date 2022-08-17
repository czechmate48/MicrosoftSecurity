Function Set-MSAutoRunCommand {

    <#
    .SYNOPSIS
    This cmdlet enables or disables windows ability to Autorun commands
    .DESCRIPTION
    This cmdlet enables or disables Autorunning commands by changing the value of 'NoAutoRun' to a 0(enabled) or 1(disabled).
    If the NoAutoRun value does not exist, the cmdlet creates the value and sets it to the correct value. Autorun is vulnerable
    as malicious code may execute without any user interaction. Autorun commands are typically stored with the *.inf extension. 
    .PARAMETER $State
    This required parameter sets the value of 'NoAutoRun'
    .EXAMPLE
    Set-MSAutoRunCommand -State 'Enable'
    .EXAMPLE
    Set-MSAutoRunCommand -State 'Disable'
    .NOTES
    This script sets the value NoAutoRun to Enabled, which is the logical equivalent of setting AutoRun to Disable
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName,Position=0)]
        [ValidateSet('Enable','Disable')]
        [String] $State
    )

    BEGIN {}
    
    PROCESS {

        if ($State -eq 'Enable'){
            $registryValue=0
        } else {
            $registryValue=1
        }
        
        $FinalState=$State+'d'

        Try {
            Write-Verbose "Setting 'NoAutoRun' value in Explorer registry key to $registryValue"
            Set-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoAutoRun -Value $registryValue -ErrorAction stop
            Write-Verbose "'NoAutoRun' succesfully set to $registryValue"
            Write-Verbose "Autorun commands are now $FinalState"
        } Catch {
            Try {
                Write-Warning "Unable to set value 'NoAutoRun' to $registryValue because it does not exist. Attempting to create 'NoAutoRun' in the registry"
                New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\ -Name NoAutoRun -Value $registryValue -PropertyType DWORD -ErrorAction Stop | Out-File .\Null
                Write-Verbose "NoAutoRun successfully set to $registryValue"
                Write-Verbose "Autorun commands are now $FinalState"
            } Catch {
                Write-Warning "Unable to create 'NoAutoRun' in the registry"
                Write-Error "Aborting operation. Unable to set 'NoAutoRun' to $registryValue"
            }
        }
    }
    
    END {}
}
