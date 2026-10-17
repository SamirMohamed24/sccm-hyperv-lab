# Scripts

| Script | Run on | Purpose |
|---|---|---|
| `host-create-nat-switch.ps1` | Hyper-V host | Internal NAT switch as an alternative to the Default Switch |
| `set-static-ip.ps1` | AD01, SC01, WIN10 | Static IP, gateway, DNS and time zone |
| `test-lab-network.ps1` | Any lab machine | Tests pfSense, AD01, internet and DNS step by step |
| `join-domain.ps1` | SC01, WIN10 | Joins `corp.lab` |
| `client-firewall-rules.ps1` | Clients | Firewall rules for SCCM client push |
| `sql-disable-udf-inlining.sql` | SC01 | Recommended SQL setting for the SCCM database |
| `sql-memory-settings.sql` | SC01 | Optional SQL memory limits |

Run PowerShell scripts as administrator. If execution policy blocks them: `Set-ExecutionPolicy -Scope Process Bypass`.
