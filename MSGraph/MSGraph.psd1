﻿@{
    # Script module or binary module file associated with this manifest
    ModuleToProcess = 'MSGraph.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.2.2'
    
    # ID used to uniquely identify this module
    GUID = '5f61c229-95d0-4423-ab50-938c0723ad21'
    
    # Author of this module
    Author = 'Friedrich Weinmann, Andreas Bellstedt'
    
    # Company or vendor of this module
    CompanyName = ''
    
    # Copyright statement for this module
    Copyright = 'Copyright (c) 2018 Friedrich Weinmann, Andreas Bellstedt'
    
    # Description of the functionality provided by this module
    Description = 'Tools for interacting with the Microsoft Graph Api'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'
    
    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of the .NET Framework required by this module
    # DotNetFrameworkVersion = '2.0'
    
    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = '2.0.50727'
    
    # Processor architecture (None, X86, Amd64, IA64) required by this module
    # ProcessorArchitecture = 'None'
    
    # Modules that must be imported into the global environment prior to importing
    # this module
    RequiredModules = @(
        @{ ModuleName='PSFramework'; ModuleVersion= '0.9.25.107' }
    )
    
    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @('bin\MSGraph.dll')
    
    # Script files (.ps1) that are run in the caller's environment prior to
    # importing this module
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @('xml\MSGraph.Types.ps1xml')
    
    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @('xml\MSGraph.Format.ps1xml')
    
    # Modules to import as nested modules of the module specified in
    # ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Get-MgaMailFolder',
        'Get-MgaMailMessage',
        'Get-MgaMailAttachment',
        'Export-MgaMailAttachment',
        'Update-MgaMailMessage',

        'Invoke-MgaGetMethod',
        'New-MgaAccessToken',
        'Update-MgaAccessToken',
        'Get-MgaRegisteredAccessToken',
        'Register-MgaAccessToken'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport = ''
    
    # Variables to export from this module
    VariablesToExport = ''
    
    # Aliases to export from this module
    AliasesToExport = @(
        'Save-MgaMailAttachment'
    )
    
    # List of all modules packaged with this module
    ModuleList = @()
    
    # List of all files packaged with this module
    FileList = @()
    
    # Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        
        #Support for PowerShellGet galleries.
        PSData = @{
            
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()
            
            # A URL to the license for this module.
            # LicenseUri = ''
            
            # A URL to the main website for this project.
            # ProjectUri = ''
            
            # A URL to an icon representing this module.
            # IconUri = ''
            
            # ReleaseNotes of this module
            # ReleaseNotes = ''
            
        } # End of PSData hashtable
        
    } # End of PrivateData hashtable
}