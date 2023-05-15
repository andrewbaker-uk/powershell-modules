# PowerShell Modules

Different PowerShell Modules I've developed for use for home and my work

## IP Tools
### IP Checker

  ```powershell
  Import-Module IPChecker
  Get-OnlineDevices -IpRange "192.168.0.1-192.168.0.100"
  ```
This will load the module and execute the Get-OnlineDevices function with the specified IP range. The function will return an object with the online devices, offline devices, and offline devices with resolved DNS.
