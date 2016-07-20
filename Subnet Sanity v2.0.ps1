# Subnet NSG checker
# Revision 1.2
# SDG 20150225

#Configurable Variables
$subnets = @("NST Infrastructure","PLT Infrastructure","Active Directory","Backup","WebServers-Tier1","MiddleWare","WebRoles","Oracle","SQL", "DEV Infrastructure", "DCCASIS-DBA", "DMZ-WebTier", "DMZ-Middleware", "DMZ-WebRoles", "DMZ-IS Infrastructure", "GatewaySubnet", "DMZ-RemoteApp")
$subscriptions = @("TestA1","TestA2","Development", "ProductionA2", "ProductionA1")

foreach ($subscription in $subscriptions) {

	Select-AzureSubscription -SubscriptionName "$subscription" -ErrorAction Stop | out-null
    #Get a copy of the VNET config for current subscription
	$currentVNetConfig = [xml] (Get-AzureVNetConfig).XMLConfiguration

    $virtNetCfg = $currentVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.VirtualNetworkSites.VirtualNetworkSite.name

    foreach ($sub_vnet in $virtNetCfg) {
        write-host "`n------- $subscription Subscription - $sub_vnet VNET -------`n"
          
        [Object]$vnet_subnet = $currentVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.VirtualNetworkSites.VirtualNetworkSite | Where-Object {$_.Name -eq "$sub_vnet"}

        foreach ($vnet_subnet in $vnet_subnet.Subnets.Subnet.name) {
            if ($subnets -contains $vnet_subnet) {
                if ($vnet_subnet -ne "GatewaySubnet" -and $vnet_subnet -ne "NST Infrastructure") {
                    $2 = Get-AzureNetworkSecurityGroupForSubnet -SubnetName "$vnet_subnet" -VirtualNetworkName $sub_vnet -ErrorAction SilentlyContinue | Select Name

                    if ($2 -eq $null) {
                        write-host "$vnet_subnet has no NSG" -foregroundcolor "red"
                    }
                    else {
                        $NSG =  $2.Name
                        write-host "$vnet_subnet has $NSG NSG applied"
                        $good++
                    }
                }
            } else {
                write-host "$vnet_subnet is not an approved subnet" -foregroundcolor "red"
            }
        }
    }
}