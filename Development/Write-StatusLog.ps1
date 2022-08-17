#TODO -> See if you can access the log file as a network share
Function Write-StatusLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String] $Device,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Success','Failure')]
        [String] $Status,
        [Parameter(Mandatory=$false)]
        [String] $Log, #Path to the Log
        [Parameter(Mandatory=$false)]
        [Switch] $Overwrite, #Overwrite the value in the log with the current value
        [Parameter(Mandatory=$false)]
        [Switch] $OverwriteFailureWithSuccess, #Overwrites only if the current value is 'failure' and the new value is 'success'
        [Parameter(Mandatory=$false)]
        [Switch] $OverwriteSuccessWithFailure #Overwrites only if the current value is 'success' and the new value is 'failure'
    )

    BEGIN{}

    PROCESS {

        # STEP ONE: READ THE CURRENT STATUS LOG FILE
        Try {
            Write-Verbose 'Reading the current status log file'
            $status_log = Import-CSV $Log -ErrorAction Stop
        } Catch [System.IO.FileNotFoundException] {
            Write-Warning "Unable to find status log at $Log"
            Try {
                Write-Verbose "Attempting to create a status log at $Log"
                New-Item -ItemType File -Path $Log -ErrorAction Stop | Out-File .\Null
                Write-Verbose "Status log successfully created at $Log"
            } Catch {
                Write-Error 'Unable to create status log. There is an uncaught exception that prevented the creation of the status log file'
                Write-Error 'Exiting command'
                Return
            }
        } Catch {
            Write-Error 'Unable to read status log file. There is an uncaught exception that is preventing the file from being read.'
            Write-Error 'Exiting command'
            Return
        }
        
        # STEP TWO: IDENTIFY IF THE RECORD ALREADY EXISTS IN THE STATUS LOG
        Try {
            Write-Verbose 'Determining if the record already exists in the status log file'
            $index = -1
            for ($i=0;$i -lt $status_log.length; $i++){
                if ($status_log[$i].SerialNumber -eq (Get-CimInstance Win32_BIOS -ErrorAction Stop).SerialNumber){
                    $index=$i # The index corresponding to the matching object
                    Write-Verbose "Record already exists for $Device"
                    break
                } 
            }
            if ($index -eq -1) { Write-Verbose "No record exists for $Device" }
        } Catch {
            Write-Error 'Unable to idenitify the serial number of the host system.'
            Write-Error 'Exiting command'
            Return
        }
        
        # STEP THREE: CORRECTLY ADD OR UPDATE RECORD
        if ($index -eq -1){ # No Match - Add Record
            $props = [ordered] @{
                'Device'= $device
                'Status'= $Status
                'SerialNumber'= (Get-CimInstance Win32_BIOS).SerialNumber
                'Date'= (Get-Date).DateTime
            }
            
            $obj = New-Object -TypeName PSCustomObject -Property $props
            Try {
                Write-Verbose "Appending record for $Device to $Log" 
                Export-Csv -InputObject $obj -Path $log -Append
                #$obj | Out-File $log -Append -ErrorAction Stop
                Write-Verbose "Appending record succesful. Exiting Command."
                Return
            } Catch {
                Write-Error "Unable to append new record to $Log. There is an uncaught exception preventing this action."
                Write-Error 'Exiting Command'
                Return
            }
        } elseif ($PSBoundParameters.ContainsKey('Overwrite')){
            Write-Verbose "Overwrite toggled to On. Overwriting current record for $Device"
            $status_log[$index].Status = $status
            $status_log[$index].Date = (Get-Date).DateTime
        } elseif ($PSBoundParameters.ContainsKey('OverwriteFailureWithSuccess') -and ($status_log[$index].Status -like 'Failure') -and ($Status -like 'Success')){
            Write-Verbose "OverwriteFailureWithSuccess toggled to On. Overwriting current failed record with a success record for $Device"
            $status_log[$index].Status = $Status
            $status_log[$index].Date = (Get-Date).DateTime
        } elseif ($PSBoundParameters.ContainsKey('OverwriteSuccessWithFailure') -and ($status_log[$index].Status -like 'Success') -and ($Status -like 'Failure')){
            Write-Verbose "OverwriteSuccessWithFailure toggled to On. Overwriting current success record with a failed record for $Device"
            $status_log[$index].Status = $Status
            $status_log[$index].Date = (Get-Date).DateTime
        } else {
            Write-Verbose "No overwrite conditions met. No change made to $Log"
            Write-Verbose 'Exiting Command'
            Return
        }
    
        # STEP FOUR: OUTPUT DATA TO LOG FILE
        Try {
            Write-Verbose "Writing updated data to $log"
            Export-Csv -InputObject $status_log[0] -Path $log #Overwrite
            for ($i=1;$i -lt $status_log.length; $i++){
                Export-Csv -InputObject $status_log[$i] -Path $log -Append #Append
            }
        } Catch {
            Write-Error "Unable to write new record to $Log. There is an uncaught exception preventing this action."
            Write-Error 'Exiting Command'
            Return
        }
    }

    END {
        if (Test-path .\Null) {Remove-Item .\Null}
    }
    
}
