######################
# GATHER INFORMATION #
######################

Write-Host ""
Write-Host "This module requires access to the Microsoft Graph. Please enter your Tenant ID and Powershell AppClient ID" -ForegroundColor Yellow
Write-Host ""
$Global:TenantId = Read-Host "Tenant ID"
$Global:AppClientId = Read-Host "AppClientID"

##################################
# INSTALL MICROSOFT GRAPH MODULE #
##################################

Write-Host ""
Write-Host "Determining whether Microsoft Graph module is installed" -ForegroundColor Yellow

if (-not (Get-InstalledModule Microsoft.Graph)){
    Write-Host "Microsoft Graph module not found" -ForegroundColor Yellow
    Write-Host "Microsoft Graph module is required for some commands to work properly" -ForegroundColor Yellow
    $installGraph = Read-Host "Do you want to install the Microsoft Graph module? [Y/N]"
} else {
    Write-Host "Microsoft Graph module found" -ForegroundColor Yellow
}

if ($installGraph -match "[yY]"){
    
    Try {
        Write-Host ""
        Write-Host "Installing the Microsoft Graph module" -ForegroundColor Yellow
        Install-Module Microsoft.Graph -Repository PSGallery -Scope CurrentUser -AllowClobber -force -ErrorAction Stop
        Write-Host "Microsoft Graph module installed successfully" -ForegroundColor Yellow
    } Catch {
        Write-Error "Unable to install the Microsoft Graph module"
        Write-Host "Some commands will not work properly." -ForegroundColor Yellow
    }

}

##############################
# CONNECT TO MICROSOFT GRAPH #
##############################

$MsalParams = @{
    ClientId = $AppClientId
    TenantId = $TenantId
    Scopes   = "https://graph.microsoft.com/User.Read.All","https://graph.microsoft.com/AuditLog.Read.All","https://graph.microsoft.com/UserAuthenticationMethod.Read.All"
}

Try {
    Write-Host ""
    Write-Host "Generating access token for Microsoft Graph" -ForegroundColor Yellow
    $MsalResponse = Get-MsalToken @MsalParams -ErrorAction Stop
    $Global:AccessToken  = $MsalResponse.AccessToken
    $Global:Headers = @{'Content-Type'="application\json";'Authorization'="Bearer $AccessToken"}
    Write-Host "Access token successfully created" -ForegroundColor Green
    Write-Host "The module is now available" -ForegroundColor Yellow
    Write-Host ""
    
} Catch {
    Write-Host "Failed to create an access token" -ForegroundColor Red
    Write-Host "Please try closing your powershell session and reimporting the module" -ForegroundColor Yellow
    Write-Host ""
}