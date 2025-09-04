
GatherDotnetInfoOutput-JSONs.ps1
=================================
This script loops through the root directory $RootPath that you define, looking for all *runtimeconfig.json, *deps.json, *appsettings.json files.
Then it extracts .NET Framework version or .NET Core versions from framework/tfm tag.


GatherDotnetInfo-QuynnBell.ps1
=================================
This script does everything from https://quynnbell.com/identify-net-and-visual-c-dependencies-using-powershell/. 
Some loggings are added to match the format as produced by GatherDotnetInfoOutput-JSONs.ps1 for consistency.

This script loops through the root directory $RootPath that you define, checking all EXEs and DLLs to pull the version info. 
WARNING: this script does run a long time and heavy CPU consumption.


GatherDotnetInfo-Misc.ps1
===========================
This script is meant for references.

It contains various Powershell commands, from gathering installed software inventory to query registry on installed item properties, 
as well as check registry for installed .NET SDK versions.

WARNING: this script is NOT really meant to be run as whole. 
