-- 1. On Principal
alter database DatabaseName set recovery full

--1.1 Create FULL backup WITH FORMAT
--1.2 Create LOG BACKUP

-- 2. On Principal
CREATE ENDPOINT Endpoint_Mirroring
    STATE=STARTED 
    AS TCP (LISTENER_PORT=5022) 
    FOR DATABASE_MIRRORING (ROLE=PARTNER)
GO

-- 3. On Principal. SQL Server domain login. One for MIRROR instance and one for WITNESS
CREATE LOGIN [SQLServerAccount] FROM WINDOWS ;
GRANT CONNECT ON ENDPOINT::Endpoint_Mirroring TO [SQLServerAccount]

-- 4. On MIRROR
CREATE ENDPOINT Endpoint_Mirroring
    STATE=STARTED 
    AS TCP (LISTENER_PORT=5022) 
    FOR DATABASE_MIRRORING (ROLE=ALL)
GO

-- 5. On MIRROR. Create login and grant connect for PRINCIPAL instance and for WITNESS if need.
CREATE LOGIN [SQLServerAccount] FROM WINDOWS;
GRANT CONNECT ON ENDPOINT::Endpoint_Mirroring TO [SQLServerAccount]

-- 6. On Witness
CREATE ENDPOINT Endpoint_Mirroring
    STATE=STARTED 
    AS TCP (LISTENER_PORT=5022) 
    FOR DATABASE_MIRRORING (ROLE=WITNESS)
GO

-- 7. On Witness. Create login and grant connect for PRINCIPAL and MIRROR instances.
CREATE LOGIN [SQLServerAccount] FROM WINDOWS;
GRANT CONNECT ON ENDPOINT::Endpoint_Mirroring TO [SQLServerAccount]

-- 8. On MIRROR. Restore principal FULL and LOG database with NORECOVERY.

-- 9. On MIRROR
ALTER DATABASE [DatabaseName]
    SET PARTNER = 'TCP://PrimaryInstance:5022'
GO

-- 10. On Principal
ALTER DATABASE [DatabaseName]
    SET PARTNER = 'TCP://MirrorInstance:5022'
GO

-- 11. On Principal
ALTER DATABASE [DatabaseName]
    SET WITNESS = 'TCP://WitnessInstance:5022'
GO