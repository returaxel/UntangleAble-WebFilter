
<#
.DESCRIPTION
    - Input adlist to block -> Output Untangle AdBlock-App compatible json file, or fail miserably.
    - 
.PARAMETER OutFile
    - Path & name of exported file
.PARAMETER BlockListURL
    - URL of selected list (.txt)
.NOTES
    Version:        1
    Author:         returaxel
    Creation Date:  2021-06-20
.EXAMPLE
    .\untangleable-adblock.ps1 -OutFile C:\Temp\My.json -BlockListURL https://easylist.to/easylist/easylist.txt
    -
    - The following lists were converted and uploaded successfully 2021-06-20
        https://easylist.to/easylist/easylist.txt
#>

[CmdletBinding()]
param (
    [Parameter()][string]$OutFile = "$($ENV:OneDrive)\AdBlocker.json",
    [Parameter()][string]$BlockListURL = "https://easylist.to/easylist/easylist.txt"
)

# Don't show progress for download to save time
$ProgressPreference = 'SilentlyContinue'

# Class
class AdBlockerRow{
    [object]$blocked   = $true
    [object]$flagged   = $true
    [object]$string    = $null
    [object]$javaClass = "com.untangle.uvm.app.GenericRule"
    [object]$name      = $null
    [object]$description= $null
    [object]$readOnly  = $null
    [object]$id        = $null
    [object]$category  = $null
    [object]$enabled   = $true

    AdBlockerRow([string]$string)
    {
        $this.string = $string
    }
}

$RunTime = Measure-Command { # Measure run time

# Split rows to make iterable array
$BlockListArray = (Invoke-WebRequest $BlockListURL).Content -Split "`n"

# Build Json, skip comments (!) and blanks
[psobject]$UntangleAble = foreach ($row in $BlockListArray) {
    if ($row -notmatch '^\!' -and $row -ne '') {
        [AdBlockerRow]::New($row)
    }
}

} # End Measure
Write-Host "RunTime: $($RunTime.TotalSeconds)"

# Save to file
$UntangleAble | ConvertTo-Json | Set-Content $OutFile