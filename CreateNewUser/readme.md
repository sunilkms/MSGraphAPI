## Setup New user using Graph API using powershell
#### This script shows an example of issuing POST request in REST method to O365 graph API

### Script Requirements

* Make sure you have setup an Azure APP and have added "User.ReadWrite.All, Directory.ReadWrite.All" Rights
* Replace your Graph app info app ID and service account info in the script
* Service account should have at list "User management administrator" role.

#### Import script as module, or dot source it to use the function and run as below.

**Example:** 
* ```Import-Module .\setupuser.ps1``` 'OR' ```. .\setupuser.ps1```
* ```NewUser-GraphAPI -DisplayName "Test User 01" -Alias "tu01" -password "Pa55w0rd"```
