<#
This function demonstrate how to updates user account properties using the Graph API.

Following are the all the available attributes which can be update using this script
#--------------------------------------------------------------------------------------------
$aboutMe,$accountEnabled,$birthday,$city,$country,$department,$displayName,
$givenName,$hireDate,$interests,$jobTitle,$mailNickname,$mobilePhone,
$mySite,$officeLocation,$onPremisesImmutableId,$passwordPolicies,$passwordProfile,$pastProjects,
$postalCode,$preferredLanguage,$responsibilities,$schools,$skills,$state,$streetAddress,
$surname,$usageLocation,$userPrincipalName,$userType
**********************************************************************************************
Details can be found on the link below.
https://docs.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0
#----------------------------------------------------------------------------------------------

*** In this script I will be foucusing on the below attributes only
**** attibute from the list above can be included in the JSON to update the user 

$upn= "tu01@domain.com",
$givenName = "Test",
$surname = "User",
$city = "Noida",
$country = "IN",
$department = "IT",
$jobTitle = "System Admin",
$mobilePhone = "999999999",
$officeLocation = "Sector 126"

************************************
Requirements:
************************************

* Make sure the GetAccessToken Script is Already imported to the session
* Module can be found in the 'MSGraphAPI Directory'
#>
Function UpdateUser-GraphAPI {

param (
$upn= "tu01@Brocode.gq",
$givenName = "Test",
$surname = "User",
$city = "Noida",
$country = "IN",
$department = "IT",
$jobTitle = "System Admin",
$mobilePhone = "9818182354",
$officeLocation = "Sector 126"
)

# Get Access Token # Make sure the GetAccessToken Script is Already imported to the session
# Module can be found in the 'MSGraphAPI Directory'

$AccessToken = GetAccessToken

$Header=@{
            'Content-Type'  = 'application/json'
            'Authorization' = $AccessToken.CreateAuthorizationHeader()        
          }

#----Jason Construction--

$givenName = "'" + $givenName + "'"
$surname = "'" + $surname + "'"
$city = "'" + $city + "'"
$country = "'" + $country + "'"
$department = "'" + $department + "'"
$jobTitle = "'" + $jobTitle + "'"
$mobilePhone = "'" + $mobilePhone + "'"
$officeLocation = "'" + $officeLocation + "'"

$JSON=@"
{
    "givenName":$givenName,
    "surname":$surname,
    "city":$city,
    "country":$country,
    "department":$department,
    "jobTitle":$jobTitle,
    "officeLocation":$officeLocation,
    "mobilePhone":$mobilePhone
}
"@

#post to graph using rest method
$URI="https://graph.microsoft.com/v1.0/users/" + $upn
$Results = Invoke-RestMethod -Headers $Header -Uri $Uri -Method PATCH -Body $JSON

}
