﻿function Rename-MgaMailFolder {
    <#
    .SYNOPSIS
        Rename folder(s) in Exchange Online using the graph api.

    .DESCRIPTION
        Change the displayname of folder(s) in Exchange Online using the graph api.

    .PARAMETER Folder
        The folder to be renamed. This can be a name of the folder, it can be the
        Id of the folder or it can be a folder object passed in.

    .PARAMETER NewName
        The name to be set as new name.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER Token
        The token representing an established connection to the Microsoft Graph Api.
        Can be created by using New-MgaAccessToken.
        Can be omitted if a connection has been registered using the -Register parameter on New-MgaAccessToken.

    .PARAMETER PassThru
        Outputs the token to the console

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .EXAMPLE
        PS C:\> Rename-MgaMailFolder -Folder 'Inbox' -NewName 'MyPersonalInbox'

        Rename the "wellknown" folder inbox (regardless of it's current name), to 'MyPersonalInbox'.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [OutputType([MSGraph.Exchange.Mail.Folder])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByInputObject')]
        [Alias('FolderName', 'FolderId', 'InputObject', 'DisplayName', 'Name', 'Id')]
        [MSGraph.Exchange.Mail.FolderParameter[]]
        $Folder,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $NewName,

        [string]
        $User,

        [MSGraph.Core.AzureAccessToken]
        $Token,

        [switch]
        $PassThru
    )
    begin {
        $requiredPermission = "Mail.ReadWrite"
        $Token = Invoke-TokenScopeValidation -Token $Token -Scope $requiredPermission -FunctionName $MyInvocation.MyCommand

        $bodyJSON = @{
            displayName = $NewName
        } | ConvertTo-Json
    }

    process {
        Write-PSFMessage -Level Debug -Message "Gettings folder(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        foreach ($folderItem in $Folder) {
            #region checking input object type and query folder if required
            if ($folderItem.TypeName -like "System.String") {
                $folderItem = Resolve-MailObjectFromString -Object $folderItem -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
                if (-not $folderItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $folderItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if ($pscmdlet.ShouldProcess("Folder '$($folderItem)'", "Rename to '$($NewName)'")) {
                Write-PSFMessage -Tag "FolderUpdate" -Level Verbose -Message "Rename folder '$($folderItem)' to name '$($NewName)'"
                $invokeParam = @{
                    "Field"        = "mailFolders/$($folderItem.Id)"
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaRestMethodPatch @invokeParam
                if ($PassThru) {
                    New-MgaMailFolderObject -RestData $output -ParentFolder $folderItem.InputObject.ParentFolder -FunctionName $MyInvocation.MyCommand
                }
            }
        }
    }

    end {
    }
}