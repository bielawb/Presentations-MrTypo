#region DPS
throw "Hey, Dory! Forgot to use F8?"
#endregion

#region Script block parameters
function Test-Completer {
    param (
        [String]$Parameter,
        [String]$Other
    )
}

Register-ArgumentCompleter -CommandName Test-Completer -ParameterName Parameter -ScriptBlock {
    $args -join ',' | Set-Content -LiteralPath C:\temp\Arguments.txt
    $args[-1] | ConvertTo-Json | Set-Content -LiteralPath C:\temp\LastArgument.json
}

Register-ArgumentCompleter -CommandName Test-Completer -ParameterName Other -ScriptBlock {
    @{
        CommandName = $args[0]
        Parameter = $args[1]
        WordToComplete = $args[2]
        CommandAst = $args[3]
        FakeBoundParameters = $args[4]
    } | ConvertTo-Json | Set-Content -LiteralPath C:\temp\AllArguments.json
}

Test-Completer -OtherParameter SomeValue -Parameter WordTo
Get-Content C:\temp\Arguments.txt
Get-Content C:\temp\LastArgument.json | ConvertFrom-Json
Get-Content C:\temp\AllArguments.json | ConvertFrom-Json

#endregion

#region Generating completers
# All classes in SMA!
[Management.Automation.CompletionCompleters] | Get-Member -Static
[Management.Automation.CompletionCompleters]::CompleteFilename('*.ps1')
[Management.Automation.CompletionCompleters]::CompleteType('ping')

# Custom - most of the time...
[Management.Automation.CompletionResult]::new

[Management.Automation.CompletionResult]::new(
    'Completion',
    'TextInTheList (usually the same)',
    [Management.Automation.CompletionResultType]::History,
    'Tool tip (some long text that is visible only when intellisense is used)'
)

# ... or ...
[Management.Automation.CompletionResult]::new('Text')
#endregion

#region Basic example
$script = {
    $wordToComplete = $args[2]
    (Get-WinEvent -ListLog "$wordToComplete*").foreach{
        [Management.Automation.CompletionResult]::new($_.LogName)
    }
}

Register-ArgumentCompleter -CommandName Get-WinEvent -ParameterName LogName -ScriptBlock $script
Get-WinEvent *DSC*
Get-WinEvent *User*Experience

# Solution... 
Start-Process 'https://github.com/lzybkr/TabExpansionPlusPlus/blob/master/TabExpansionPlusPlus.psm1#L33-L85'
. .\CompletionResult.ps1

$script = {
    $wordToComplete = $args[2]
    (Get-WinEvent -ListLog "$wordToComplete*").foreach{
        New-CompletionResult $_.LogName
    }
}
Register-ArgumentCompleter -CommandName Get-WinEvent -ParameterName LogName -ScriptBlock $script
Get-WinEvent *DSC*
Get-WinEvent *User*Experience


#endregion

#region Advanced - fakeBound

#endregion
