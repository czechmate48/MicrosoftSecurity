Function Get-MS365ActiveAuthenticationMethod {

    <#
    .SYNOPSIS
    This cmdlet identifies which authentication methods are active on the user accounts
    .DESCRIPTION
    This cmdlet queries the Microsoft Graph to obtain a list of users in the tenant and their associated authentication methods. Any authentications methods that may be used
    for resetting passwords, logging into the graph, or performing MFA are marked as 'Active'
    .PARAMETER $UserPrincipalName
    The user to perform the query against. If no user is specified, all users in the tenant are queried. 
    .EXAMPLE
    Get-MS365ActiveAuthenticationMethods -Userprincipalname John.Doe@contoso.com
    .NOTES
    https://docs.microsoft.com/en-us/graph/api/resources/authenticationmethods-overview?view=graph-rest-1.0
    https://docs.microsoft.com/en-us/graph/api/authentication-list-methods?view=graph-rest-1.0
    #>

    [CmdletBinding()]
    param (
        [System.Object[]] $UserPrincipalName = @() # Declare array as empty or values will be added one letter at a time instead of one UPN at a time
    )

    BEGIN{

        # Admin must be global administrator, global reader, privileged authentication administrator, or authentication administrator

        if ($UserPrincipalName.Count -eq 0){
            $ApiUrl = "https://graph.microsoft.com/v1.0/users?`$top=999"
            $Response = Invoke-RestMethod -Method Get -Uri $apiurl -headers $headers

            foreach ($resp in $response.value){
                $UserPrincipalName += $resp.userprincipalname
            }
        }

    }

    PROCESS {

        foreach ($user in $UserPrincipalName){

            Try {
                $response = Invoke-RestMethod -Method Get -uri "https://graph.microsoft.com/v1.0/users/$user/authentication/methods" -headers $headers -ErrorAction Stop

                $Email,$Fido,$Authenticator,$Password,$Phone,$SoftwareOath,$TemporaryAccessPass,$WindowsHello = ''

                foreach ($value in $response.value){
                    if ($value.'@odata.type' -like "*emailAuthenticationMethod*"){
                        $Email = "Active"
                    }
                    if ($value.'@odata.type' -like "*fido2AuthenticationMethod*"){
                        $Fido = "Active"
                    }
                    if ($value.'@odata.type' -like "*microsoftAuthentcatorAuthenticationMethod*"){
                        $Authenticator = "Active"
                    }
                    if ($value.'@odata.type' -like  "*passwordAuthenticationMethod*"){
                        $Password = "Active"
                    }
                    if ($value.'@odata.type' -like  "*PhoneAuthenticationMethod*"){
                        $Phone = "Active"
                    }
                    if ($value.'@odata.type' -like  "*softwareOathAuthenticationMethod*"){
                        $SoftwareOath = "Active"
                    }
                    if ($value.'@odata.type' -like  "*temporaryAccessPassAuthenticationMethod*"){
                        $TemporaryAccessPass = "Active"
                    }
                    if ($value.'@odata.type' -like  "*windowsHelloForBusinessAuthenticationMethod*"){
                        $WindowsHello = "Active"
                    }
                }

                [PSCustomObject]@{
                    UserPrincipalName = $user
                    Email = $Email
                    Fido = $Fido
                    Authenticator = $Authenticator
                    Password = $Password
                    Phone = $Phone
                    SoftwareOath = $SoftwareOath
                    TemporaryAccessPass = $TemporaryAccessPass
                    WindowsHello = $WindowsHello
                }
            } Catch {
                # Do Nothing
            }
            
        }
    
    }

    END {}
}