# UpdateUser-GraphAPI

## This function demonstrate how to updates user account properties using the Graph API.

#### Following are the all the available attributes which can be update using this script

```powershell
-----------------------------------------------------------------------------------------------
$aboutMe,$accountEnabled,$birthday,$city,$country,$department,$displayName,
$givenName,$hireDate,$interests,$jobTitle,$mailNickname,$mobilePhone,
$mySite,$officeLocation,$onPremisesImmutableId,$passwordPolicies,$passwordProfile,$pastProjects,
$postalCode,$preferredLanguage,$responsibilities,$schools,$skills,$state,$streetAddress,
$surname,$usageLocation,$userPrincipalName,$userType
------------------------------------------------------------------------------------------------
```
#### More details on the usage of these attribute can be found [here](https://docs.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0).

### This script foucuses on the below attributes only
*Attibute from the list above can be included in the JSON to update the user* 
```powershell
-----------------------------------------------------------------------------------------------
$upn= "tu01@domain.com",
$givenName = "Test",
$surname = "User",
$city = "Noida",
$country = "IN",
$department = "IT",
$jobTitle = "System Admin",
$mobilePhone = "999999999",
$officeLocation = "Sector 126"
-----------------------------------------------------------------------------------------------
```
### Requirements:

* Make sure the **GetAccessToken** Script is Already imported to the session
* Module can be found in the **'MSGraphAPI Directory'**

### Example Run:
```powershell
UpdateUser-GraphAPI -upn tu02@domain.com -department Sales -jobTitle "Sales Manager" -mobilePhone 99999999
```
