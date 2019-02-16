# Get Office 365 User SignIn Logs Using Powershell Script
#### This script will get user sign in logs from Azure AD, import the script as module in powershell

## run examples
```sh
GetSignInLogs -upn sc@lab365.gq -DateGTE 2019-02-10 -getfailed
```
## parameters defination

* -upn: upn of the user you wish to fetch the signin logs
* -getfailed: is a switch, if used will skip the success logs
* -DateGTE: date greater than or equal to accept the YYYY-MM-DD format, if run without a dateGTE script will fetch all the available logs.

### If you do not know how to setup the Azure App and permissions check out my blogs serices on working wiht Graph API using powershell.

> https://www.sunilchauhan.info/2019/02/working-with-microsoft-graph-api-using.html
> https://www.sunilchauhan.info/2019/02/working-with-microsoft-graph-api-using_10.html
