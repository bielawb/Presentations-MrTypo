#region DPS
throw "Hey, Dory! Forgot to use F8?"
#endregion

#region Information - MSDN
Start-Process http://bit.ly/IArgComp

<#
public System.Collections.Generic.IEnumerable<System.Management.Automation.CompletionResult> CompleteArgument (string commandName, string parameterName, string wordToComplete, System.Management.Automation.Language.CommandAst commandAst, System.Collections.IDictionary fakeBoundParameters);
#>

#endregion

#region Definition

class EuCompleter : System.Management.Automation.IArgumentCompleter {
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] CompleteArgument (
        [String]$CommandName,
        [String]$ParameterName,
        [String]$WordToComplete,
        [System.Management.Automation.Language.CommandAst]$CommandAst,
        [System.Collections.IDictionary]$FakeBoundParameters
    ) {
        
        $results = [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]]::new()
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
                $null = $results.Add((New-CompletionResult -CompletionText $_))
            }
        return $results
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

    # Implementation...
}

#endregion

Import-Module -Name $pwd\PSConfEU-Class.psm1