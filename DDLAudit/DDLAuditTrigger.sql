--Source code from http://www.mssqltips.com/sqlservertip/2085/sql-server-ddl-triggers-to-track-all-database-changes/

CREATE TRIGGER tr_Log_DDL_cmds
    ON ALL SERVER
    WITH EXECUTE AS 'sa'
    FOR DDL_DATABASE_LEVEL_EVENTS 
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
        @EventData XML = EVENTDATA();
 
    DECLARE 
        @ip VARCHAR(32) =
        (
            SELECT client_net_address
                FROM sys.dm_exec_connections
                WHERE session_id = @@SPID
        );
 
    INSERT DDLLog.dbo.DDLEvents
    (
        EventType,
        EventDDL,
        EventXML,
        DatabaseName,
        SchemaName,
        ObjectName,
        HostName,
        IPAddress,
        ProgramName,
        LoginName,
	   UserName
    )
    SELECT
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
        @EventData,
        @EventData.value('(/EVENT_INSTANCE/DatabaseName)[1]',  'NVARCHAR(255)'), 
        @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),
        HOST_NAME(),
        @ip,
        PROGRAM_NAME(),
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]',  'NVARCHAR(255)'),
	   @EventData.value('(/EVENT_INSTANCE/UserName)[1]',  'NVARCHAR(255)')
END
GO