$svc="AZUSQDSP010"
$ilb="ILB_AZUSQDSP010"
$subnet="DMZ-ProxyInfrastructure"
$IP="10.3.69.200"
Add-AzureInternalLoadBalancer -ServiceName $svc -InternalLoadBalancerName $ilb –SubnetName $subnet –StaticVNetIPAddress $IP


Add first VM

$svc="AZUSQDSP010"
$vmname="AZUSQDSP010"
$epname="HTTP"
$prot="tcp"
$locport=80
$pubport=80
$ilb="ILB_AZUSQDSP010"
Get-AzureVM –ServiceName $svc –Name $vmname | Add-AzureEndpoint -Name $epname -Protocol $prot -LocalPort $locport -PublicPort $pubport –DefaultProbe -InternalLoadBalancerName $ilb -LBSetName HTTP-ILB –LoadBalancerDistribution “sourceIP” | Update-AzureVM

Add second VM

$svc="AZUSQDSP010"
$vmname="AZUSQDSP011"
$epname="HTTP"
$prot="tcp"
$locport=80
$pubport=80
$ilb="ILB_AZUSQDSP010"
Get-AzureVM –ServiceName $svc –Name $vmname | Add-AzureEndpoint -Name $epname -Protocol $prot -LocalPort $locport -PublicPort $pubport –DefaultProbe -InternalLoadBalancerName $ilb -LBSetName HTTP-ILB –LoadBalancerDistribution “sourceIP” | Update-AzureVM



Add first VM

$svc="AZUSQDSP010"
$vmname="AZUSQDSP010"
$epname="SQUID"
$prot="tcp"
$locport=3128
$pubport=3128
$ilb="ILB_AZUSQDSP010"
Get-AzureVM –ServiceName $svc –Name $vmname | Add-AzureEndpoint -Name $epname -Protocol $prot -LocalPort $locport -PublicPort $pubport –DefaultProbe -InternalLoadBalancerName $ilb -LBSetName SQUID-ILB –LoadBalancerDistribution “sourceIP” | Update-AzureVM

Add second VM

$svc="AZUSQDSP010"
$vmname="AZUSQDSP011"
$epname="SQUID"
$prot="tcp"
$locport=3128
$pubport=3128
$ilb="ILB_AZUSQDSP010"
Get-AzureVM –ServiceName $svc –Name $vmname | Add-AzureEndpoint -Name $epname -Protocol $prot -LocalPort $locport -PublicPort $pubport –DefaultProbe -InternalLoadBalancerName $ilb -LBSetName SQUID-ILB –LoadBalancerDistribution “sourceIP” | Update-AzureVM


Check Status of VIP

Get-AzureVM –ServiceName AZUSQDSP010 –Name AZUSQDSP010 | Get-AzureEndpoint


Configure iLB resiliency after the fact

Set-AzureLoadBalancedEndpoint -ServiceName "AZUSQDSP010" -LBSetName "HTTP-ILB" -Protocol tcp -LocalPort 80 -ProbeProtocolTCP –LoadBalancerDistribution "sourceIP"
Set-AzureLoadBalancedEndpoint -ServiceName "AZUSQDSP010" -LBSetName "SQUID-ILB" -Protocol tcp -LocalPort 3128 -ProbeProtocolTCP –LoadBalancerDistribution "sourceIP"