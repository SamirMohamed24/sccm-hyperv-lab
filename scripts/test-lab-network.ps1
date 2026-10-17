<#
.SYNOPSIS
  Tests the lab network layer by layer, to show exactly where traffic stops.
#>
$tests = [ordered]@{
    "pfSense LAN (10.10.10.2)" = { Test-Connection 10.10.10.2 -Count 1 -Quiet }
    "AD01 (10.10.10.11)"       = { Test-Connection 10.10.10.11 -Count 1 -Quiet }
    "Internet (8.8.8.8)"       = { Test-Connection 8.8.8.8 -Count 1 -Quiet }
    "DNS corp.lab"             = { [bool](Resolve-DnsName corp.lab -ErrorAction SilentlyContinue) }
    "DNS DC SRV record"        = { [bool](Resolve-DnsName _ldap._tcp.dc._msdcs.corp.lab -Type SRV -ErrorAction SilentlyContinue) }
    "DNS google.com"           = { [bool](Resolve-DnsName google.com -ErrorAction SilentlyContinue) }
}
foreach ($t in $tests.GetEnumerator()) {
    $ok = & $t.Value
    "{0,-28} {1}" -f $t.Key, $(if ($ok) { "OK" } else { "FAILED" })
}
