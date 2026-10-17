# 6. Prerequisites and SCCM installation

## Server prerequisites on SC01

| Component | Notes |
|---|---|
| Windows Server roles | IIS (with the components the SCCM prerequisite checker asks for), BITS, Remote Differential Compression, .NET Framework |
| SQL Server 2019 | Collation `SQL_Latin1_General_CP1_CI_AS` (required by SCCM) |
| Windows ADK | **Deployment Tools** + **User State Migration Tool (USMT)** |
| Windows PE add-on | Same version as the ADK |

## Install roles and features

**Server Manager → Add Roles and Features** on SC01.

| Step | Select |
|---|---|
| Server role | **Web Server (IIS)** |
| Features | **.NET Framework 3.5** (incl. HTTP and Non-HTTP Activation), **ASP.NET 4.8**, **WCF Services** (all activations), **BITS** (IIS Server Extension, Compact Server), **Remote Differential Compression** |
| Optional role | **Windows Server Update Services**, for a later Software Update Point |
| IIS role services | **Windows Authentication**, **ASP.NET 3.5**, **IIS 6 Management Compatibility** (all four), **IIS Management Scripts and Tools**, **Management Service** |

![Web Server (IIS) role](../images/sc01/01-server-setup/12-role-web-server-iis.png)

![.NET Framework features](../images/sc01/01-server-setup/13-feature-net-framework.png)

![WCF Services activations](../images/sc01/01-server-setup/14-feature-wcf-services.png)

![BITS features](../images/sc01/01-server-setup/15-feature-bits.png)

![Remote Differential Compression](../images/sc01/01-server-setup/16-feature-rdc.png)

![IIS security: Windows Authentication](../images/sc01/01-server-setup/17-iis-security.png)

![IIS management tools](../images/sc01/01-server-setup/18-iis-management-tools.png)

![IIS application development: ASP.NET 3.5](../images/sc01/01-server-setup/19-iis-asp-net.png)

![Windows Server Update Services role](../images/sc01/01-server-setup/20-role-wsus.png)

## Install SQL Server 2019

Mount `SQLServer2019-x64-ENU.iso` and run **New SQL Server stand-alone installation**.

![SQL Server setup](../images/sc01/01-server-setup/21-setup-files.png)

1. **Feature Selection:** **Database Engine Services** only.

   ![Feature selection](../images/sc01/01-server-setup/22-feature-selection.png)

2. **Server Configuration → Collation:** `SQL_Latin1_General_CP1_CI_AS`. SCCM requires this collation.

   ![Collation SQL_Latin1_General_CP1_CI_AS](../images/sc01/01-server-setup/23-collation.png)

3. **Database Engine Configuration:** **Windows authentication mode**, and click **Add Current User** (`CORP\Administrator`) as SQL administrator.

   ![Database Engine Configuration](../images/sc01/01-server-setup/24-database-engine-config.png)

4. Finish the wizard. All features should show **Succeeded**.

   ![SQL Server installation complete](../images/sc01/01-server-setup/25-install-complete.png)

5. In **Services**, set **SQL Server (MSSQLSERVER) → Log On** to a domain account. The lab uses `CORP\Administrator`; in production use a dedicated service account. Restart the service.

   ![SQL Server service account](../images/sc01/01-server-setup/26-service-account.png)

## Install the Windows ADK and WinPE add-on

Download both installers from Microsoft Learn (*Download and install the Windows ADK*). They must be the **same release**.

1. Run **`adksetup.exe`** first and choose **Install the Windows Assessment and Deployment Kit to this computer**. Select:
   - ☑ Deployment Tools
   - ☑ User State Migration Tool (USMT)

   Imaging and Configuration Designer and Configuration Designer aren't needed for SCCM.

   ![ADK feature selection](../images/sc01/01-server-setup/27-adk-features.png)

2. Then run **`adkwinpesetup.exe`** with the default selection.

The ADK installs to `C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit`.

## Install the primary site

Run `E:\MEM\splash.hta` and choose **Install**.

1. **Getting Started:** **Install a Configuration Manager primary site**, tick **Use typical installation options**, and answer **Yes**.

   ![Install a primary site with typical options](../images/sc01/01-server-setup/28-getting-started.png)

2. **Product Key:** **Install the evaluation edition** (180 days).

   ![Evaluation edition](../images/sc01/01-server-setup/29-product-key.png)

3. **License Terms:** accept all three.

   ![License terms](../images/sc01/01-server-setup/30-license-terms.png)

4. **Prerequisite Downloads:** **Download required files** to `E:\SCCFiles`.

   ![Prerequisite downloads to E:\SCCFiles](../images/sc01/01-server-setup/31-prerequisite-downloads-path.png)

   ![Downloading the 49 prerequisite files](../images/sc01/01-server-setup/32-prerequisite-downloads-progress.png)

5. **Site and Installation Settings:** site code **GBG**, site name **Gothenburg**, and tick **Install the Configuration Manager console**.

   ![Site code GBG](../images/sc01/01-server-setup/33-site-settings.png)

6. **Prerequisite Check:** no item may be **Failed**. **Warnings** don't block the install. Click **Begin Install**.

   ![Prerequisite check with warnings only](../images/sc01/01-server-setup/34-prerequisite-check.png)

| Warning | Notes |
|---|---|
| SQL Server security mode | Advice to use Windows authentication only. Fine in the lab |
| Configuration for SQL Server memory usage | Set SQL min/max memory (below) |
| SQL Server process memory allocation | Wants 8 GB reserved for SQL. Acceptable in a lab with little RAM |

Optional SQL memory setting (roughly half of SC01's memory):

```sql
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 4096; RECONFIGURE;
EXEC sp_configure 'min server memory (MB)', 2048; RECONFIGURE;
```

The full results are in `C:\ConfigMgrPrereq.log`.

| Setting | Value |
|---|---|
| Install type | Stand-alone primary site, evaluation |
| Site code | `GBG` |
| Site name | `Gothenburg` |
| Site server | `sc01.corp.lab` |
| Database | Local SQL Server, database `CM_GBG` |
| Roles on SC01 | Management point, distribution point |

When setup finishes, the console title shows *Connected to GBG, Gothenburg – sc01.corp.lab*. Under **Administration → Site Configuration → Sites**, the site shows **State: Site Active**, build **9049** (Configuration Manager 2103, evaluation).

![Site GBG active on sc01.corp.lab](../images/sc01/01-server-setup/35-site-gbg-active.png)

## Post-install: SQL scalar UDF inlining

On SQL Server 2019/2022, turn off scalar UDF inlining for the SCCM database. Without it, the console can fail when you create applications:

```
sqlcmd -S localhost -E -d CM_GBG -Q "ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF;"
```

See [scripts/sql-disable-udf-inlining.sql](../scripts/sql-disable-udf-inlining.sql).

---
Next: [7. Boundaries, boundary groups and discovery](07-boundaries-discovery.md)
