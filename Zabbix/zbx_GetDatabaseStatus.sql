use Adm
go
set ansi_nulls on
set quoted_identifier on
go

if object_id('zbx.GetDatabaseStatus') is null exec ('create procedure zbx.GetDatabaseStatus as begin return end')
go
alter procedure zbx.GetDatabaseStatus
    @DatabaseName sysname
as begin
    set nocount on;
    select [state]
    from sys.databases
    where name = @DatabaseName
end
go

