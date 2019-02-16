#This script will get user sign in logs from azure AD, import the script as module in powershell
#run examples
#GetSignInLogs -upn sc@lab365.gq -DateGTE 2019-02-10 -getfailed
#
#-upn: upn of the user you wish to fetch the signin logs
#-getfailed: is a switch, if used will skip the success logs
#-DateGTE: date greater than or equal to accept the YYYY-MM-DD format, if run without a dateGTE script will fetch all the available logs.

#you if do not know how to setup the Azure app and permissions check out my blogs here on working wiht Graph API
#https://www.sunilchauhan.info/2019/02/working-with-microsoft-graph-api-using.html
#https://www.sunilchauhan.info/2019/02/working-with-microsoft-graph-api-using_10.html

function GetSignInLogs {
param ($upn, [switch]$getfailed,$DateGTE)
if ($dateGTE) {
if ($DateGTE -notmatch "\d{4}-[0-1][0-2]-\d{2}") { Write-Host "Supplied date format is not correct, please use date format as 'YYYY-MM-DD'" -ForegroundColor Yellow ;break}
}
#///////////////////MODIFY THE DETAILS BELOW/////////////////////////////////////
$Office365Username='adminuserid'
$Office365Password='Password'
$clientId = "c14a2820-b922-4139-901b-36024950fc95"
#////////////////////////////////////////////////////////////////////////////////

$redirectUri = "https://localhost"
$resourceURI = "https://graph.microsoft.com"
$authority = "https://login.microsoftonline.com/common"

try {
$AadModule = Import-Module -Name AzureAD -ErrorAction Stop -PassThru
}
catch {
throw 'Prerequisites not installed (AzureAD PowerShell module not installed)'
}
$adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
[System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
 
##option without user interaction
if (([string]::IsNullOrEmpty($Office365Username) -eq $false) -and ([string]::IsNullOrEmpty($Office365Password) -eq $false))
{
$SecurePassword = ConvertTo-SecureString -AsPlainText $Office365Password -Force
#Build Azure AD credentials object
$AADCredential = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential" -ArgumentList $Office365Username,$SecurePassword
# Get token without login prompts.
$authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceURI, $clientid, $AADCredential);
}
else
{
# Get token by prompting login window.
$platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
$authResult = $authContext.AcquireTokenAsync($resourceURI, $ClientID, $RedirectUri, $platformParameters)
}
$accessToken = $authResult.result.AccessToken
$apiUrl = 'https://graph.microsoft.com/beta/auditLogs/signIns?' + "`$filter=userPrincipalName eq " + "'" + $upn + "'"
if ($DateGTE) {
#$DateGTE = "2019-02-10"
$apiUrl = 'https://graph.microsoft.com/beta/auditLogs/signIns?' + "`$filter=userPrincipalName eq " + "'" + $upn + "'" + " and createdDateTime ge " + $DateGTE
}
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $apiUrl -Method Get
$PR = $Data.value

if ($getfailed) 
   {
    $PR | ? {$_.status.errorCode -ne 0} | select createdDateTime,userPrincipalName,appDisplayName,clientAppUsed,Status,ipAddress,conditionalAccessStatus,
    @{N="OS";E={$_.deviceDetail.operatingSystem}
    }
    } 
else {
$pr | select createdDateTime,userPrincipalName,appDisplayName,clientAppUsed,Status,ipAddress,conditionalAccessStatus,
@{N="OS";E={$_.deviceDetail.operatingSystem}}}
}
