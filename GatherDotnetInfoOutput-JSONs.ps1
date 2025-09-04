# Set root directory to scan
$RootPath = "C:"
$outputFile = "C:\GatherDotnetInfoOutput-JSONs.csv"
# if output file already exists, remove it to avoid appending to old data
if (Test-Path -Path $outputFile) {
    Remove-Item -Path $outputFile
}

<#
# Add this before your existing Get-ChildItem line to test the search
Write-Host "Searching for .NET JSON files in: $RootPath"
Write-Host "Testing search patterns individually..."

# Test each pattern separately
$runtimeConfigs = Get-ChildItem -Path $RootPath -Recurse -Include "*runtimeconfig.json" -ErrorAction SilentlyContinue
$depsFiles = Get-ChildItem -Path $RootPath -Recurse -Include "*deps.json" -ErrorAction SilentlyContinue  
$appSettings = Get-ChildItem -Path $RootPath -Recurse -Include "appsettings.json" -ErrorAction SilentlyContinue

Write-Host "Found $($runtimeConfigs.Count) *runtimeconfig.json files"
Write-Host "Found $($depsFiles.Count) *deps.json files"
Write-Host "Found $($appSettings.Count) appsettings.json files"
#>

# Find relevant JSON files
$JsonFiles = Get-ChildItem -Path $RootPath -Recurse -Include *runtimeconfig.json,*deps.json,*appsettings.json

Add-Content -Path $outputFile -Value "FullPath,File,FrameworkName,FrameworkVersion"

foreach ($JsonFile in $JsonFiles) {
    Write-Host "`nScanning file: $($JsonFile.FullName)"

    try {
        $JsonContent = Get-Content $JsonFile.FullName -Raw | ConvertFrom-Json
    } catch {
        Write-Warning "Could not parse JSON: $($JsonFile.FullName)"
        continue
    }

    # Check if the json file name contains runtimeconfig.json
    if ($JsonFile.Name -like "*runtimeconfig.json") {
        if ($JsonContent.runtimeOptions.framework) {
            $FrameworkName = $JsonContent.runtimeOptions.framework.name
            $FrameworkVersion = $JsonContent.runtimeOptions.framework.version
            # Output the framework name and version found in runtimeconfig.json to $outputFile
            Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),$FrameworkName,$FrameworkVersion"
            #SWrite-Host "runtimeconfig.json: Framework = $FrameworkName, Version = $FrameworkVersion"
        }
        elseif ($JsonContent.runtimeOptions.tfm) {
            Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),TFM,$($JsonContent.runtimeOptions.tfm)"
            #Write-Host "runtimeconfig.json: Target Framework Moniker = $($JsonContent.runtimeOptions.tfm)"
        }
    }

    # Check deps.json - look for target framework
    elseif ($JsonFile.Name -like "*deps.json") {
        if ($JsonContent.runtimeTarget.framework) {
            Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),$($JsonContent.runtimeTarget.framework)"
            #Write-Host "deps.json: Framework = $($JsonContent.runtimeTarget.framework)"
        }
        if ($JsonContent.targets) {
            $FrameworkKeys = $JsonContent.targets.PSObject.Properties.Name
            foreach ($key in $FrameworkKeys) {
                Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),$key"
                #Write-Host "deps.json: Target = $key"
            }
        }
    }

    # Check appsettings.json (rare, but sometimes a custom field is used)
    elseif ($JsonFile.Name -like "*appsettings.json") {
        # Example: Some custom uses may specify .NET version/target framework
        if ($JsonContent.DotNetVersion) {
            Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),DotNetVersion,$($JsonContent.DotNetVersion)"
            #Write-Host "appsettings.json: DotNetVersion = $($JsonContent.DotNetVersion)"
        }
        elseif ($JsonContent.FrameworkVersion) {
            Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),FrameworkVersion,$($JsonContent.FrameworkVersion)"
            #Write-Host "appsettings.json: FrameworkVersion = $($JsonContent.FrameworkVersion)"
        }
        else
        {
            Add-Content -Path $outputFile -Value "$($JsonFile.FullName),$($JsonFile.Name),None,Not Found"
            Write-Host "appsettings.json: No relevant .NET version information found."
        }
    }
}

 # open the output file for review
 Invoke-Item -Path $outputFile

