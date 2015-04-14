--Source code from http://www.mssqltips.com/sqlservertip/2085/sql-server-ddl-triggers-to-track-all-database-changes/

use DDLLog
CREATE TABLE dbo.DDLEvents
(
    EventDate    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    EventType    NVARCHAR(64),
    EventDDL     NVARCHAR(MAX),
    EventXML     XML,
    DatabaseName NVARCHAR(255),
    SchemaName   NVARCHAR(255),
    ObjectName   NVARCHAR(255),
    HostName     VARCHAR(64),
    IPAddress    VARCHAR(32),
    ProgramName  NVARCHAR(255),
    LoginName    NVARCHAR(255),
    UserName    NVARCHAR(255)
);
