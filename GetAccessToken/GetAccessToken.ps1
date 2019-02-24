# This function will get the Access token for Graph API Call
# You must have AzureAD modue installed and AzureApp configured and permission setup for the account and as well for the app.
# Import this as module or dot source it.
# Example : import-module getaccesstoken.ps1 or . .\GetAccessToken.ps1
# $AccessToken = GetAccessToken

Function GetAccessToken {

#---------------Modify the below detials----------------
#Add Service Account and domain name details below
$Office365Username='svcga@domain.com'
$Office365Password='Pass'
$clientId = "8e5a2e83-aef4-4229-992f-262ec347ef1e"
#-------------------------------------------------------
$redirectUri = "https://localhost"
$resourceURI = "https://graph.microsoft.com"
$authority = "https://login.microsoftonline.com/common"
#-------------------------------------------------------

#Import AzureAd powershell Module
try {
     $AadModule = Import-Module -Name AzureAD -ErrorAction Stop -PassThru
    }
     catch {
            throw 'Prerequisites not installed (AzureAD PowerShell module not installed)'
           }

#Load ADAL DLLs
$adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
[System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

##option without user interaction
if (([string]::IsNullOrEmpty($Office365Username) -eq $false) -and`
   ([string]::IsNullOrEmpty($Office365Password) -eq $false))
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
$authResult.result
}
