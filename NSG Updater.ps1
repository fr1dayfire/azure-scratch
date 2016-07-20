#Show files that have been modified within last 1 day
Import-Module '\\hqrdata01\mis\Shared MIS\IS\Infra & Ops\NST\5 - Projects\01 - In Progress\Cloud 2014\Azure\Powershell\NSG\AzureCustomNetworkSecurityGroup\AzureCustomNetworkSecurityGroup.ps1'
$match = '*.csv' 
$dir_to_look="S:\Infra & Ops\NST\1 - Network\4 - WAN\4 - Azure\NSG\"
    
$days_backdate=$(Get-Date).AddDays(-1)    
  
#--Find the files which are modified or created within last 7 days --#    
Get-Childitem $dir_to_look -Recurse -include $match | `   
where-object {!($_.psiscontainer)} | `   
where { $_.LastWriteTime -gt $days_backdate } | `   
foreach {  
    $vnet = Split-Path (Split-Path $($_.Fullname) -Parent) -Leaf
    Select-AzureSubscription -SubscriptionName "$vnet"
    Write-Host "$($_.LastWriteTime) :: $($_.Name) :: $($_.Directory)"  
    $name_noext = [io.path]::GetFileNameWithoutExtension("$($_.Fullname)")
    write-host $name_noext
    Update-AzureCustomNetworkSecurityGroup -CSVPath "S:\Infra & Ops\NST\1 - Network\4 - WAN\4 - Azure\NSG\$vnet\$($_.Name)" -NetworkSecurityGroupName "$vnet-$name_noext" -verbose
}   