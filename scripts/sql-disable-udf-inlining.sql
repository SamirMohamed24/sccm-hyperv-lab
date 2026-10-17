-- Recommended for SCCM on SQL Server 2019/2022:
-- turns off scalar UDF inlining for the site database.
-- Run with: sqlcmd -S localhost -E -i sql-disable-udf-inlining.sql
USE CM_GBG;
GO
ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF;
GO
-- value should be 0
SELECT name, value FROM sys.database_scoped_configurations
WHERE name = 'TSQL_SCALAR_UDF_INLINING';
GO
