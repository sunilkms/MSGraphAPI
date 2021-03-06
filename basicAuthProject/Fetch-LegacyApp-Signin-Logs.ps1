#-------------------------------------------------------------------------------------------------
# Author: Sunil Chauhan <sunilkms@gmail.com> "www.lab365.in"
# Script: Fetch-SignIn-Logs.ps1
#
# This script fetches the sign-in logs from office 365 using GRAPH API
# 
# Background: 
# This project has been developed in view of basic authentication deprication in the next year.
# script will list all the legacy authentication clients, you can select one client at a time,
# scirpt will provide 3 options to chose from for duration, last 24 hours, 7 days and 30 days.
# script will monitor the token age and will renew token in the last 5 min.
# 
# Requirement:
#            1) - AzureAd powershell module
#            2) - Admin account with 'Report Reader' role rights
#            3) - Register an app in azure and add require rights check my blog link
#                 for more details on this (https://www.lab365.in/p/graph-api.html)
# 
#---------------------------------------------------------------------------------------------------
param (        
        $Office365Username="admin@lab365.in",
        $Office365Password="myadminpassword",
        $clientId = "8e5a2e83-xxxx-xxxx-xxxx-262ec347xxxx" # replace with your client app ID
        )
""
""
Write-Host "--------------------" -NoNewline -ForegroundColor Cyan
Write-Host "www.lab365.in" -NoNewline -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Cyan -NoNewline
Write-Host "
 FETCH SIGN-IN LOGS USING GRAPH API - TYPE THE NUMBER TO CONT.
---------------------------------------------------------------" -ForegroundColor Cyan

Write-Host "
LEGACY AUTHENTICATION CLIENTS

      [1] - AutoDiscover
      [2] - Exchange ActiveSync
      [3] - Exchange Online PowerShell      
      [4] - Exchange Web Services      
      [5] - IMAP4
      [6] - MAPI Over HTTP
      [7] - Offline Address Book
      [8] - Other clients
      [9] - Outlook Anywhere (RPC over HTTP)
      [10]- POP3      
      [11]- Reporting Web Services
      [12]- Authenticated SMTP "
Write-Host "
----------------------------------------------------------------
   NOTE:Please write a single ClientApp number only." -NoNewline -ForegroundColor Cyan
Write-Host "
------" -NoNewline -ForegroundColor Cyan
Write-Host "(Developed By:Sunil Chauhan<sunilkms@gmail.com>)" -ForegroundColor Yellow -NoNewline
Write-Host "----------" -ForegroundColor Cyan
" "
$number=Read-Host "============"
$Clientapp=switch ($number) {

1 {"AutoDiscover"}
2 {"Exchange ActiveSync"}
3 {"Exchange Online PowerShell"}
4 {"Exchange Web Services"}
5 {"IMAP4"}
6 {"MAPI Over HTTP"}
7 {"Offline Address Book"}
8 {"Other clients"}
9 {"Outlook Anywhere (RPC over HTTP)"}
10 {"POP3"}
11 {"Reporting Web Services"}
12 {"Authenticated SMTP"}

}

if ($Clientapp -eq $null) {Write-Host "
 ------------------------------------------------------------------------------------------------------
 Opps!! it seems you typed an incorrect number as there is no ClientApp defined with number:$number
 Tip: Run the script again and type the number from the above list only.
 ------------------------------------------------------------------------------------------------------ 
 " -ForegroundColor Yellow
;break}

Write-Host "
----------------------------------------------------------------
                        Select Duration
----------------------------------------------------------------
           1 - Last 24 Hours
           2 - Last 07 Days
           3 - Last 30 Days
----------------------------------------------------------------
" -ForegroundColor Yellow

$duration=Read-Host "Type The Number:"
$DateGTE=switch ($duration){
1 {$d=(Get-Date).AddDays(-1);(Get-Date $d -Format yyyy-MM-dd)}
2 {$d=(Get-Date).AddDays(-7);(Get-Date $d -Format yyyy-MM-dd)}
3 {$d=(Get-Date).AddDays(-30);(Get-Date $d -Format yyyy-MM-dd)}
}

$exportFileName="Signin_Logs_" + $Clientapp.Replace(" ","_")+ "_" + $DateGTE + "_" + "to"  + "_" +(get-date -Format yyyy-MM-dd)  + ".csv"

Write-Host "Sign-in Logs starting from $DateGTE will be searched" -ForegroundColor Cyan
Write-Host "Sign-in Logs for " -NoNewline
Write-Host $clientApp -f Yellow -NoNewline
Write-Host " will be exported to " -NoNewline
Write-Host $exportFileName -F Yellow

