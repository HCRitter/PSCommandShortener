# PSCommandShortener

Shortens and simplifies a PowerShell script block by replacing command names with aliases and using shortest parameter aliases.

## The Invoke-CommandShortener function takes a PowerShell script block as input and performs the following tasks

  1. Splits the input script block into individual lines, removing empty lines and delimiters.
  2. Identifies command delimiters in the input script block.
  3. Parses the input script block into an Abstract Syntax Tree (AST).
  4. Extracts a list of command elements and their associated parameters from the AST.
  5. Creates a list of command information, including aliases and parameters.
  6. Replaces command names with their aliases and parameter names with their shortest aliases or their shortest unique parameter match if no alias is available, including an implied 'Get-' test.
  7. Returns the modified script block.

## Planned improvements

 None, but open for good ideas :)

## Intentions Behind the Script

The PSCommandShortener script was created with the intention of simplifying and optimizing PowerShell script blocks, particularly for Code-Golf enthusiasts. This tool aims to assist users in finding the shortest and most efficient way to construct PowerShell commands, making the coding experience more enjoyable and productive.

Feel free to contribute to this project, suggest improvements, or report any issues you encounter. I welcome community involvement in making PowerShell scripting more efficient and fun!
