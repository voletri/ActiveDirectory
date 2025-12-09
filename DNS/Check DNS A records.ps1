# Import the required modules
Import-Module ../Library/DNS.psm1
Import-Module ../Library/Excel.psm1

# Get the IP pattern from the user
$ipPattern = Read-Host "Enter the IP pattern to search for (e.g., 10.100.1.*)"

# Get the DNS A records
$dnsRecords = Get-DnsARecords -IPPattern $ipPattern

# Prepare the data for the Excel report
$data = @()
foreach ($record in $dnsRecords) {
    if ($record.Timestamp -gt 0) {
        $ft = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1601 00:00').AddHours($record.Timestamp))
        $t = Get-Date $ft -Format dd-MMM-yyyy
    }
    else {
        $t = $record.TimeStamp
    }
    $data += ,@($record.ownername, $record.IPaddress, $t)
}

# Define the headers for the Excel report
$headers = @("Server Name", "IP", "TimeStamp")

# Create the Excel report
New-ExcelReport -WorksheetName "DNS_A_Records" -Headers $headers -Data $data
