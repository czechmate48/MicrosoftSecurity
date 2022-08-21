Write-Host ""
Write-Host "This module requires access to the Microsoft Graph. Please enter your Tenant ID and Powershell AppClient ID" -ForegroundColor Yellow
Write-Host ""
$TenantId = Read-Host "Tenant ID"
$AppClientId = Read-Host "AppClientID"

$MsalParams = @{
    ClientId = $AppClientId
    TenantId = $TenantId
    Scopes   = "https://graph.microsoft.com/User.Read.All","https://graph.microsoft.com/AuditLog.Read.All"
}

Try {
    Write-Host ""
    Write-Host "Generating access token for Microsoft Graph" -ForegroundColor Yellow
    $MsalResponse = Get-MsalToken @MsalParams -ErrorAction Stop
    $Global:AccessToken  = $MsalResponse.AccessToken
    $Global:headers = @{'Content-Type'="application\json";'Authorization'="Bearer $AccessToken"}
    Write-Host "Access token successfully created" -ForegroundColor Green
    Write-Host "The module is now available" -ForegroundColor Yellow
    Write-Host ""
    
} Catch {
    Write-Host "Failed to create an access token" -ForegroundColor Red
    Write-Host "Please try closing your powershell session and reimporting the module" -ForegroundColor Yellow
    Write-Host ""
}