Function GetAuthorizationToken {

$redirectUri = "https://localhost"
$resourceURI = "https://graph.microsoft.com"
$authority = "https://login.microsoftonline.com/common"
    
    try {
         #$AadModule=Import-Module -Name AzureADPreview -ErrorAction Stop -PassThru
         $AadModule=Import-Module -Name AzureAD -ErrorAction Stop -PassThru
        }
   catch{
         throw 'Prerequisites not installed (AzureAD PowerShell module not installed)'
        }
""
if ($Office365Username -and $Office365Password) {
Write-Host "Trying to fetch the auth token" -ForegroundColor Yellow -NoNewline
#Loading ADAL Library
$adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
[System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

$SecurePassword = ConvertTo-SecureString -AsPlainText $Office365Password -Force

#Build Azure AD credentials object
$AADCredential = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential" -ArgumentList $Office365Username,$SecurePassword

# Get token without login prompts.
$authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceURI, $clientid, $AADCredential);
} else {"Did not find the Admin Credentials, script will now try the MFA based auth"}

#if basic auth fails try MFA.

if (!$authResult.result) 
            {
            Write-Host " "
            Write-Host "Script failed while fetching authtoken using seemless method." -ForegroundColor Yellow
            Write-Host "Now trying to fetch authtoken using MFA" -ForegroundColor Yellow -NoNewline
            $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
            [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
            [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

            #Build Azure AD credentials object
            $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Always"
            $authResult=$authContext.AcquireTokenAsync($resourceURI, $ClientID, $RedirectUri, $platformParameters)
            }
sleep 2
if ($authResult.Status -eq "RanToCompletion"){Write-Host ":Succeeded" -ForegroundColor Green}else{Write-Host ":Failed" -ForegroundColor red}
$accessToken = $authResult
Return $accessToken
}

#Check if the auth token was previously exported.
$MinToExpire=(($authResult.result.ExpiresOn.LocalDateTime) - (get-date)).minutes
if ($authResult -eq $null -or $authResult.Status -ne "RanToCompletion" -or $MinToExpire -lt 5)
            {
             $Global:authResult=GetAuthorizationToken
            }
       else {
             Write-Host "A good token from the previous run is found in the powershell session," -NoNewline -ForegroundColor Green
             Write-Host " New Authtoken fetch request will be skipped." -ForegroundColor Green
            }

$accessToken=$authResult.result.AccessToken

if ($authResult.Status -ne "Faulted")
       { 
        Write-Host "Fetching the signin logs" -ForegroundColor cyan
        $Clientappq="clientAppUsed eq " + "'"  +  $Clientapp + "'"
        #$status=" and Status/errorcode eq " + "'"  +  "0" + "'"       
        $date = " and createdDateTime ge " + $DateGTE # 'YYYY-MM-DD'
        $quaryFilter=$Clientappq + $date    # + $status
        $apiUrl='https://graph.microsoft.com/beta/auditLogs/signIns?' + "`$filter=$quaryFilter"
        try   {
            $Data=Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $apiUrl -Method Get
            if ($data.value){
                            $data.value | select createdDateTime,userPrincipalName,appDisplayName,clientAppUsed,userAgent,conditionalAccessStatus,
                            @{N="operatingSystem";E={$_.deviceDetail.operatingSystem}},
                            @{N="browser";E={$_.deviceDetail.browser}},ipAddress,authenticationRequirement,
                            @{N="Status";E={$_.Status.errorCode}},
                            @{N="additionalDetails";E={$_.Status.additionalDetails}},
                            @{N="failureReason";E={$_.Status.failureReason}} |`
                            export-csv $exportFileName -NoTypeInformation -Append 
                           }
            }
        catch {               
               Write-Host "Failed to fetch the Sign-in logs, please review the error message below." -ForegroundColor Yellow
               #Write-host " "
               Write-Host ($error[0].ErrorDetails.message | ConvertFrom-Json).error.code
               Write-Host ($error[0].ErrorDetails.message | ConvertFrom-Json).error.message

               if (($error[0].ErrorDetails.message | ConvertFrom-Json).error.message -match "expired")
                    {
                     Write-Host "Token in psSession has expired,script will try renew the token please restart the script" -ForegroundColor Yellow
                     $Global:authResult=GetAuthorizationToken
                    } 
               else {
                     Write-Host "Please make sure the account " -NoNewline -ForegroundColor Yellow
                     Write-Host  $Office365Username -NoNewline -ForegroundColor Cyan
                     Write-Host  " has 'Report Reader' role rights." -ForegroundColor Yellow
                     break 
                    }
              }
       } 
else    {
         Write-host "Could not fetch the token.. breaking.."         
         Write-Host "Script faile due the following exception" -ForegroundColor Yellow
         $authResult.Exception.InnerException.Message
         ;break
        }

#go in loop if more than 1000 Logs were found.
if ($data."@odata.nextLink" -ne $null) 
           {
            do {
                #check the current auth token status.                
                $MinToExpire=(($authResult.result.ExpiresOn.LocalDateTime) - (get-date)).minutes
                Write-Host "AuthToken Age $MinToExpire Min " -NoNewline 
                if($MinToExpire -lt 5) {
                $Global:authResult=GetAuthorizationToken
                $accessToken=$authResult.result.AccessToken
                }

                #Fetch the next Odata Link
                
                $apiUrl=$data."@odata.nextLink"
                Write-host "Log Processed so far:" $apiUrl.split("_")[1]  -ForegroundColor Cyan              
                $Data=Invoke-RestMethod -Headers @{Authorization = "Bearer $accessToken"} -Uri $apiUrl -Method Get
                
                #Export to csv
                if ($data.value) 
                        {                           
                         $data.value | select createdDateTime,userPrincipalName,appDisplayName,clientAppUsed,userAgent,conditionalAccessStatus,
                         @{N="operatingSystem";E={$_.deviceDetail.operatingSystem}},
                         @{N="browser";E={$_.deviceDetail.browser}},ipAddress,authenticationRequirement,
                         @{N="Status";E={$_.Status.errorCode}},
                         @{N="additionalDetails";E={$_.Status.additionalDetails}},
                         @{N="failureReason";E={$_.Status.failureReason}} | `
                         export-csv $exportFileName -NoTypeInformation -Append
                        }                  
                } until ($data."@odata.nextLink" -eq $null)
                " "
                Write-Host "Sign-in Logs Export completed"
                Write-Host "logs has has been exported to path" $(($(Get-Location).path) + "\" + "$exportFileName") -f Green
            }
else       { 
             #Notification for less than 1K logs 
             if ($data)
                      {
                        Write-Host "Sign-in Logs Export completed"
                        Write-Host "logs has has been exported to path" $(($(Get-Location).path) + "\" + "$exportFileName") -f Green
                      }
           } 
