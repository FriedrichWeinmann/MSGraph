﻿<#
# Example:
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Type -Name MSGraph.alcohol
#>

Register-PSFTeppArgumentCompleter -Command New-MgaAccessToken -Parameter "Permission" -Name "MSGraph.Core.Permission.Consent.User"

Register-PSFTeppArgumentCompleter -Command Get-MgaMailFolder -Parameter "Name" -Name "MSGraph.Exchange.Mail.WellKnowFolders"
Register-PSFTeppArgumentCompleter -Command Move-MgaMailFolder -Parameter "DestinationFolder" -Name "MSGraph.Exchange.Mail.WellKnowFolders"
Register-PSFTeppArgumentCompleter -Command New-MgaMailFolder -Parameter "ParentFolder" -Name "MSGraph.Exchange.Mail.WellKnowFolders"
Register-PSFTeppArgumentCompleter -Command Remove-MgaMailFolder -Parameter "Folder" -Name "MSGraph.Exchange.Mail.WellKnowFolders"

Register-PSFTeppArgumentCompleter -Command Get-MgaMailMessage -Parameter "FolderName" -Name "MSGraph.Exchange.Mail.WellKnowFolders"
Register-PSFTeppArgumentCompleter -Command Move-MgaMailMessage -Parameter "DestinationFolder" -Name "MSGraph.Exchange.Mail.WellKnowFolders"

Register-PSFTeppArgumentCompleter -Command Get-MgaExchCategory -Parameter "Color" -Name "MSGraph.Exchange.Category.Colors"
Register-PSFTeppArgumentCompleter -Command New-MgaExchCategory -Parameter "Color" -Name "MSGraph.Exchange.Category.Colors"
Register-PSFTeppArgumentCompleter -Command Set-MgaExchCategory -Parameter "Color" -Name "MSGraph.Exchange.Category.Colors"
