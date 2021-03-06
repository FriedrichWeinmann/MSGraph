﻿function Set-MgaMailMessage {
    <#
    .SYNOPSIS
        Set properties on message(s)

    .DESCRIPTION
        Set properties on message(s) in Exchange Online using the graph api.

    .PARAMETER Message
        Carrier object for Pipeline input. Accepts messages.

    .PARAMETER User
        The user-account to access. Defaults to the main user connected as.
        Can be any primary email name of any user the connected token has access to.

    .PARAMETER IsRead
        Indicates whether the message has been read.

    .PARAMETER Subject
        The subject of the message.
        (Updatable only if isDraft = true.)

    .PARAMETER Sender
        The account that is actually used to generate the message.
        (Updatable only if isDraft = true, and when sending a message from a shared mailbox,
        or sending a message as a delegate. In any case, the value must correspond to the actual mailbox used.)

    .PARAMETER From
        The mailbox owner and sender of the message.
        Must correspond to the actual mailbox used.
        (Updatable only if isDraft = true.)

    .PARAMETER ToRecipients
        The To recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER CCRecipients
        The Cc recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER BCCRecipients
        The Bcc recipients for the message.
        (Updatable only if isDraft = true.)

    .PARAMETER ReplyTo
        The email addresses to use when replying.
        (Updatable only if isDraft = true.)

    .PARAMETER Body
        The body of the message.
        (Updatable only if isDraft = true.)

    .PARAMETER Categories
        The categories associated with the message.

    .PARAMETER Importance
        The importance of the message.
        The possible values are: Low, Normal, High.

    .PARAMETER InferenceClassification
        The classification of the message for the user, based on inferred relevance or importance, or on an explicit override.
        The possible values are: focused or other.

    .PARAMETER InternetMessageId
        The message ID in the format specified by RFC2822.
        (Updatable only if isDraft = true.)

    .PARAMETER IsDeliveryReceiptRequested
        Indicates whether a delivery receipt is requested for the message.

    .PARAMETER IsReadReceiptRequested
        Indicates whether a read receipt is requested for the message.

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
        PS C:\> $mail | Set-MgaMailMessage -IsRead $false

        Set messages represented by variable $mail to status "unread"
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Inbox -ResultSize 1

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -IsRead $false -categories "Red category"

        Set status "unread" and category "Red category" to messages represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Inbox -ResultSize 1

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -ToRecipients "someone@something.org"

        Set reciepent from draft mail represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts

    .EXAMPLE
        PS C:\> Set-MgaMailMessage -Id $mail.Id -ToRecipients "someone@something.org" -Subject "Something important"

        Set reciepent from draft mail represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts

    .EXAMPLE
        PS C:\> $mail | Set-MgaMailMessage -ToRecipients $null

        Clear reciepent from draft mail represented by variable $mail
        The variable $mails can be represent:
        PS C:\> $mails = Get-MgaMailMessage -Folder Drafts


    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidAssignmentToAutomaticVariable", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [Alias("Update-MgaMailMessage")]
    [OutputType([MSGraph.Exchange.Mail.Message])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('InputObject', 'MessageId', 'Id')]
        [MSGraph.Exchange.Mail.MessageParameter[]]
        $Message,

        [ValidateNotNullOrEmpty()]
        [bool]
        $IsRead,

        [string]
        $Subject,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $Sender,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $From,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Alias('To', 'Recipients')]
        [string[]]
        $ToRecipients,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $CCRecipients,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $BCCRecipients,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]
        $ReplyTo,

        [String]
        $Body,

        [String[]]
        $Categories,

        [ValidateSet("Low", "Normal", "High")]
        [String]
        $Importance,

        [ValidateSet("focused", "other")]
        [String]
        $InferenceClassification,

        [String]
        $InternetMessageId,

        [bool]
        $IsDeliveryReceiptRequested,

        [bool]
        $IsReadReceiptRequested,

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
    }

    process {
        Write-PSFMessage -Level Debug -Message "Gettings folder(s) by parameterset $($PSCmdlet.ParameterSetName)" -Tag "ParameterSetHandling"

        #region Put parameters (JSON Parts) into a valid "message"-JSON-object together
        $jsonParams = @{}
        $boundParameters = @()
        $names = "IsRead", "Subject", "Sender", "From", "ToRecipients", "CCRecipients", "BCCRecipients", "ReplyTo", "Body", "Categories", "Importance", "InferenceClassification", "InternetMessageId", "IsDeliveryReceiptRequested", "IsReadReceiptRequested"
        foreach ($name in $names) {
            if (Test-PSFParameterBinding -ParameterName $name) {
                Write-PSFMessage -Level Debug -Message "Add $($name) from parameters to message" -Tag "ParameterParsing"
                $boundParameters = $boundParameters + $name
                $jsonParams.Add($name, (Get-Variable $name -Scope 0).Value)
            }
        }
        $bodyJSON = New-JsonMailObject @jsonParams -FunctionName $MyInvocation.MyCommand
        #endregion Put parameters (JSON Parts) into a valid "message"-JSON-object together

        #region Update messages
        foreach ($messageItem in $Message) {
            #region checking input object type and query message if required
            if ($messageItem.TypeName -like "System.String") {
                $messageItem = Resolve-MailObjectFromString -Object $messageItem -User $User -Token $Token -NoNameResolving -FunctionName $MyInvocation.MyCommand
                if (-not $messageItem) { continue }
            }

            $User = Resolve-UserInMailObject -Object $messageItem -User $User -ShowWarning -FunctionName $MyInvocation.MyCommand
            #endregion checking input object type and query message if required

            if ($pscmdlet.ShouldProcess("message '$($messageItem)'", "Update properties '$([string]::Join("', '", $boundParameters))'")) {
                Write-PSFMessage -Tag "MessageUpdate" -Level Verbose -Message "Update properties '$([string]::Join("', '", $boundParameters))' on message '$($messageItem)'"
                $invokeParam = @{
                    "Field"        = "messages/$($messageItem.Id)"
                    "User"         = $User
                    "Body"         = $bodyJSON
                    "ContentType"  = "application/json"
                    "Token"        = $Token
                    "FunctionName" = $MyInvocation.MyCommand
                }
                $output = Invoke-MgaRestMethodPatch @invokeParam
                if ($output -and $PassThru) { New-MgaMailMessageObject -RestData $output }
            }
        }
        #endregion Update messages
    }

}