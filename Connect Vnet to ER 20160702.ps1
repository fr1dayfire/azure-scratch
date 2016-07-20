# DS 20160702
# Link a virtual network to an ExpressRoute circuit
# #
# Prereqs:
# Ensure that you have Azure private peering configured for your ExpressRoute circuit.
# Ensure that Azure private peering is configured and the BGP peering between your network and Microsoft is up so that you can enable end-to-end connectivity.
# Ensure that you have a virtual network and a virtual network gateway created and fully provisioned.
#
#$subscription = "Sandbox POC Network"
#$subscription = "Dyno"
$subscription = "Core Services"
$vnet = "NPOC_V2_CoreServices_Ams"
$location = "West Europe"
# $RGname = "V2-Default-Networking-Ams"

# Login to Azure
Login-AzureRmAccount
Get-AzureRmSubscription 

#Select Subscription
Select-AzureRmSubscription -SubscriptionName $subscription
# List the ExpressRoute cct details to populate the ExpressRouteCCT name variable:

########
# Connect a vnet in the same subscription to a circuit:
# this can be done in the ARM Portal - suggest you do it there since it's not a regular activity
########
# Make sure that the vnet gateway [VNG] is created and is ready for linking beforehand:
$RGname = "V2-Default-Networking-Ams"
# Get ExpressRoute cct name and set variable
Get-AzureRmExpressRouteCircuit
$ExpressRouteCctName = "BG-CoreServices-Ams"
# Get VNG details to populate VNGname variable
Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RGname
$VNGname = BG-V2-CoreServices-VNG-Ams
#Name of new VNG-to-ER Connection:
$NewVNGERConnection = BG-V2-CoreServices-VNG-Ams-CoreEX-Ams
Get-AzureRmVirtualNetworkGatewayConnection
#
$circuit = Get-AzureRmExpressRouteCircuit -Name $ExpressRouteCctName -ResourceGroupName $RGname
$gw = Get-AzureRmVirtualNetworkGateway -Name $VNGname -ResourceGroupName $RGname
$connection = New-AzureRmVirtualNetworkGatewayConnection -Name "ERConnection" -ResourceGroupName $RGname -Location $location -VirtualNetworkGateway1 $gw -PeerId $circuit.Id -ConnectionType ExpressRoute

##########
#Connect a virtual network in a different subscription to a circuit
##########
# The circuit owner is an authorized power user of the ExpressRoute circuit resource. 
# The circuit owner can create authorizations that can be redeemed by circuit users. 
# Circuit users are owners of virtual network gateways (that are not within the same subscription as the ExpressRoute circuit). 
# Circuit users can redeem authorizations (one authorization per virtual network).
# The circuit owner has the power to modify and revoke authorizations at any time. 
# Revoking an authorization results in all link connections being deleted from the subscription whose access was revoked.
# Takes a few minutes to create
#
From the 'OWNER' of ExpressRoute, create the Authorization key
# Make sure that the vnet gateway [VNG] is created and is ready for linking beforehand:
$RGname = "V2-Default-Networking-Ams"
# Get ExpressRoute cct name and set variable
# Get-AzureRmExpressRouteCircuit
$ExpressRouteCctName = "BG-CoreServices-Ams"
# Set Authorization key name variable: <OwnerEX>-<OwnerEXlocation>-<SlaveSubscriptionName>Auth<##>-<Slavelocation>
$AuthName01 = "CoreEX-Ams-DynoAuth01-Ams"
#
$circuit = Get-AzureRmExpressRouteCircuit -Name $ExpressRouteCctName -ResourceGroupName $RGname
Add-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit -Name $AuthName01
# Save the above setting:
Set-AzureRmExpressRouteCircuit -ExpressRouteCircuit $circuit

$auth1 = Get-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit -Name $AuthName01

# To review all current authorizations:
# Takes a few minutes to create AuthKeys etc
$circuit = Get-AzureRmExpressRouteCircuit -Name $ExpressRouteCctName -ResourceGroupName $RGname
Get-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit
# Set the variable
$authorizations = Get-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit

# Adding authorizations
# The circuit OWNER can add authorizations by using the following cmdlet:
$circuit = Get-AzureRmExpressRouteCircuit -Name $ExpressRouteCctName -ResourceGroupName $RGname
$AuthName02 = "CoreEX-Ams-DynoAuth01-Dub"
Add-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit -Name $AuthName02
# Save
Set-AzureRmExpressRouteCircuit -ExpressRouteCircuit $circuit

$circuit = Get-AzureRmExpressRouteCircuit -Name $ExpressRouteCctName -ResourceGroupName $RGname
$authorizations = Get-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit

# Deleting authorizations
The circuit owner can revoke/delete authorizations to the user by running the following cmdlet:
to review all current authorizations:
$circuit = Get-AzureRmExpressRouteCircuit -Name $ExpressRouteCctName -ResourceGroupName $RGname
Get-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit
Remove-AzureRmExpressRouteCircuitAuthorization -Name "CoreEX-Ams-EXAuthorization01" -ExpressRouteCircuit $circuit
# Save
Set-AzureRmExpressRouteCircuit -ExpressRouteCircuit $circuit    

#######################
## Circuit user operations
#######################
#
#The circuit user needs the peer ID and an authorization key from the circuit owner. The authorization key is a GUID.
#
# Redeeming connection authorizations
# The circuit user can run the following to redeem a link authorization:
$id = "/subscriptions/********************************/resourceGroups/ERCrossSubTestRG/providers/Microsoft.Network/expressRouteCircuits/MyCircuit"  
$connection = New-AzureRmVirtualNetworkGatewayConnection -Name "ERConnection" -ResourceGroupName "RemoteResourceGroup" -Location "East US" -VirtualNetworkGateway1 $gw -PeerId $id -ConnectionType ExpressRoute -AuthorizationKey "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

# Releasing connection authorizations
# You can release an authorization by deleting the connection that links the ExpressRoute circuit to the virtual network.