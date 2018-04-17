$sessionData = Import-Clixml -LiteralPath 'D:\Backup\PSConfEU-Export.clixml'

class EuCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument (
        [String]$CommandName,
        [String]$ParameterName,
        [String]$WordToComplete,
        [System.Management.Automation.Language.CommandAst]$CommandAst,
        [System.Collections.IDictionary]$FakeBoundParameters
    ) {
        
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
        
        return [System.Management.Automation.CompletionResult[]]@( 
            Get-ConfEUSession @splat | 
                Where-Object $ParameterName -Like "$WordToComplete*" | 
                ForEach-Object $ParameterName |
                ForEach-Object {
                    $this.NewResult($_)
                }
        )
    }

    [System.Management.Automation.CompletionResult] NewResult (
        [String]$CompletionText
    ) {
        $tokens = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput(
            "echo $CompletionText", 
            [ref]$tokens, 
            [ref]$null
        )
        if (
            $tokens.Length -ne 3 -or
            (
                $tokens[1] -is [System.Management.Automation.Language.StringExpandableToken] -and
                $tokens[1].Kind -eq [System.Management.Automation.Language.TokenKind]::Generic
            )
        ) {
            $CompletionText = "'$CompletionText'"
        }

        return [System.Management.Automation.CompletionResult]::new($CompletionText)
    }
}


function Get-ConfEUSession {
    param (
        [ArgumentCompleter([EuCompleter])]
        [String]$Speaker = '*',
        [ArgumentCompleter([EuCompleter])]
        [String]$Title = '*',
        [String]$Abstract = '*'
    )

    $sessionData.Where{
        $_.Speaker -like $Speaker -and
        $_.Title -like $Title -and
        $_.Abstract -like $Abstract
    }
}