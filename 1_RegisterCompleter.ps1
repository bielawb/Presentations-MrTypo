#region DPS

throw "Hey, Dory! Forgot to use F8?"

#endregion

#region Built-in and installed from gallery

$PSVersionTable.PSVersion.Major -ge 5
Get-Command -Name Register-ArgumentCompleter -Module Microsoft.PowerShell.Core

Get-InstalledModule -Name TabExpansionPlusPlus 
Find-Module -Name TabExpansionPlusPlus | Install-Module -AllowClobber
Get-Command -Module TabExpansionPlusPlus
Get-ArgumentCompleter | Group-Object -Property Parameter | Sort-Object Count 

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
. (
    [scriptblock]::Create(
        'using namespace System.Management.Automation'
    )
)

[CompletionCompleters] | Get-Member -Static
[CompletionCompleters]::CompleteFilename('*.ps1')
[CompletionCompleters]::CompleteType('ping')

# Custom - most of the time...
[CompletionResult]::new

[CompletionResult]::new(
    'Completion',
    'TextInTheList (usually the same)',
    [CompletionResultType]::History,
    'Tool tip (some long text that is visible only when intellisense is used)'
)

    # ... or ...
[CompletionResult]::new('Text')

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

$argumentCompleterSplat = @{
    CommandName = 'Register-ArgumentCompleter'
    ParameterName = 'ParameterName'
    ScriptBlock = {
        param (
            $CommandName,    
            $Parameter,
            $WordToComplete,
            $CommandAst,
            $FakeBoundParameters
        )
        $splat = @{}
        if ($cmd = $FakeBoundParameters['CommandName']) {
            $splat['Name'] = $cmd
        }
    
        (Get-Command @splat).Parameters.Keys | 
            Where-Object { $_ -like "$WordToComplete*" } |
            Sort-Object -Unique |
            ForEach-Object {
                New-CompletionResult -CompletionText $_
            }
    }
}

Register-ArgumentCompleter @argumentCompleterSplat


$itemPropertyNameCompleter = {
    param (
        [String]$CommandName,
        [String]$ParameterName,
        [String]$WordToComplete,
        [Management.Automation.Language.CommandAst]$CommandAst,
        [hashtable]$FakeBoundParameter
    )

    $parameters = if ($FakeBoundParameter.Contains('Path')) {
        @{
            Path = $FakeBoundParameter['Path']
            Name = "$WordToComplete*"
        }
    } elseif ($FakeBoundParameter.Contains('LiteralPath')) {
        @{
            LiteralPath = $FakeBoundParameter['LiteralPath']
        }
    }

    (Get-ItemProperty @parameters).PSObject.Properties.Name.Where{ 
            $_ -like "$WordToComplete*" 
        }.ForEach{
            [Management.Automation.CompletionResult]::new($_)
        }
}

Register-ArgumentCompleter -CommandName @(
    'Get-ItemProperty'
    'Get-ItemPropertyValue'
    'Set-ItemProperty'
) -ParameterName Name -ScriptBlock $itemPropertyNameCompleter

Test-ArgumentCompleter -CommandName Get-ItemPropertyValue -ParameterName Name -FakeBoundParameters @{
    Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
} -WordToComplete Build

Register-ArgumentCompleter -CommandName Get-Verb -ParameterName Verb -ScriptBlock {
    $wordToComplete = $args[2]
    Get-Verb -verb "$wordToComplete*" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name)
    }
}

Get-Verb -verb A
#endregion

#region Examples from TabExpansionPlusPlus module

Get-ArgumentCompleter -Name Start-VM | Format-List -Property *
Get-ArgumentCompleter -Name Rename-LocalGroup | Format-List -Property *

Get-ArgumentCompleter | 
    ForEach-Object File | 
    Sort-Object -Unique | 
    Get-Item -Path { 
        Join-Path -Path (Get-Module TabExpansionPlusPlus).ModuleBase -ChildPath $_ 
    }
    
Get-VM -Name D						# I get the list of my VMs with name starting with 'D'
Rename-LocalGroup -Name A			# I get subset of local groups with name starting with 'A'

#endregion

#region useful commands in TabExpansionPlusPlus module
Test-ArgumentCompleter -CommandName Get-Verb -ParameterName Verb -WordToComplete A

#region fixed

Register-ArgumentCompleter -CommandName Get-Verb -ParameterName Verb -ScriptBlock {
    $wordToComplete = $args[2]
    Get-Verb -verb "$wordToComplete*" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Verb)
    }
}

Get-Verb -verb A

#endregion

Get-ArgumentCompleter -Name Get-Verb

#endregion