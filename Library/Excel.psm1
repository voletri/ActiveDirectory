# In DNS/Check DNS A records.ps1, the Excel report is generated using the following code:
# $a = New-Object -comobject Excel.Application
# $a.visible = $True
# ...
# I will create a reusable function to generate an Excel report.

function New-ExcelReport {
    param(
        [string]$WorksheetName,
        [array]$Headers,
        [array]$Data
    )

    try {
        $excel = New-Object -ComObject Excel.Application
        $excel.Visible = $True
        $workbook = $excel.Workbooks.Add()
        $worksheet = $workbook.Worksheets.Item(1)
        $worksheet.Name = $WorksheetName

        for ($i = 0; $i -lt $Headers.Length; $i++) {
            $worksheet.Cells.Item(1, $i + 1) = $Headers[$i]
        }

        for ($i = 0; $i -lt $Data.Length; $i++) {
            $row = $Data[$i]
            for ($j = 0; $j -lt $row.Length; $j++) {
                $worksheet.Cells.Item($i + 2, $j + 1) = $row[$j]
            }
        }

        $worksheet.UsedRange.Interior.ColorIndex = 19
        $worksheet.UsedRange.Font.ColorIndex = 11
        $worksheet.UsedRange.Font.Bold = $True
        $worksheet.UsedRange.EntireColumn.AutoFit()

        return $workbook
    }
    catch {
        Write-Error "Failed to generate Excel report: $_"
        return $null
    }
}

Export-ModuleMember -Function New-ExcelReport
