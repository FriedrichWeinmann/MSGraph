﻿function Move-MgaMailMessage {
    <#
    .SYNOPSIS
        Move message(s) to a folder

    .DESCRIPTION
        Move message(s) to a folder in Exchange Online using the graph api.

    .PARAMETER Message
        Carrier object for Pipeline input. Accepts messages and strings.

    .PARAMETER DestinationFolder
        The destination folder where to move the message to

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
        PS C:\> $mails | Move-MgaMailMessage -DestinationFolder $destinationFolder

        Moves messages in variable $mails to the folder in the variable $destinationFolder.
        also possible:
        PS C:\> Move-MgaMailMessage -Message $mails -DestinationFolder $destinationFolder

        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Inbox -ResultSize 1

        The variable $destinationFolder can be represent:
        PS C:\> $destinationFolder = Get-MgaMailFolder -Name "Archive"

    .EXAMPLE
        PS C:\> Move-MgaMailMessage -Id $mails.id -DestinationFolder $destinationFolder

        Moves messages into the folder $destinationFolder.

        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Inbox -ResultSize 1

        The variable $destinationFolder can be represent:
        PS C:\> $destinationFolder = Get-MgaMailFolder -Name "Archive"

    .EXAMPLE
        PS C:\> Get-MgaMailMessage -Folder Inbox | Move-MgaMailMessage -DestinationFolder $destinationFolder

        Moves ALL messages from your inbox into the folder $destinationFolder.
        The variable $destinationFolder can be represent:
        PS C:\> $destinationFolder = Get-MgaMailFolder -Name "Archive"

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [Alias()]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('InputObject', 'MessageId', 'Id', 'Mail', 'MailId')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [Parameter(Mandatory = $true, Position = 1)]
        [MSGraph.Exchange.Mail.FolderParameter]
        $DestinationFolder,

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

        #region checking DestinationFolder and query folder if required
        if ($DestinationFolder.TypeName -like "System.String") {
            $DestinationFolder = Resolve-MailObjectFromString -Object $DestinationFolder -User $User -Token $Token -FunctionName $MyInvocation.MyCommand
            if (-not $DestinationFolder) { throw }
        }
        #endregion checking DestinationFolder and query folder if required

        $bodyHash = @{
            destinationId = ($DestinationFolder.Id | ConvertTo-Json)
        }
    }

    process {
        Write-PSFMessage -Level Debug -Message "Gettings messages by parameter set $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        # Put parameters (JSON Parts) into a valid JSON-object together and output the result
        $bodyJSON = Merge-HashToJson $bodyHash

        #region move message
        foreach ($messageItem in $Message) {
            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if (-not $messageItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if ($pscmdlet.ShouldProcess("message '$($messageItem)'", "Move to folder '$($DestinationFolder.Name)'")) {
                Write-PSFMessage -Tag "MessageUpdate" -Level Verbose -Message "Move message '$($messageItem)' to folder '$($DestinationFolder)'"
                $invokeParam = @{
                    "Field"        = "messages/$($messageItem.Id)/move"
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaRestMethodPost @invokeParam
                if ($PassThru) { New-MgaMailMessageObject -RestData $output }
            }
        }
        #endregion move message
    }

    end {
    }
}