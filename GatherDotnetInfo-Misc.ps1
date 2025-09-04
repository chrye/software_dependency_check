
# Gathering Installed Software Inventory

Get-CimInstance -Class Win32_Product | Select-Object Name, Version, Vendor
<# Sample output
Name                                                                          Version          Vendor
----                                                                          -------          ------
Python 3.12.10 Development Libraries (64-bit)                                 3.12.10150.0     Python Software Foundation
Azure Developer CLI                                                           1.18.300         Microsoft Corporation
Python 3.12.10 Add to Path (64-bit)                                           3.12.10150.0     Python Software Foundation
Python 3.12.10 pip Bootstrap (64-bit)                                         3.12.10150.0     Python Software Foundation
Python 3.12.10 Tcl/Tk Support (64-bit)                                        3.12.10150.0     Python Software Foundation
Office 16 Click-to-Run Extensibility Component                                16.0.19127.20154 Microsoft Corporation
Office 16 Click-to-Run Licensing Component                                    16.0.19029.20114 Microsoft Corporation
Microsoft.NET.Runtime.MonoTargets.Sdk (x64)                                   6.0.36.0         Microsoft Corporation
Microsoft.NETCore.App.Runtime.Mono.android-arm64 (x64)                        9.0.8.0          Microsoft Corporation
#>

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object DisplayName, DisplayVersion, Publisher
<# Sample output
DisplayName                                                                   DisplayVersion  Publisher
-----------                                                                   --------------  ---------
Visual Studio Build Tools 2019                                                16.11.50        Microsoft Corporation
Visual Studio Enterprise 2022                                                 17.14.12        Microsoft Corporation
IntelliJ IDEA 2025.1.3                                                        251.26927.53    JetBrains s.r.o.
IntelliJ IDEA 2025.1.4                                                        251.27812.12    JetBrains s.r.o.
IntelliJ IDEA 2025.1.4.1                                                      251.27812.49    JetBrains s.r.o.
Microsoft Edge                                                                139.0.3405.125  Microsoft Corporation
Microsoft Edge WebView2 Runtime                                               139.0.3405.125  Microsoft Corporation
Windows SDK for Windows Store Apps Libs                                       10.1.26100.4188 Microsoft Corporation
Windows SDK Facade Windows WinMD Versioned                                    10.1.26100.4188 Microsoft Corporation
#>


Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object DisplayName, DisplayVersion, Publisher
<# Sample output
DisplayName                                                         DisplayVersion   Publisher
-----------                                                         --------------   ---------
NVM for Windows 1.2.2                                               1.2.2            Author Software Inc.
Git                                                                 2.51.0           The Git Development Community
IntelliJ IDEA 2025.2                                                252.23892.409    JetBrains s.r.o.
IntelliJ IDEA 2025.2.1                                              252.25557.131    JetBrains s.r.o.
Microsoft Azure Compute Emulator - v2.9.7                           2.9.8999.43      Microsoft Corporation
Notepad++ (64-bit x64)                                              8.8.5            Notepad++ Team
Microsoft 365 Apps for enterprise - en-us                           16.0.19127.20192 Microsoft Corporation
Microsoft OneNote - en-us                                           16.0.19127.20192 Microsoft Corporation
#>

# For .NET Framework
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
    Get-ItemProperty -Name Version -EA 0 |
    Where { $_.Version -match '^\d' } |
    Select Version, PSChildName

# For .NET Core/5+/6+ (folder-based, check presence in system folders)
Get-ChildItem 'C:\Program Files\dotnet\shared\' -Recurse -Directory |
    Select-Object FullName

dotnet --info

function Get-DotNetDependency {
    param (
        [string]$Path
    )
    try {
        $peHeader = [System.Reflection.AssemblyName]::GetAssemblyName($Path)
        $peHeader.Version
    } catch {}
}

$outputPath = "C:\GatherDotnetInfoOutput-Misc.csv"
Get-ChildItem -Path "C:\Program Files" -Recurse -Include *.exe, *.dll | 
    ForEach-Object { 
        $version = Get-DotNetDependency -Path $_.FullName
        if ($version) {
            [PSCustomObject]@{ FullName = $_.FullName; Name = $_.Name; DotNetVersion = $version }
        }
    } | Export-Csv -Path $outputPath -NoTypeInformation

 # open the output file for review
 Invoke-Item -Path $outputPath