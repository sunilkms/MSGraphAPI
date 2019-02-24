# Setup New user using Graph API using powershell
# replace your Graph app info and service account info in the script
# Server account should have at list "User management administrator" rights.
# Import it as function and run as below.
# Example: NewUser-GraphAPI -DisplayName "Test User 01" -Alias "tu01" -password "Pa55w0rd"

Function NewUser-GraphAPI {
param (
$DisplayName="testuser6" ,
$Alias="testu6",
$password="Pa55w0rd"
)

#---------------Modify the below detials----------------
#Add Service Account and domain name details below
$Office365Username= 'svcga@domain.com'
$Office365Password='Pass' 
$domain="domain.com" # or
#$domain="domain.onmicrosoft.com"
#-------------------------------------------------------
$clientId = "8e5a2e83-aef4-4229-992f-262ec347ef1e"
$redirectUri = "https://localhost"
$resourceURI = "https://graph.microsoft.com"
$authority = "https://login.microsoftonline.com/common"
#-------------------------------------------------------

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
$accessToken = $authResult.result

# Prepare for POST, We need Header and the JASON BODY.
#header
$Header = @{
            'Content-Type'  = 'application\json'
            'Authorization' = $AccessToken.CreateAuthorizationHeader()
          }

#----Jason Construction--
$displayName="'" + $displayName + "'"
$mailNickname="'" + $alias + "'"
$UPN= "'" + $alias + '@' +$domain + "'"
$Method="POST"
$password = "'" + $password + "'"

$JASON=@"
{
  "accountEnabled": true,
  "displayName": $displayName,
  "mailNickname": $mailNickname ,
  "userPrincipalName":$UPN,
  "passwordProfile" : {
                        "forceChangePasswordNextSignIn": true,
                        "password":$password
                      }
  }
"@

#post to graph using rest method
$URI="https://graph.microsoft.com/v1.0/users"
$Results = Invoke-RestMethod -Headers $Header -Uri $Uri -Method POST -Body $JASON -ContentType "application/json”
}
