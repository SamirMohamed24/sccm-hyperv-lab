<#
.SYNOPSIS
  Sets a static IP, gateway and DNS on a lab machine.
.EXAMPLE
  .\set-static-ip.ps1 -IPAddress 10.10.10.18                  # SC01
  .\set-static-ip.ps1 -IPAddress 10.10.10.20                  # WIN10
  .\set-static-ip.ps1 -IPAddress 10.10.10.11 -Dns 127.0.0.1   # AD01 (DC uses itself)
#>
param(
    [Parameter(Mandatory)][string]$IPAddress,
    [string]$InterfaceAlias = "Ethernet",
    [int]$PrefixLength      = 24,
    [string]$Gateway        = "10.10.10.2",
    [string[]]$Dns          = @("10.10.10.11")
)

New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $Dns
Set-TimeZone -Id "W. Europe Standard Time"
