$sessionData = Import-Clixml -LiteralPath 'D:\Backup\PSConfEU-Export.clixml'

function Get-ConfEUSession {
    param (
        [String]$Speaker = '*',
        [String]$Title = '*',
        [String]$Abstract = '*'
    )
    $sessionData.Where{
        $_.Speaker -like $Speaker -and
        $_.Title -like $Title -and
        $_.Abstract -like $Abstract
    }
}