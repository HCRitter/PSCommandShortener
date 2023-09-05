# PSCommandShortener
Shortens and simplifies a PowerShell script block by replacing command names with aliases and using shortest parameter aliases.

### The Invoke-CommandShortener function takes a PowerShell script block as input and performs the following tasks:
    
    1. Splits the input script block into individual lines, removing empty lines and delimiters.
    2. Identifies command delimiters in the input script block.
    3. Parses the input script block into an Abstract Syntax Tree (AST).
    4. Extract a list of command elements and their associated parameters from the AST.
    5. Creates a list of command information, including aliases and parameters.
    6. Replaces command names with their aliases and parameter names with their shortest aliases.
    7. Returns the modified script block.

### Planned improvements:

  1. Checking for implied Get- if there is no alias for a specific command - If a command has a 'get' verb then you could ignore it and the command will work very the same way 
```powershell
Get-Childitem -Path "C:\Temp\"
# is the same like:
Childitem -Path "C:\Temp\"
```
  2. Shortest Unique Parameter Match: I aim to identify the shortest, unique match for a parameter when no alias is defined. This will help ensure that the shortened parameter is unique within the command.
```PowerShell
Get-Childitem -Path "C:\Temp\"
# would become:
Get-Childitem -Pa "C:\Temp\"
# This wont work:
Get-Childitem -P "C:\Temp\"
# because -PiplineVariable is also a parameter and the shortened one needs to be unique
```

### Intentions Behind the Script
The PSCommandShortener script was created with the intention of simplifying and optimizing PowerShell script blocks, particularly for Code-Golf enthusiasts. This tool aims to assist users in finding the shortest and most efficient way to construct PowerShell commands, making the coding experience more enjoyable and productive.

Feel free to contribute to this project, suggest improvements, or report any issues you encounter. I welcome community involvement in making PowerShell scripting more efficient and fun!
