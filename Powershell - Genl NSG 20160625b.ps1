
#Import Custom Module
# Import-Module '\\hqrdata01\mis\Shared MIS\IS\Infra & Ops\NST\5 - Projects\01 - In Progress\Cloud 2014\Azure\Powershell\NSG\AzureCustomNetworkSecurityGroup\AzureCustomNetworkSecurityGroup.ps1'
# Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1'
Import-Module 'C:\AzureNSG\Powershell\Modules\AzureCustomRMNetworkSecurityGroup.ps1'

$subscription = "Sandbox POC Network"
$vnet = "NPOC_V2_CoreServices_Ams"
$location = "West Europe"
$RGname = "RG-NSG-DMZ-Core001"

if ($subscription -eq "ProductionA2" -OR $vnet -eq "DCCASIS-AMS") {
    $Location = "West Europe"
}
 else {
    $location = "North Europe"
}

# Login to Azure
Login-AzureRmAccount
Get-AzureRmSubscription 

#Select Subscription
Select-AzureRmSubscription -SubscriptionName $subscription

# Create RG ahead of time
# Create NSG v2
New-AzureRmCustomNetworkSecurityGroup -CSVPath C:\AzureNSG\$subscription\DMZ-Core-Web001.csv -AzureLocation $location -ResourceGroupName RG-NSG-DMZ-Core001 -NetworkSecurityGroupName NSG-DMZ-Core-Web001 -Tags @{Name="Environment";Value="Sandbox"} -PassThru

# v1 # New-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-WebTier.csv" -NetworkSecurityGroupName "DMZ-WebTier" -AzureLocation "$location" -NetworkSecurityGroupLabel "This contains the rules for the Virtual Subnet DMZ-WebTier"
# v1 # New-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-MiddleWare.csv" -NetworkSecurityGroupName "DMZ-Middleware" -AzureLocation "$location" -NetworkSecurityGroupLabel "This contains the rules for the Virtual Subnet DMZ-MiddleWare"
# v1 # New-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-IS Infrastructure.csv" -NetworkSecurityGroupName "DMZ-IS Infrastructure" -AzureLocation "$location" -NetworkSecurityGroupLabel "This contains the rules for the Virtual Subnet DMZ-ActiveDirectory"

#Update NSG
Update-AzureRmCustomNetworkSecurityGroup -CSVPath C:\AzureNSG\$subscription\DMZ-Core-Web001.csv -ResourceGroupName RG-NSG-DMZ-Core001 -NetworkSecurityGroupName NSG-DMZ-Core-Web001 -Tags @{Name="Environment";Value="Sandbox"} -PassThru

# v1 # Update-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-WebTier.csv" -NetworkSecurityGroupName "DMZ-WebTier"
# v1 # Update-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-MiddleWare.csv" -NetworkSecurityGroupName "DMZ-MiddleWare"
# v1 # Update-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-IS Infrastructure.csv" -NetworkSecurityGroupName "DMZ-IS Infrastructure"

#Apply NSG to Subnet
#To apply the NSG:
# For a subnet: 
Set-AzureNetworkSecurityGroupToSubnet -Name "NSG-DMZ-Core-Web001" -VirtualNetworkName "NPOC_V2_CoreServices_Ams" -SubnetName "DMZ-Core-Web001"
# Set-AzureNetworkSecurityGroupAssociation -Name "NSG-DMZ-Core-Web001" -VirtualNetworkName "NPOC_V2_CoreServices_Ams" -SubnetName "DMZ-Core-Web001"

#Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork "NPOC_V2_CoreServices_Ams" -Name "DMZ-Core-Web001" -NetworkSecurityGroup "NSG-DMZ-Core-Web001"
# For a VM: Get-AzureVM -ServiceName "DMZ" -Name "DMZ-WEB01" | Set-AzureNetworkSecurityGroupConfig -NetworkSecurityGroupName "VS-DMZ-NSG" | Update-AzureVM
##### 
Set-AzureNetworkSecurityGroupToSubnet -Name "DMZ-WebTier" -SubnetName "DMZ-WebTier" -VirtualNetworkName "$vnet"
Set-AzureNetworkSecurityGroupToSubnet -Name "DMZ-MiddleWare" -SubnetName "DMZ-Middleware" -VirtualNetworkName "$vnet"
Set-AzureNetworkSecurityGroupToSubnet -Name "DMZ-IS Infrastructure" -SubnetName "DMZ-IS Infrastructure" -VirtualNetworkName "$vnet"

# ARM commands
Get-AzureRmNetworkSecurityGroup
Get-AzureNetworkSecurityGroupForSubnet -VirtualNetworkName "NPOC_V2_CoreServices_Ams" -SubnetName "DMZ-Core-Web001"
Get-AzureRmNetworkSecurityGroup -Name "NSG-DMZ-Core-Web001" -ResourceGroupName $RGname
Remove-AzureNetworkSecurityGroupFromSubnet 



##################
##################
# Manual NSG rules format
# NSG rule allowing access from the Internet to port 3389.
$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389	

# NSG rule allowing access from the Internet to port 80.
	
$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
    -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
	
# Add the rules created above to a new NSG named NSG-FrontEnd.
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName TestRG -Location "west europe" -Name "NSG-FrontEnd" -SecurityRules $rule1,$rule2

# Check the rules created in the NSG.
$nsg

# Associate the NSG created above to the FrontEnd subnet.
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name FrontEnd -AddressPrefix 192.168.1.0/24 -NetworkSecurityGroup $nsg
	
# The output for the command above shows the content for the virtual network configuration object, which only exists on the computer where you are running
# PowerShell. You need to run the Set-AzureRmVirtualNetwork cmdlet to save these settings to Azure.

# Save the new VNet settings to Azure.
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

