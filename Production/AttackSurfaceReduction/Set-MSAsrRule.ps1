Function Set-MSAsrRule {

<#
.SYNOPSIS
This cmdlet sets the attack surface reduction rules for Microsoft Defender for Endpoint. 
.DESCRIPTION
Use this cmdlet to set the attack surface reduction rules for Microsoft Defender for Endpoint. This cmdlet works by receiving a pscustomobject with 
two parameters, guid and name, which correspond to attack surface reduction rules. For example, Consider the following .csv format as displayed in excel:
GUID                                    NAME
56a863a9-875e-4185-98a7-b882c64b5ce5    Block abuse of exploited vulnerable signed drivers
7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c    Block Adobe Reader from creating child processes
These rules can be set to one of four states ('AuditMode', 'Warn', 'Enabled', or 'Disabled'). 
    - AuditMode: "Evaluates how the ASR rule would impact your organization if enabled"
    - Warn: "Enable the ASR rule but allow the end user to bypass the block"
    - Enabled: "Enable the ASR rule"
    - Disabled: "Disable the ASR rule"
Please see https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/enable-attack-surface-reduction?view=o365-worldwide#requirements
You can set as many rules at a time as you would like. By default, the cmdlet adds the rules to the current ruleset. In order to overwrite the current
ruleset, you must specify the 'Overwrite' parameter. Furthermore, you can specify whether to continue with adding the rules even if you are unable to 
overwrite the current ruleset by setting the 'AddRulesToExistingRulesetOnOverwriteError' parameter to true. 
.PARAMETER $Mode
The mode to place the attack surface reduction rules in. All ASR are put in the same mode, and it is not possible to set various modes for each rule
.PARAMETER $Map
This pscustomobject holds a mapping of the rule name to the guid. By default, Powershell needs the guid to set the rule. This parameter can be easily
created be placing a listing of the ASR in a .CSV file with the headings 'GUID' and 'NAME' and then importing the CSV. 
.PARAMETER $Overwrite
Toggle this parameter to overwrite the existing ruleset. 
.PARAMETER $AddRulesToExistingRulesetOnOverwriteError
Set this parameter to true to continue adding the specified ASR rule even if there is an error when attempting to overwrite the current ruleset
.EXAMPLE
Set-ASRRule -Mode Enabled -Map $ASRRules
Set the attack surface reduction rules to enabled
.EXAMPLE
Set-ASRRule -Mode AuditMode -Map (Import-CSV C:\Users\ASRRules.csv) -Overwrite - $AddRulesToExistingRulesetOnOverwriteError
Import a CSV file and set the attack surface reduction rules to audit mode. Overwrite the existing ruleset. 
.NOTES
This cmdlet has been tested on the Windows 10 operating system. Functionality not guaranteed on other operating systems. Visit my github 
at https://github.com/czechmate48 for more cmdlets and scripts related to windows security. 
.LINK
The following web pages were referenced when creating the cmdlet: 
# https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules?view=o365-worldwide#block-adobe-reader-from-creating-child-processes
# https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=windowsserver2019-ps
# https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/enable-attack-surface-reduction?view=o365-worldwide#powershell
#>

    # Two rule sets ('AddRules', 'Overwrite'): Overwrite is used for overwriting the current ASR rules
    [CmdletBinding(DefaultParameterSetName='AddRules')]
    Param (
        [Parameter(Mandatory=$true, ParameterSetName='AddRules')]
        [Parameter(Mandatory=$true, ParameterSetName='Overwrite')]
        [ValidateSet('AuditMode','Warn','Enabled','Disabled')]
        [String] $Mode,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='AddRules')]
        [Parameter(Mandatory=$true, ParameterSetName='Overwrite')]
        [PSCustomObject] $Map, # Maps ASR Rule Names to the respective Guid. 

        [Parameter(ParameterSetName='Overwrite', Mandatory=$false)]
        [Switch] $Overwrite,

        [Parameter(ParameterSetName='Overwrite', Mandatory=$true)]
        [Boolean] $AddRulesToExistingRulesetOnOverwriteError
    )

    Write-Verbose "Checking map object to ensure it contains 'guid' and 'name' properties." 
    if ($Map.count -eq 0) {
        Write-Error -Message "Unable to set attack surface reduction rules. The specified map does not contain 
        any objects. Please specify at least one object and ensure it has the properties 'guid' and 'name'."
        Return # Exit the function
    }

    # Use the first element of the map to ensure the object contains the correct properties
    $containsGuid = [bool] ($map[0].psobject.properties.name -eq 'guid')
    $containsName = [bool] ($map[0].psobject.properties.name -eq 'name')

    if ($containsGuid -eq $False -or $containsName -eq $False){
        Write-Error -Message "Unable to set attack surface reduction rules. The specified map does not contain the
        correct properties. Please specify an object with the properties 'guid' and 'name'."
        Return # Exit the function
    } else {
        Write-Verbose "Map parameter correctly formatted with 'guid' and 'name' properties."
    }

    # OVERWRITE EXISTING ASR
    $asrInitialIndex=0 # Controls which index is initially used when adding ASR rules. Allows user to overwrite the current ASR rules.
    If ($PSBoundParameters.ContainsKey('overwrite')){
        Write-Verbose "Overwriting current attack surface reduction rules."
        try {
            Set-MpPreference -AttackSurfaceReductionRules_Ids $map[$asrInitialIndex].guid -AttackSurfaceReductionRules_Actions $mode -ErrorAction Stop
            $message = $map[$asrInitialIndex].name + " set succesfully"
            Write-Verbose $message
            $asrInitialIndex = 1
        } catch {
            Write-Warning 'Unable to overwrite attack surface reduction rules'
            if ($AddRulesToExistingRulesetOnOverwriteError -eq $false){
                Write-Error 'Unable to overwrite ASR rules. Exiting function.'
                Return # Exit the function
            }
            #asrInitialIndex stays 0 if $AddRulesToExistingRuleseOnOverwriteError is true
        }
    }

    # ADD ASR
    for ($i=$asrInitialIndex; $i -lt $map.count; $i++){
        try {
            Add-MpPreference -AttackSurfaceReductionRules_Ids $map[$i].guid -AttackSurfaceReductionRules_Actions $mode -ErrorAction Stop
            $message = $map[$i].name + " set succesfully"
            Write-Verbose $message
        } catch {
            $message = "Failed to set " + $map[$i].name
            Write-Error $message
        }
    }
}
