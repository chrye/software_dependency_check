cls
$outputPath = "C:\GatherDotnetInfoOutput-Joe.csv"
$targetDotNetVersion = "net6.0"

########################################################

#delete the output file if it already exists
if (Test-Path -Path $outputPath) {
    Remove-Item -Path $outputPath -Force
}   

echo "Gathering application information from runtimeconfig.json..."

$roots = @("C:\Program Files","C:\Program Files (x86)","$env:ProgramData","$env:LOCALAPPDATA")
# runtimeconfig.json with tfm = net6.0
Get-ChildItem -Path $roots -Filter *.runtimeconfig.json -Recurse -ErrorAction SilentlyContinue |
  ForEach-Object {
    try {
      $json = Get-Content $_.FullName -Raw | ConvertFrom-Json
      $tfm  = $json.runtimeOptions?.tfm
      if ($tfm -eq $targetDotNetVersion) {
        [PSCustomObject]@{ AppPath = Split-Path $_.FullName -Parent; File = $_.FullName; TFM = $tfm }         
      }
    } catch { }
  } | Export-Csv -Path $outputPath -Append -NoTypeInformation


echo "Gathering application information from deps.json..."

# deps.json containing "net6.0"
Get-ChildItem -Path $roots -Filter *.deps.json -Recurse -ErrorAction SilentlyContinue |
  Select-String -Pattern '"net6\.0"' -List |
  ForEach-Object {
    [PSCustomObject]@{ AppPath = Split-Path $_.Path -Parent; File = $_.Path; Match = $_.Matches.Value }
  } | Export-Csv -Path $outputPath -Append -NoTypeInformation


 
 Write-Output "Dependency information saved to $outputPath"
 
 # open the output file for review
 Invoke-Item -Path $outputPath
