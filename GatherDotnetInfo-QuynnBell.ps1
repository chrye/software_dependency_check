#
# Program Name: .NET and Visual C++ Determinier
#
# Description: This will look through all installed applications and tell you which app requires which version of .NET and Visual C++.
#              Output will be displayed through the terminal and written to a CSV file ("C:\ProgramDependencies.csv")
#
# Author: Quynn Bell
#
# Date Modified: 23rd of May 2024
#

# Function to get installed programs
function Get-InstalledPrograms {
    $programs = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
                Select-Object DisplayName, DisplayVersion, InstallDate, Publisher, InstallLocation

    $programs += Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
                 Select-Object DisplayName, DisplayVersion, InstallDate, Publisher, InstallLocation

    $programs | Where-Object { $_.DisplayName } | Sort-Object DisplayName
}

# Function to search for dependencies in program files
function Get-ProgramDependencies {
    param(
        [string]$installLocation,
        [string[]]$patterns
    )
    $dependencies = @()
    foreach ($pattern in $patterns) {
        $dependencies += Get-ChildItem -Path $installLocation -Recurse -Filter $pattern -ErrorAction SilentlyContinue
    }
    $dependencies
}

# Function to get installed .NET versions
function Get-DotNetVersion {
    param(
        [string]$filePath
    )
    try {
        $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filePath)
        return $versionInfo.ProductVersion
    } catch {
        return $null
    }
}

cls

# Get installed programs
$installedPrograms = Get-InstalledPrograms

# Define patterns for common .NET and Visual C++ dependencies
$dotNetPatterns = @("System.*.dll", "mscorlib.dll")
$vcppPatterns = @("msvcp*.dll", "msvcr*.dll", "vccorlib*.dll", "vcomp*.dll", "vcruntime*.dll")

# Collect dependency information
$dependencyInfo = @()

foreach ($program in $installedPrograms) {
    if ($program.InstallLocation) {
        # Check for .NET dependencies
        $dotNetDependencies = Get-ProgramDependencies -installLocation $program.InstallLocation -patterns $dotNetPatterns
        foreach ($dependency in $dotNetDependencies) {
            $dotNetVersion = Get-DotNetVersion -filePath $dependency.FullName
            if ($dotNetVersion) {
                $dependencyInfo += [PSCustomObject]@{
                    Program       = $program.DisplayName
                    Version       = $program.DisplayVersion
                    Dependency    = $dependency.Name
                    DependencyType = "DotNet"
                    DependencyVersion = $dotNetVersion
                }
            }
        }
        
        # Check for Visual C++ dependencies
        $vcppDependencies = Get-ProgramDependencies -installLocation $program.InstallLocation -patterns $vcppPatterns
        foreach ($dependency in $vcppDependencies) {
            $vcppVersion = Get-DotNetVersion -filePath $dependency.FullName  # Using same function to get version
            if ($vcppVersion) {
                $dependencyInfo += [PSCustomObject]@{
                    Program       = $program.DisplayName
                    Version       = $program.DisplayVersion
                    Dependency    = $dependency.Name
                    DependencyType = "VisualCpp"
                    DependencyVersion = $vcppVersion
                }
            }
        }
    }
}

# Output the dependency information
$dependencyInfo | Format-Table -AutoSize

# Save to a CSV file for easier visualization
$outputPath = "C:\GatherDotnetInfoOutput-QuynnBell.csv"
if (Test-Path -Path $outputFile) {
    Remove-Item -Path $outputFile
}

$dependencyInfo | Export-Csv -Path $outputPath -NoTypeInformation

Write-Output "Dependency information saved to $outputPath"

 # open the output file for review
 Invoke-Item -Path $outputPath
