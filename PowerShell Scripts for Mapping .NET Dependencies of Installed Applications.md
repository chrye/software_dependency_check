# PowerShell Scripts for Mapping .NET Dependencies of Installed Applications

#### Quick Summary
>
> - No Built-in Tool – Community to the Rescue
> Microsoft has no native utility to list which installed apps depend on which .NET version. Sysadmins have filled the gap with PowerShell scripts that scan installed programs and identify their .NET Framework or .NET runtime requirements.
> 
> - File Scanning to Detect Dependencies
> Scripts typically work by scanning program installation folders for tell-tale .NET assembly files (e.g. `System*.dll`, `mscorlib.dll`) or manifest entries. By retrieving file version info of these assemblies, the script infers the .NET version required.
> 
> - Structured Output for Enterprise Use
> These scripts output results in a structured format (CSV or JSON), mapping each software to the .NET version it needs. This data can be aggregated across thousands of endpoints and analyzed centrally – essential for a large enterprise environment.
> 
> - Deployable via SCCM, Intune, Tanium
> You can run the script on all PCs using your management tools (ConfigMgr/SCCM, Intune, or platforms like Tanium) and collect the results automatically. No new agent is required – leverage existing infrastructure to execute the script on each machine and retrieve the inventory data.
