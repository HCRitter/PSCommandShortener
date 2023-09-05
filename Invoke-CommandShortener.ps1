<#
.SYNOPSIS
    Shortens and simplifies a PowerShell script block by replacing command names with aliases and using shortest parameter aliases.

.DESCRIPTION
    The Invoke-CommandShortener function takes a PowerShell script block as input and performs the following tasks:
    
    1. Splits the input script block into individual lines, removing empty lines and delimiters.
    2. Identifies command delimiters in the input script block.
    3. Parses the input script block into an Abstract Syntax Tree (AST).
    4. Extracts a list of command elements and their associated parameters from the AST.
    5. Creates a list of command information, including aliases and parameters.
    6. Replaces command names with their aliases and parameter names with their shortest aliases.
    7. Returns the modified script block.

.PARAMETER InputScriptBlock
    Specifies the PowerShell script block that you want to shorten and simplify.

.EXAMPLE
    Invoke-CommandShortener -InputScriptBlock {Foreach-Object -Process {"Blub"} 
    Get-ChildItem -Path C:\Temp -Hidden;Cls }
    
        Output: 
        % -Process {"Blub"} 
        ls -Path C:\Temp -h;Cls
    

    # $shortenedScript will contain the modified script block with shortened command names and aliases.

.EXAMPLE
    Invoke-CommandShortener -InputScriptBlock {Get-Process | Where-Object { $_.CPU -gt 50 }}
    
        Output: 
        ps | ? { $_.CPU -gt 50 } 
    

    # $shortenedScript will contain the modified script block with shortened command names and aliases.
.NOTES
    File Name      : Invoke-CommandShortener.ps1
    Author         : Christian Ritter
    Prerequisite   : PowerShell v3.0
    version        : 0.1

.LINK
    Online version: https://github.com/HCRitter/PSCommandShortener

#>
function Invoke-CommandShortener {
    param (
        [scriptblock]$InputScriptBlock 
    )
    
    # Split the input script block into individual lines, removing empty lines and delimiters
    $ScriptblockText = New-Object -TypeName "System.Collections.ArrayList"
    $scriptBlockText.AddRange(@($InputScriptBlock.ToString().Trim() -split "(?<=;|`n|\|)" | ForEach-Object { $_ -replace "[;`n|]" } | Where-Object { $_ -match '\S' }))
    
    # Identify command delimiters in the input script block
    $commandDelimiters = $InputScriptBlock.ToString() | Select-String -Pattern "(\n|\||;)" -AllMatches | ForEach-Object { $_.Matches.Value }

    # Parse the input script block into an Abstract Syntax Tree (AST)
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($InputScriptBlock.ToString(), [ref]$null, [ref]$null)

    # Extract a list of command elements and their associated parameters from the AST
    $commandElementList = $ast.FindAll({$args[0].GetType().Name -like 'CommandAst'}, $true) | ForEach-Object {
        [pscustomobject]@{
            Cmdlet = $_.CommandElements[0].Value
            Parameters = $_.CommandElements.ParameterName
        }
    }
    
    # Create a list of command information, including aliases and parameters
    $list = foreach ($commandElementListItem in $commandElementList) {
        $command = Get-Command -Name $commandElementListItem.Cmdlet
        $commandAlias = $null
        
        # Determine if the command is an alias and resolve it if necessary
        switch ($command) {
            {$PSItem.Commandtype -eq "Alias"} {
                $commandAlias = $commandElementListItem.Cmdlet
                $command = Get-Command $PSItem.ResolvedCommand
            }
            Default {
                # Find the shortest alias for the command if it's not an alias itself
                try {
                    $commandAlias = ((Get-Alias -Definition $commandElementListItem.Cmdlet -ErrorAction Stop).DisplayName.ForEach({
                        $_.Split("-")[0]
                    })) | Sort-Object -Property Length | Select-Object -first 1
                }
                catch {
                    $commandAlias = $null
                }

            }
        }
        
        $parameters = [ordered]@{}
        
        # Match command parameters with their aliases and select the shortest alias
        foreach ($commandElementListItemParameterItem in $commandElementListItem.Parameters) {
            switch ((Get-Command $command.Name | Select-Object -ExpandProperty ParameterSets).Parameters) {
                {($commandElementListItemParameterItem -eq $PSItem.Alias) -or ($commandElementListItemParameterItem -eq $PSItem.Name)} {
                    $parameters[$PSitem.Name] = $($PSItem.Aliases  | Sort-Object -Property Length | Select-Object -first 1)
                }
            }
        }
        
        [PSCustomObject]@{
            CommandAlias = $commandAlias
            CommandName = $command.Name
            Parameters = $parameters
        }
    }
    
    # Initialize the final script block text
    $finalScriptBlockText = ""
    
    # Process each line of the script block
    for ($i = 0; $i -lt $scriptBlockText.Count; $i++) {
        
        # Replace command names with their aliases or implied 'Get-' if available
        switch -Wildcard ($list[$i].CommandName) {
            { -not [string]::IsNullOrEmpty($list[$i].CommandAlias) } {
                $scriptBlockText[$i] = $scriptBlockText[$i] -replace $list[$i].CommandName, $list[$i].CommandAlias
            }
            { $_ -like "Get-*" } {
                $scriptBlockText[$i] = $scriptBlockText[$i] -replace $list[$i].CommandName, ($_ -replace "Get-")
            }
        }
        
        # Replace parameter names with their shortest aliases
        $list[$i].Parameters.GetEnumerator() | Where-Object {
            -not [string]::IsNullOrEmpty($PSItem.Value)
        } | ForEach-Object {
            $scriptBlockText[$i] = $scriptBlockText[$i] -replace $PSItem.Key, $PSItem.Value
        }
        
        # Append the modified line to the final script block text
        $finalScriptBlockText += $scriptBlockText[$i]
        
        # Append the command delimiter if present
        if ($i -lt $commandDelimiters.Count) {
            $finalScriptBlockText += $commandDelimiters[$i]
        }
    }
    
    # Replace line breaks with CRLF and remove extra spaces
    $finalScriptBlockText = $finalScriptBlockText -replace '(?<!\r)\n', "`r`n" -replace ' {2,}', ' '

    # Create and return the modified script block
    return $([scriptblock]::Create($finalScriptBlockText))
}

Invoke-CommandShortener -InputScriptBlock {Get-ChildItem}