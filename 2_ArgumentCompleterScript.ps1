#region DPS

throw "Hey, Dory! Forgot to use F8?"

#endregion

#region Any version of PowerShell

New-Module -Name FakeModule {
    function Test-Foo {
        param (
            [String]$Bar
        )
    }

    if (Get-Command -Name Register-ArgumentCompleter -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -CommandName Test-Foo -ParameterName Bar -ScriptBlock {
            $wordToComplete = $args[2]
            'One', 'Two', 'Three' | 
                Where-Object {
                    $_ -like "$wordToComplete*"
                } |
                ForEach-Object {
                    [Management.Automation.CompletionResult]::new($_)
                }
        }
    }
}


#endregion

#region Version 5+

#region Script block in ArgumentCompleter
function Get-Foo {
    param (
        [ArgumentCompleter(
            {
                $wordToComplete = $args[2]
                'One', 'Two', 'Three' | 
                    Where-Object {
                        $_ -like "$wordToComplete*"
                    } |
                    ForEach-Object {
                        [Management.Automation.CompletionResult]::new($_)
                    }
            }
        )]
        [String]$Bar
    )
    "$Bar"
}

#endregion

#region Function shared between commands

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

    # Implementation...
}


#endregion

#region functions in the module

Import-Module "$($psISE.CurrentFile.FullPath)\..\PSConfEU.psm1"
Import-Module "$($psISE.CurrentFile.FullPath)\..\PSConfEU-Tab.psm1" -Force
psEdit $PSScriptRoot\*.psm1

#endregion

#endregion