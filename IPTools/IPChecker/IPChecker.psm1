function Test-IpAddressInRange {
    param (
        [string]$IpAddress,
        [string]$FromAddress,
        [string]$ToAddress
    )

    $ip = [System.Net.IPAddress]::Parse($IpAddress).GetAddressBytes()
    [Array]::Reverse($ip)
    $ip = [System.BitConverter]::ToUInt32($ip, 0)

    $from = [System.Net.IPAddress]::Parse($FromAddress).GetAddressBytes()
    [Array]::Reverse($from)
    $from = [System.BitConverter]::ToUInt32($from, 0)

    $to = [System.Net.IPAddress]::Parse($ToAddress).GetAddressBytes()
    [Array]::Reverse($to)
    $to = [System.BitConverter]::ToUInt32($to, 0)

    $from -le $ip -and $ip -le $to
}

function Get-OnlineDevices {
    param (
        [string]$IpRange
    )

    $ipStart, $ipEnd = $IpRange -split '-'

    $commonPrefix = $ipStart.Substring(0, $ipStart.LastIndexOf('.') + 1)
    $lastSegmentStart = [int]$ipStart.Substring($ipStart.LastIndexOf('.') + 1)
    $lastSegmentEnd = [int]$ipEnd.Substring($ipEnd.LastIndexOf('.') + 1)

    $onlineDevices = @()
    $offlineDevices = @()
    $offlineDevicesWithDNS = @()

    $ipAddresses = $lastSegmentStart..$lastSegmentEnd | ForEach-Object {
        $commonPrefix + $_
    }

    foreach ($ipAddress in $ipAddresses) {
        if (Test-IpAddressInRange -IpAddress $ipAddress -FromAddress $ipStart -ToAddress $ipEnd) {
            $result = Test-Connection -ComputerName $ipAddress -Count 1 -Quiet -ErrorAction SilentlyContinue
            if ($result) {
                $onlineDevices += $ipAddress
                try {
                    $dnsEntry = [System.Net.Dns]::GetHostEntry($ipAddress)
                    if ($dnsEntry.HostName) {
                        Write-Output "$ipAddress - $($dnsEntry.HostName) is online and registered in DNS"
                    } else {
                        Write-Output "$ipAddress is online but not registered in DNS"
                    }
                } catch {
                    Write-Output "$ipAddress is online but not registered in DNS"
                }
            } else {
                try {
                    $dnsEntry = [System.Net.Dns]::GetHostEntry($ipAddress)
                    if ($dnsEntry.HostName) {
                        Write-Output "$ipAddress - $($dnsEntry.HostName) is offline and registered in DNS"
                        $offlineDevicesWithDNS += $ipAddress
                    } else {
                        Write-Output "$ipAddress is offline"
                    }
                } catch {
                    Write-Output "$ipAddress is offline"
                }
                $offlineDevices += $ipAddress
            }
        }
    }

    $output = @{
        OnlineDevices = $onlineDevices
        OfflineDevices = $offlineDevices
        OfflineDevicesWithDNS = $offlineDevicesWithDNS
    }
    
    Write-Output $output
}    
