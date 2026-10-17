<#
.SYNOPSIS
  Creates an internal Hyper-V switch with NAT, as a fixed alternative to the Default Switch.
.NOTES
  Run on the Hyper-V HOST as administrator. Give pfSense WAN 192.168.100.2/24, gateway 192.168.100.1.
#>
param(
    [string]$SwitchName = "NAT-WAN",
    [string]$GatewayIP  = "192.168.100.1",
    [int]$PrefixLength  = 24,
    [string]$Prefix     = "192.168.100.0/24"
)

New-VMSwitch -Name $SwitchName -SwitchType Internal
New-NetIPAddress -InterfaceAlias "vEthernet ($SwitchName)" -IPAddress $GatewayIP -PrefixLength $PrefixLength
New-NetNat -Name $SwitchName -InternalIPInterfaceAddressPrefix $Prefix
