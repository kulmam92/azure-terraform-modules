# run LoadAzureTerraformSecretsToEnvVars.ps1 first to load env variables
if ($null -ne $env:ARM_SUBSCRIPTION_ID) {
    docker run -it -w /home/iacdev --rm --volume ""$PSScriptRoot/../":/home/iacdev/module" `
    -e "AZURE_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -e "AZURE_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -e "AZURE_SECRET=$env:ARM_ACCESS_KEY" `
    -e "AZURE_TENANT=$env:ARM_TENANT_ID" `
    -e "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -e "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -e "ARM_ACCESS_KEY=$env:ARM_ACCESS_KEY" `
    -e "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    iacbase
} else {
    Write-Host "Necessary environment varables hasn't been set. Run -- az cli -- first" -ForegroundColor 'Red'
    throw $_
}