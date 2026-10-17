<#
.SYNOPSIS
  Joins the machine to corp.lab and restarts. Check DNS first with test-lab-network.ps1.
#>
param([string]$Domain = "corp.lab", [string]$User = "CORP\Administrator")
Add-Computer -DomainName $Domain -Credential $User -Restart
