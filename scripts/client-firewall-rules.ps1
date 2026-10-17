<#
.SYNOPSIS
  Opens the firewall rules SCCM client push needs. Run on each client as administrator.
.NOTES
  In production, push these with Group Policy instead.
#>
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
