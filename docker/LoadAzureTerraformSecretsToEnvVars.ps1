<#
.SYNOPSIS
    Loads Azure Key Vault secrets into Terraform environment variables for the current PowerShell session.
.DESCRIPTION
    Loads Azure Key Vault secrets into Terraform environment variables for the current PowerShell session.

    The following steps are automated:
    - Identifies the Azure Key Vault matching a search string (default: 'terraform-kv').
    - Retrieves the Terraform secrets from Azure Key Vault.
    - Loads the Terraform secrets into these environment variables for the current PowerShell session:
        - ARM_SUBSCRIPTION_ID
        - ARM_CLIENT_ID
        - ARM_CLIENT_SECRET
        - ARM_TENANT_ID
        - ARM_ACCESS_KEY
.EXAMPLE
    .\LoadAzureTerraformSecretsToEnvVars.ps1 "terraform-kv"

    Loads Azure Key Vault secrets into Terraform environment variables for the current PowerShell session
.NOTES
    Assumptions:
    - Azure PowerShell module is installed: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
    - You are already logged into Azure before running this script (eg. Connect-AzAccount)

    Author:  Adam Rush
    GitHub:  https://github.com/adamrushuk
    Modifier: Yong Ji
    GitHub:  https://github.com/kulmam92
#>


[CmdletBinding()]
param (
    # Find the Azure Key Vault that includes this string in it's name
    [string]$keyVaultSearchString = 'terraform-kv',
    [string]$subscriptionid
)


#region Helper function for padded messages
function Write-HostPadded {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Message,

        [Parameter(Mandatory = $false)]
        [String]
        $ForegroundColor,

        [Parameter(Mandatory = $false)]
        [Int]
        $PadLength = 60,

        [Parameter(Mandatory = $false)]
        [Switch]
        $NoNewline
    )

    $writeHostParams = @{
        Object = $Message.PadRight($PadLength, '.')
    }

    if ($ForegroundColor) {
        $writeHostParams.Add('ForegroundColor', $ForegroundColor)
    }

    if ($NoNewline.IsPresent) {
        $writeHostParams.Add('NoNewline', $true)
    }

    Write-Host @writeHostParams
}
#endregion Helper function for padded messages


#region Check Azure login
Write-HostPadded -Message "Checking for an active Azure login..." -NoNewline

# Get current context
$azContext = Get-AzContext

if (-not $azContext) {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw "There is no active login for Azure. Please login first (eg 'Connect-AzAccount')"
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'
#endregion Check Azure login

if ($subscriptionid -ne $null) {
    #change subscription
    Write-HostPadded -Message "Switching subscription..." -NoNewline
    Select-AzSubscription -SubscriptionId $subscriptionid
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}

#region Identify Azure Key Vault
$loadMessage = "loading Terraform environment variables just for this PowerShell session"
Write-Host "`nSTARTED: $loadMessage" -ForegroundColor 'Green'

# Get Azure objects before Key Vault lookup
Write-HostPadded -Message "Searching for Terraform KeyVault..." -NoNewline
$tfKeyVault = Get-AzKeyVault | Where-Object VaultName -match $keyVaultSearchString
if (-not $tfKeyVault) {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw "Could not find Azure Key Vault with name including search string: [$keyVaultSearchString]"
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'
#endregion Identify Azure Key Vault


#region Get Azure KeyVault Secrets
Write-HostPadded -Message "Retrieving Terraform secrets from Azure Key Vault..." -NoNewline
$secretNames = @(
    'ARM_SUBSCRIPTION_ID'
    'ARM_CLIENT_ID'
    'ARM_CLIENT_SECRET'
    'ARM_TENANT_ID'
    'ARM_ACCESS_KEY'
)
$terraformEnvVars = @{}

# Compile Get Azure KeyVault Secrets
foreach ($secretName in $secretNames) {
    try {
        # Retrieve secret
        $azKeyVaultSecretParams = @{
            Name        = $secretName -replace '_', '-'
            VaultName   = $tfKeyVault.VaultName
            ErrorAction = 'Stop'
        }
        $tfSecret = Get-AzKeyVaultSecret @azKeyVaultSecretParams

        $secretValueText = '';
        $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tfSecret.SecretValue)
        try {
            $secretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
        }

        # Add secret to hashtable
        # $terraformEnvVars.$secretName = $tfSecret.SecretValueText
        $terraformEnvVars.$secretName = $secretValueText

    } catch {
        Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
        throw $_
    }
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'
#endregion Get Azure KeyVault Secrets


#region Load Terraform environment variables
$sessionMessage = "Setting session environment variables for Azure / Terraform"
Write-Host "`nSTARTED: $sessionMessage" -ForegroundColor 'Green'
foreach ($terraformEnvVar in $terraformEnvVars.GetEnumerator()) {
    # ansible
    if($terraformEnvVar.Key -eq "ARM_CLIENT_SECRET") {
        $ansbileEnvVar = "AZURE_SECRET"
    } elseif ($terraformEnvVar.Key -eq "ARM_TENANT_ID") {
        $ansbileEnvVar = "AZURE_TENANT"
    } else {
        $ansbileEnvVar = $terraformEnvVar.Key.replace("AZURE_","ARM_")
    }
    Write-HostPadded -Message "Setting [$($terraformEnvVar.Key)] & [$($ansbileEnvVar)]..." -NoNewline
    try {
        # Terraform
        $setItemParams = @{
            Path        = "env:$($terraformEnvVar.Key)"
            Value       = $terraformEnvVar.Value
            ErrorAction = 'Stop'
        }
        Set-Item @setItemParams
        $setItemParams = @{
            Path        = "env:$($ansbileEnvVar)"
            Value       = $terraformEnvVar.Value
            ErrorAction = 'Stop'
        }
        Set-Item @setItemParams
    } catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}
Write-Host "FINISHED: $sessionMessage" -ForegroundColor 'Green'

Write-Host "`nFINISHED: $loadMessage" -ForegroundColor 'Green'
#endregion Load Terraform environment variables