function GetModuleInfo {
    <#
        .SYNOPSIS
            Loads the module manifest
        .DESCRIPTION
            Wraps Get-Module to read the module information from the module manifest and handles errors
    #>
    [CmdletBinding()]
    param(
        # The Module.psd1 file
        [string]$ModuleManifest
    )
    Write-Debug "Importing ModuleInfo"

    # These errors are caused by trying to parse valid module manifests without compiling the module first
    $ErrorsWeIgnore = "^" + @(
        "Modules_InvalidRequiredModulesinModuleManifest"
        "Modules_InvalidRootModuleInModuleManifest"
    ) -join "|^"

    # Finally, add all the information in the module manifest to the return object
    $ModuleInfo = Get-Module (Get-Item $ModuleManifest).FullName -ListAvailable -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable Problems

    # If there are any problems that count, fail
    if ($Problems = $Problems.Where( {$_.FullyQualifiedErrorId -notmatch $ErrorsWeIgnore})) {
        foreach ($problem in $Problems) {
            Write-Error $problem
        }
        throw "Unresolvable problems in module manifest"
    }

    $ModuleInfo
}
