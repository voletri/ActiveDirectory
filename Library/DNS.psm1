# In DNS/Check DNS A records.ps1, the DNS query is performed using the following code:
# $dns = gwmi -Namespace root\MicrosoftDNS -Class MicrosoftDNS_AType -ComputerName adc
# I will create a reusable function to query DNS.

function Get-DnsARecords {
    param(
        [string]$ComputerName = "adc",
        [string]$IPPattern
    )

    try {
        $dns = Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_AType -ComputerName $ComputerName
        return $dns | Where-Object { $_.IPAddress -like $IPPattern }
    }
    catch {
        Write-Error "Failed to query DNS: $_"
        return $null
    }
}

Export-ModuleMember -Function Get-DnsARecords
