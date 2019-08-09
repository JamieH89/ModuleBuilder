function ResolveModuleManifest {
    <#
        .SYNOPSIS
            Finds the Module.psd1 manifest,
        .DESCRIPTION
            Normalizes a relative or absolute path to a folder or build.psd1,
            and returns the full FileSystem path to the manifest file, if it exists.

    #>
    [CmdletBinding()]
    param(
        # The path to the folder where the Build manifest was found
        [string]$WorkingDirectory = $(Get-Location -PSProvider FileSystem),

        # The path where we expect to find the ModuleManifest
        [string]$ModuleManifest
    )
    Write-Debug "ResolveModuleManifest $WorkingDirectory \ $ModuleManifest"

    # Resolve Module manifest if not defined in Build.psd1
    if (-Not $ModuleManifest) {
        $ModuleName = Split-Path -Leaf $WorkingDirectory

        # If we're in a "well known" source folder, look higher for a name
        if ($ModuleName -in 'Source', 'src') {
            $ModuleName = Split-Path (Split-Path -Parent $WorkingDirectory) -Leaf
        }

        # As the Build Manifest did not specify the Module manifest, we expect the Module manifest in same folder
        $ModuleManifest = Join-Path $WorkingDirectory "$ModuleName.psd1"
    }

    # Make sure the Path is set and points at the actual manifest, relative to Build.psd1 or absolute
    if(!(Split-Path -IsAbsolute $ModuleManifest)) {
        $ModuleManifest = Join-Path $WorkingDirectory $ModuleManifest
    }

    if (!(Test-Path $ModuleManifest)) {
        throw "Can't find module manifest at $($ModuleManifest)"
    }

    $ModuleManifest
}
