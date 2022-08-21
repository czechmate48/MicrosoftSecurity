Function Get-MS365LastLogin {

    <#
    .SYNOPSIS
    This cmdlet obtains the last login for the specified users.
    .DESCRIPTION
    This cmdlet obtains the last login for the specified users. If no users are specified, this cmdlet queries the top 999 individuals in the 
    tenant. If more users are needed, they can be passed in or the code must be manually modified
    .PARAMETER $UserPrincipalName
    The upn of the users login reports to obtain
    .PARAMETER $Member
    Tells the cmdlet to only obtain information on members
    .PARAMETER $Guest
    Tells the cmdlet to only obtain information on guests
    .EXAMPLE
    Get-MS365LastLogin -TenandID xxxx -AppClientId xxxx -member
    .EXAMPLE
    Get-MS365LastLogin -TenandID xxxx -AppClientId xxxx -userprincipalname john.doe@contoso.net,jane.doe@contoso.net
    #>

    [CmdletBinding()]
    param (
        [System.Object[]] $UserPrincipalName,
        [Switch] $member,
        [Switch] $guest
    )

    BEGIN{

        # Query graph API for first 999 users
        $ApiUrl = "https://graph.microsoft.com/beta/users?`$select=accountEnabled,displayName,userPrincipalName,signInActivity,userType,createdDateTime,ExternalUserState&`$top=999"
        $Response = Invoke-RestMethod -Method Get -Uri $apiurl -headers $headers
        
        # Select specific users if specified by the end user
        if ($UserPrincipalName.count -ne 0){
            $Users = @()
            foreach ($user in $Response.Value){
                foreach ($upn in $UserPrincipalName){
                    if ($user.userPrincipalName -like $upn){
                        $users += $user
                    }
                }
            }
        } else {
            $users = $response.value
        }

    }

    PROCESS {

        foreach ($user in $users){

            if ($null -eq $user.signInActivity.lastSignInDateTime){
                $lastInteractiveLogin = "Never"
            } else {
                $lastInteractiveLogin = $user.SignInActivity.lastSignInDateTime
            }

            if ($null -eq $user.signInActivity.lastNonInteractiveSignInDateTime){
                $lastNonInteractiveLogin= "Never"
            } else {
                $lastNonInteractiveLogin = $user.SignInActivity.lastNonInteractiveSignInDateTime
            }

            if (($lastInteractiveLogin -like "Never") -and ($lastNonInteractiveLogin -like "Never")){
                $daysSinceLastLogin = "Never logged in"
            } else {

                $daysSinceLastLogin_NonInteractive = ($(Get-Date) - $lastNonInteractiveLogin).days
                $daysSinceLastLogin_Interactive = ($(Get-Date) - $lastInteractiveLogin).days

                if ($daysSinceLastLogin_NonInteractive -lt $daysSinceLastLogin_Interactive){
                    $daysSinceLastLogin = $daysSinceLastLogin_NonInteractive
                } elseif ($daysSinceLastLogin_NonInteractive -gt $daysSinceLastLogin_Interactive){
                    $daysSinceLastLogin = $daysSinceLastLogin_Interactive
                } elseif ($daysSinceLastLogin_NonInteractive -eq $daysSinceLastLogin_Interactive){
                    $daysSinceLastLogin = $daysSinceLastLogin_Interactive
                } elseif (($null -ne $daysSinceLastLogin_NonInteractive) -and ($null -eq $daysSinceLastLogin_Interactive)){
                    $daysSinceLastLogin = $daysSinceLastLogin_NonInteractive
                } elseif (($null -eq $daysSinceLastLogin_NonInteractive) -and ($null -ne $daysSinceLastLogin_Interactive)){
                    $daysSinceLastLogin = $daysSinceLastLogin_Interactive
                } else {
                    $daysSinceLastLogin = ""
                }
            }

            $Domain = $user.UserPrincipalName.Split("@")[1]

            if ($member -and ($user.usertype -like "Member")){
                [PSCustomObject]@{
                    DisplayName = $user.displayName
                    UserPrincipalName = $user.UserPrincipalName
                    UserType = $user.usertype
                    AccountEnabled = $user.accountEnabled
                    CreatedDateTime = $user.CreatedDateTime
                    Domain = $domain
                    LastInteractiveLogin = $lastInteractiveLogin
                    LastNonInteractiveLogin = $lastNonInteractiveLogin
                    DaysSinceLastLogin = $daysSinceLastLogin
                }
            } elseif ($guest -and ($user.usertype -like "Guest")){

                $Domain = $user.DisplayName.Split("@")[1]

                [PSCustomObject]@{
                    DisplayName = $user.displayName
                    UserPrincipalName = $user.UserPrincipalName
                    UserType = $user.usertype
                    AccountEnabled = $user.accountEnabled
                    CreatedDateTime = $user.CreatedDateTime
                    Domain = $domain
                    ExternalUserState = $user.ExternalUserState
                    LastInteractiveLogin = $lastInteractiveLogin
                    LastNonInteractiveLogin = $lastNonInteractiveLogin
                    DaysSinceLastLogin = $daysSinceLastLogin
                }
            }
        }
    }

    END {}
}
