<#
.SYNOPSIS
    Create and delete compute Object by comparing computeObjectNames parameter and existing computeObjects.
.DESCRIPTION
    Create and delete compute Object by comparing computeObjectNames parameter and existing computeObjects.
.EXAMPLE
    .\scripts\deploy-computeobject.ps1 sb-azu-XXXXXX rg-azusw2-XXXXX ml-azusw2-XXXXXX @("default-cluster") rg-azusw2-XXXXXX vnet-azusw2-XXXXXX snet-azusw2-XXXXXX-Shared -dryRun
.NOTES
    Assumptions:
    - Azure PowerShell module is installed: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
    - Azure Machine Learning CLI is installed: https://docs.microsoft.com/en-us/azure/machine-learning/reference-azure-machine-learning-cli
    -- az extension add -n azure-cli-ml
    - You are already logged into Azure before running this script (eg. Connect-AzAccount)

    Author:  Yong Ji
#>


[CmdletBinding()]
param (
    [string]$subscriptionName,
    [string]$resourceGroupName,
    [string]$workspaceName,
    [string[]]$computeObjectNames,
    [string]$computeObjectType,
    [string]$vnetResourceGroupName,
    [string]$vnetName,
    [string]$subnetName,
    [bool]$keepUnmanagedObjects = $True,
    [bool]$dryRun = $False
)

$ErrorActionPreference = "Stop"
$vmSize = "Standard_DS3_v2"
$vmPriority = "dedicated"
$maxNodes = 4
if ($computeObjectType -eq "cluster") {
    $objectPostfix = "-cluster"
} else {
    $objectPostfix = "-com"
}

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

$subscriptionId = az account list --query "[?name=='$subscriptionName']" | ConvertFrom-Json | select-object -expand id
if ($LASTEXITCODE -ne 0){
    # Write-Host($error)
    throw "az cli command failed"
}

if ($null -ne $subscriptionId) {
    #change subscription
    Write-HostPadded -Message "Switching subscription..." -NoNewline
    Select-AzSubscription -SubscriptionId $subscriptionId
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}

$mergeMessage = "creating Computer$computeObjectType"
Write-Host "`nSTARTED: $mergeMessage" -ForegroundColor 'Green'

# Comparing computeObject list with existing ComputerObjects
Write-HostPadded -Message "Comparing computeObject list..." -NoNewline

# computetarget list doesn't have a option to filter by compute type
# There, I'm filtering using naming convention. -- *Object
$existingComputerObjects = az ml computetarget list --resource-group $resourceGroupName --workspace-name $workspaceName | convertfrom-json | Where-Object {$_.name.ToLower() -like "*$objectPostfix"} | select-object -expand name
if ($LASTEXITCODE -ne 0){
    # Write-Host($error)
    throw "az ml computetarget list failed"
}
$comparedComputerObjects = compare-object -referenceobject @($computeObjectNames | Select-Object) -differenceobject @($existingComputerObjects | Select-Object) -IncludeEqual
Write-Host "SUCCESS!" -ForegroundColor 'Green'

# deploy computeObjects based on the comparison result
Write-HostPadded -Message "deploying Computer$computeObjectType..."
foreach ($computerObject in $comparedComputerObjects) {
    try {
        if ($computerObject.SideIndicator -eq "=>" -And !$keepUnmanagedObjects) {
            write-host "deleting $($computerObject.InputObject)"
            if ($dryRun -eq $false) {
                az ml computetarget delete -n $computerObject.InputObject --resource-group $resourceGroupName --workspace-name $workspaceName
                if ($LASTEXITCODE -ne 0){
                    # Write-Host($error)
                    throw "az ml computetarget delete"
                }
            }
        } elseif ($computerObject.SideIndicator -eq "<=") {
            write-host "creating $($computerObject.InputObject)"
            if ($dryRun -eq $false) {
                if ($computeObjectType -eq "cluster") {
                    az ml computetarget create amlcompute -n $computerObject.InputObject -s $vmSize -p $vmPriority --max-nodes $maxNodes --resource-group $resourceGroupName --subnet-name $subnetName --vnet-name $vnetName --vnet-resourcegroup-name $vnetResourceGroupName --workspace-name $workspaceName
                    if ($LASTEXITCODE -ne 0){
                        # Write-Host($error)
                        throw "az ml computetarget create amlcompute failed"
                    }
                } else {
                    az ml computetarget create computeinstance -n $computerObject.InputObject -s $vmSize --resource-group $resourceGroupName --subnet-name $subnetName --vnet-name $vnetName --vnet-resourcegroup-name $vnetResourceGroupName --workspace-name $workspaceName
                    if ($LASTEXITCODE -ne 0){
                        # Write-Host($error)
                        throw "az ml computetarget create computeinstance failed"
                    }
                }
            }
        } else {
            write-host "skipping $($computerObject.InputObject)"
        }
    } catch {
        Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
        throw $_
    }
}
Write-HostPadded -Message "deployed Computer$computeObjectType..." -NoNewline
Write-Host "SUCCESS!" -ForegroundColor 'Green'

# list up existing ComputerObjects
# computetarget list doesn't have a option to filter by compute type
# There, I'm filtering using naming convention.
az ml computetarget list --resource-group $resourceGroupName --workspace-name $workspaceName | convertfrom-json | Where-Object {$_.name.ToLower() -like "*$objectPostfix"} | Format-Table
if ($LASTEXITCODE -ne 0){
    # Write-Host($error)
    throw "az ml computetarget list failed"
}

Write-Host "`nFINISHED: $mergeMessage" -ForegroundColor 'Green'