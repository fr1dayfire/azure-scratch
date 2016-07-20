# DS 20160625
# Create 2 new vnets with subnets, and vnet-to-vnet connection
# Step 1 - Create and configure VNet1 , and associated subnets
# Prepare variables

$Sub1          = "Sandbox POC Network"
$RG1           = "RG-V2-Default-Networking-Ams"
$Location1     = "West Europe"
$VNetName1     = "NPOC_V2_CoreServices_Ams"
# $FESubName1    = "FrontEnd"
# $BESubName1    = "Backend"
$GWSubName1    = "GatewaySubnet"
$VNetPrefix11  = "10.63.192.0/19"
# $VNetPrefix12  = "10.12.0.0/16"
# $FESubPrefix1  = "10.11.0.0/24"
# $BESubPrefix1  = "10.12.0.0/24"
$GWSubPrefix1  = "10.63.220.0/28"
# $DNS1          = "8.8.8.8"
$GWName1       = "NPOC_V2_CoreServices_VNG_Ams"
$GWIPName1     = "NPOC_V2_CoreServices_PIP_Ams"
$GWIPconfName1 = "gwipconf1"
$Connection14  = "NPOC_V2_CoreServices_VNG_Ams_Vpn"
$Connection15  = "NPOC_xxxx"

# Login to Azure subscription
Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName $Sub1

# Get/Create new ResourceGroup if needed
Get-AzureRmResourceGroup
# New-AzureRmResourceGroup -Name $RG1 -Location $Location1

# Create subnet config
$fesub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName1 -AddressPrefix $FESubPrefix1
$besub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName1 -AddressPrefix $BESubPrefix1
$gwsub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName1 -AddressPrefix $GWSubPrefix1

# Create VNet1
New-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1 -Location $Location1 -AddressPrefix $VNetPrefix11,$VNetPrefix12 -Subnet $fesub1,$besub1,$gwsub1

# To connect to other Vnets, create a VNG [virtual network gateway:
# Request a public IP address
$gwpip1    = New-AzureRmPublicIpAddress -Name $GWIPName1 -ResourceGroupName $RG1 -Location $Location1 -AllocationMethod Dynamic

# Create the VNG [virtual network gateway] configuration
$vnet1     = Get-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1
$subnet1   = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet1
$gwipconf1 = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName1 -Subnet $subnet1 -PublicIpAddress $gwpip1

# Create the gateway for TestVNet1 [takes up to 30min]
# For VPN [as opposed to ExpressRoute]:
New-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1 -Location $Location1 -IpConfigurations $gwipconf1 -GatewayType Vpn -VpnType RouteBased -GatewaySku Standard

#############
# Create the 2nd vnet and associated subnets
#############
# Create and configure TestVNet4
# Declare your variables
$RG4           = "RG-V2-Default-Networking-Ams"
$Location4     = "West Europe"
$VnetName4     = "NPOC_V2_Prod_PreProd_Ams"
# $FESubName4    = "FrontEnd"
# $BESubName4    = "Backend"
$GWSubName4    = "GatewaySubnet"
$VnetPrefix41  = "10.63.128.0/18"
# $VnetPrefix42  = "10.42.0.0/16"
# $FESubPrefix4  = "10.41.0.0/24"
# $BESubPrefix4  = "10.42.0.0/24"
$GWSubPrefix4  = "10.63.188.0/28"
# $DNS4          = "8.8.8.8"
$GWName4       = "NPOC_V2_Prod_PreProd_VNG_Ams"
$GWIPName4     = "NPOC_V2_Prod_PreProd_PIP_Ams"
$GWIPconfName4 = "gwipconf4"
$Connection41  = "NPOC_V2_Prod_PreProd_VNG_Ams_Vpn"

# Create a new resource group
New-AzureRmResourceGroup -Name $RG4 -Location $Location4

# Create the subnet configurations for TestVNet4
$fesub4 = New-AzureRmVirtualNetworkSubnetConfig -Name $FESubName4 -AddressPrefix $FESubPrefix4
$besub4 = New-AzureRmVirtualNetworkSubnetConfig -Name $BESubName4 -AddressPrefix $BESubPrefix4
$gwsub4 = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubName4 -AddressPrefix $GWSubPrefix4

# Create TestVNet4
New-AzureRmVirtualNetwork -Name $VnetName4 -ResourceGroupName $RG4 -Location $Location4 -AddressPrefix $VnetPrefix41,$VnetPrefix42 -Subnet $fesub4,$besub4,$gwsub4

# Request a public IP address
$gwpip4    = New-AzureRmPublicIpAddress -Name $GWIPName4 -ResourceGroupName $RG4 -Location $Location4 -AllocationMethod Dynamic

# Create the gateway configuration
$vnet4     = Get-AzureRmVirtualNetwork -Name $VnetName4 -ResourceGroupName $RG4
$subnet4   = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet4
$gwipconf4 = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName4 -Subnet $subnet4 -PublicIpAddress $gwpip4

# Create the TestVNet4 gateway
New-AzureRmVirtualNetworkGateway -Name $GWName4 -ResourceGroupName $RG4 -Location $Location4 -IpConfigurations $gwipconf4 -GatewayType Vpn -VpnType RouteBased -GatewaySku Standard

##########
# Join the 2 vnets by connecting the 2 vnet gateways
##########

