-- Optional: sets SQL Server memory limits for the SCCM prerequisite check.
-- Adjust to roughly half of SC01's RAM.
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 4096; RECONFIGURE;
EXEC sp_configure 'min server memory (MB)', 2048; RECONFIGURE;
