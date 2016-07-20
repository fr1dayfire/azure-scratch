#SDG 20160111
#Search across all NSG CSV files for particular parrern
$subscriptions = @("Test","TestA2","Development", "DCCASIS", "DCCASIS-AMS", "ProductionA2", "ProductionA1")
$pattern = "10.2.10.108"

foreach ($subscription in $subscriptions) {
    write-host "`n------- $subscription Subscription -------`n"
    Set-Location -Path "S:\Infra & Ops\NST\1 - Network\4 - WAN\4 - Azure\NSG\$subscription\"
    dir -Recurse | Select-String -pattern $pattern
}

#Find and Replace across all NSG files

Set-Location -Path "S:\Infra & Ops\NST\1 - Network\4 - WAN\4 - Azure\NSG\"
$find = '10.6.66.4'
$replace = '10.4.66.6'
$match = '*.csv' 

foreach ($sc in dir -recurse -include $match | where { test-path $_.fullname -pathtype leaf} ) {
    select-string -path $sc -pattern $find
    (get-content $sc) | foreach-object { $_ -replace $find, $replace } | set-content $sc
}