# To connect two vnets, create vnet-to-vnet connection by connecting the vnet gateways
# Get both virtual network gateways
# If both gateways are in the same subscription, this step can be completed in the same PowerShell session.

$vnet1gw = Get-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
$vnet4gw = Get-AzureRmVirtualNetworkGateway -Name $GWName4 -ResourceGroupName $RG4

# Create the TestVNet1 to TestVNet4 connection
# First create the connection in 1 dirn, from VNet1 to VNet4.
# You can use your own values for the shared key. 
# Shared key must match for both connections. Creating a connection can take a short while to complete.
New-AzureRmVirtualNetworkGatewayConnection -Name $Connection14 -ResourceGroupName $RG1 -VirtualNetworkGateway1 $vnet1gw -VirtualNetworkGateway2 $vnet4gw -Location $Location1 -ConnectionType Vnet2Vnet -SharedKey 'A1b2C3potgieter'

# Create the vnet-to-vnet connection in the reverse direction:TestVNet4 to TestVNet1.Make sure shared keys match.
# The vnet-to-vnet connection should be established after a few mins
New-AzureRmVirtualNetworkGatewayConnection -Name $Connection41 -ResourceGroupName $RG4 -VirtualNetworkGateway1 $vnet4gw -VirtualNetworkGateway2 $vnet1gw -Location $Location4 -ConnectionType Vnet2Vnet -SharedKey 'A1b2C3potgieter'

# Verify status of vnet-to-vnet connection
# connection status shoould show as Connected and see ingress and egress bytes.
# May take a few minutes to show up as Connected
Get-AzureRmVirtualNetworkGatewayConnection -Name $Connection14 -ResourceGroupName $RG1 -Debug

#########
To connect vnets in different subscriptions:
Not done this step as part of POC
#########
# Connecting the vnet gateways in different subscriptions
# In this example, because the gateways are in the different subscriptions, 
# we've split this step into two PowerShell sessions marked as [Subscription 1] and [Subscription 5].

# [Subscription 1] Get the virtual network gateway for Subscription 1
# Make sure you login and connect to Subscription 1.
$vnet1gw = Get-AzureRmVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1

# Copy the output of the following elements and send these to the administrator of Subscription 5 via email or another method.
# $vnet1gw.Name
# $vnet1gw.Id
#These two elements will have values similar to the following example output:
PS D:\> $vnet1gw.Name
NPOC_V2_CoreServices_VNG_Ams
PS D:\> $vnet1gw.Id
/subscriptions/f9cbd391-e76a-43ef-a0d7-a90cf396fdbb/resourceGroups/RG-V2-Default-Networking-Ams/providers/Microsoft.Network/virtualNetworkGateways/NPOC_V2_CoreServices_VNG_Ams

# [Subscription 5] Get the virtual network gateway for Subscription 5
# Make sure you login and connect to Subscription 5.
$vnet5gw = Get-AzureRmVirtualNetworkGateway -Name $GWName5 -ResourceGroupName $RG5

# Copy the output of the following elements and send these to the administrator of Subscription 1 via email or another method.
# $vnet5gw.Name
# $vnet5gw.Id
# These two elements will have values similar to the following example output:
PS C:\> $vnet5gw.Name
VNet5GW
PS C:\> $vnet5gw.Id
/subscriptions/66c8e4f1-ecd6-47ed-9de7-7e530de23994/resourceGroups/TestRG5/providers/Microsoft.Network/virtualNetworkGateways/VNet5GW

# [Subscription 1] Create the TestVNet1 to TestVNet5 connection
# In this step, you will create the connection from TestVNet1 to TestVNet5. The difference here is that $vnet5gw cannot be obtained directly because it is in a different subscription. You will need to create a new PowerShell object with the values communicated from Subscription 1 in the steps above. Please replace the Name, Id, and shared key with your own values. The important thing is that the shared key must match for both connections. Creating a connection can take a short while to complete.
# Make sure you connect to Subscription 1.
$vnet5gw = New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway
$vnet5gw.Name = "VNet5GW"
$vnet5gw.Id   = "/subscriptions/66c8e4f1-ecd6-47ed-9de7-7e530de23994/resourceGroups/TestRG5/providers/Microsoft.Network/virtualNetworkGateways/VNet5GW"
$Connection15 = "VNet1toVNet5"
New-AzureRmVirtualNetworkGatewayConnection -Name $Connection15 -ResourceGroupName $RG1 -VirtualNetworkGateway1 $vnet1gw -VirtualNetworkGateway2 $vnet5gw -Location $Location1 -ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'

# [Subscription 5] Create the TestVNet5 to TestVNet1 connection
# This step is similar to the one above, except you are creating the connection from TestVNet5 to TestVNet1. The same process of creating a PowerShell object based on the values obtained from Subscription 1 applies here as well. In this step, be sure that the shared keys match.
# Make sure you connect to Subscription 5.
$vnet1gw = New-Object Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway
$vnet1gw.Name = "VNet1GW"
$vnet1gw.Id   = "/subscriptions/b636ca99-6f88-4df4-a7c3-2f8dc4545509/resourceGroups/TestRG1/providers/Microsoft.Network/virtualNetworkGateways/VNet1GW "
New-AzureRmVirtualNetworkGatewayConnection -Name $Connection51 -ResourceGroupName $RG5 -VirtualNetworkGateway1 $vnet5gw -VirtualNetworkGateway2 $vnet1gw -Location $Location5 -ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'

# Verifying your connection as per above
