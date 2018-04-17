$sessionData = Import-Clixml -LiteralPath 'D:\Backup\PSConfEU-Export.clixml'

function New-CompletionResult
{
    param([Parameter(Position=0, ValueFromPipelineByPropertyName, Mandatory, ValueFromPipeline)]
          [ValidateNotNullOrEmpty()]
          [string]
          $CompletionText,

          [Parameter(Position=1, ValueFromPipelineByPropertyName)]
          [string]
          $ToolTip,

          [Parameter(Position=2, ValueFromPipelineByPropertyName)]
          [string]
          $ListItemText,

          [System.Management.Automation.CompletionResultType]
          $CompletionResultType = [System.Management.Automation.CompletionResultType]::ParameterValue,

          [Parameter(Mandatory = $false)]
          [switch] $NoQuotes = $false

          )

    process
    {
        $toolTipToUse = if ($ToolTip -eq '') { $CompletionText } else { $ToolTip }
        $listItemToUse = if ($ListItemText -eq '') { $CompletionText } else { $ListItemText }

        # If the caller explicitly requests that quotes
        # not be included, via the -NoQuotes parameter,
        # then skip adding quotes.

        if ($CompletionResultType -eq [System.Management.Automation.CompletionResultType]::ParameterValue -and -not $NoQuotes)
        {
            # Add single quotes for the caller in case they are needed.
            # We use the parser to robustly determine how it will treat
            # the argument.  If we end up with too many tokens, or if
            # the parser found something expandable in the results, we
            # know quotes are needed.

            $tokens = $null
            $null = [System.Management.Automation.Language.Parser]::ParseInput("echo $CompletionText", [ref]$tokens, [ref]$null)
            if ($tokens.Length -ne 3 -or
                ($tokens[1] -is [System.Management.Automation.Language.StringExpandableToken] -and
                 $tokens[1].Kind -eq [System.Management.Automation.Language.TokenKind]::Generic))
            {
                $CompletionText = "'$CompletionText'"
            }
        }
        return New-Object System.Management.Automation.CompletionResult `
            ($CompletionText,$listItemToUse,$CompletionResultType,$toolTipToUse.Trim())
    }

}

function Get-PropertyCompleter {
    param (
        [String]$CommandName,
        [String]$ParameterName,
        [String]$WordToComplete,
        [Management.Automation.Language.CommandAst]$CommandAst,
        [hashtable]$FakeBoundParameters
    )

    $splat = @{}

    switch ($ParameterName) {
        Speaker {
            if ($FakeBoundParameters.Contains('Title')) {
                $splat.Title = $FakeBoundParameters['Title']
            }
        }
        Title {
            if ($FakeBoundParameters.Contains('Speaker')) {
                $splat.Speaker = $FakeBoundParameters['Speaker']
            }        
        }
    }

    Get-ConfEUSession @splat | 
        Where-Object $ParameterName -Like "$WordToComplete*" | 
        ForEach-Object $ParameterName |
        ForEach-Object {
            New-CompletionResult -CompletionText $_
        }
}

function Get-ConfEUSession {
    param (
        [ArgumentCompleter(
            { Get-PropertyCompleter @args }
        )]
        [String]$Speaker = '*',
        [ArgumentCompleter(
            { Get-PropertyCompleter @args }
        )]
        [String]$Title = '*',
        [String]$Abstract = '*'
    )
    $sessionData.Where{
        $_.Speaker -like $Speaker -and
        $_.Title -like $Title -and
        $_.Abstract -like $Abstract
    }
}

Export-ModuleMember -Function *