Describe 'Testing MrTypo presentation' {
    foreach ($script in Get-ChildItem -Path *.ps1) {
        Context "Testing $($script.Name)" {
            $syntaxErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                $script.FullName,
                [ref]$null,
                [ref]$syntaxErrors
            )
            
            It 'Script is syntax-error free' {
                $syntaxErrors.Message -join '; ' | Should BeNullOrEmpty
            }
            
            if ($script.Name -match '^\d+_') {
                It 'Demo script starts with a throw to prevent accidental F5' {
                    $ast.EndBlock.Statements[0] | Should BeOfType System.Management.Automation.Language.ThrowStatementAst
                }
            }
            $startRegion = $endRegion = 0
            switch -Wildcard -File $script.FullName {
                '#region *' {
                    $startRegion++
                }
                '#endregion' {
                    $endRegion++
                }
            }
            It 'All regions in the script are closed by matching endregion' {
                $startRegion | Should Be $endRegion
            }
        }    
    }
}
