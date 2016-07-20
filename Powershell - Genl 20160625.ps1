
#Import Custom Module
# Import-Module '\\hqrdata01\mis\Shared MIS\IS\Infra & Ops\NST\5 - Projects\01 - In Progress\Cloud 2014\Azure\Powershell\NSG\AzureCustomNetworkSecurityGroup\AzureCustomNetworkSecurityGroup.ps1'
# Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1'

Import-Module 'C:\AzureNSG\Powershell\Modules\AzureCustomRMNetworkSecurityGroup.ps1'
$subscription = "Sandbox POC Network"
$vnet = "NPOC_V2_CoreServices_Ams"

$location = "West Europe"

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
# Select-AzureSubscription -SubscriptionName "$subscription"
Select-AzureRmSubscription -SubscriptionName $subscription


#Create NSG
# creare RG ahead of time
New-AzureRmCustomNetworkSecurityGroup -CSVPath C:\AzureNSG\$subscription\DMZ-Core-Web001.csv -AzureLocation $location -ResourceGroupName RG-NSG-DMZ-Core001 -NetworkSecurityGroupName NSG-DMZ-Core-Web001 -Tags @{Name="Environment";Value="Sandbox"} -PassThru
New-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-WebTier.csv" -NetworkSecurityGroupName "DMZ-WebTier" -AzureLocation "$location" -NetworkSecurityGroupLabel "This contains the rules for the Virtual Subnet DMZ-WebTier"
New-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-MiddleWare.csv" -NetworkSecurityGroupName "DMZ-Middleware" -AzureLocation "$location" -NetworkSecurityGroupLabel "This contains the rules for the Virtual Subnet DMZ-MiddleWare"
New-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-IS Infrastructure.csv" -NetworkSecurityGroupName "DMZ-IS Infrastructure" -AzureLocation "$location" -NetworkSecurityGroupLabel "This contains the rules for the Virtual Subnet DMZ-ActiveDirectory"

#Update NSG
Update-AzureRmCustomNetworkSecurityGroup -CSVPath C:\AzureNSG\$subscription\DMZ-Core-Web001.csv -ResourceGroupName RG-NSG-DMZ-Core001 -NetworkSecurityGroupName NSG-DMZ-Core-Web001 -Tags @{Name="Environment";Value="Sandbox"} -PassThru
Update-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-WebTier.csv" -NetworkSecurityGroupName "DMZ-WebTier"
Update-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-MiddleWare.csv" -NetworkSecurityGroupName "DMZ-MiddleWare"
Update-AzureCustomNetworkSecurityGroup -CSVPath "C:\NSG\$subscription\Development-DMZ-IS Infrastructure.csv" -NetworkSecurityGroupName "DMZ-IS Infrastructure"

#Apply to Subnet
#To apply the NSG:
# For a subnet: 
Set-AzureNetworkSecurityGroupToSubnet -Name "NSG-DMZ-Core-Web001" -VirtualNetworkName "NPOC_V2_CoreServices_Ams" -SubnetName "DMZ-Core-Web001"
Set-AzureNetworkSecurityGroupAssociation -Name "NSG-DMZ-Core-Web001" -VirtualNetworkName "NPOC_V2_CoreServices_Ams" -SubnetName "DMZ-Core-Web001"
Set-AzureNetworkSecurityGroupAssociation
#Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork "NPOC_V2_CoreServices_Ams" -Name "DMZ-Core-Web001" -NetworkSecurityGroup "NSG-DMZ-Core-Web001"
# For a VM: Get-AzureVM -ServiceName "DMZ" -Name "DMZ-WEB01" | Set-AzureNetworkSecurityGroupConfig -NetworkSecurityGroupName "VS-DMZ-NSG" | Update-AzureVM
##### 
Set-AzureNetworkSecurityGroupToSubnet -Name "DMZ-WebTier" -SubnetName "DMZ-WebTier" -VirtualNetworkName "$vnet"
Set-AzureNetworkSecurityGroupToSubnet -Name "DMZ-MiddleWare" -SubnetName "DMZ-Middleware" -VirtualNetworkName "$vnet"
Set-AzureNetworkSecurityGroupToSubnet -Name "DMZ-IS Infrastructure" -SubnetName "DMZ-IS Infrastructure" -VirtualNetworkName "$vnet"

# ARM commands
get-azurermnetworksecuritygroup
Get-AzureNetworkSecurityGroupForSubnet -VirtualNetworkName "NPOC_V2_CoreServices_Ams" -SubnetName "DMZ-Core-Web001"
Remove-AzureNetworkSecurityGroupFromSubnet 

NSG-DMZ-Core-Web001
RG-NSG-DMZ-Core001
Name              : NPOC_V2_CoreServices_Ams
ResourceGroupName : RG-V2-Default-Networking-Ams
"DMZ-Core-Web001"
NPOC_V2_CoreServices_Ams/subnets/DMZ-Core-Web001"

