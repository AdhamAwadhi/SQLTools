use Adm
go
set ansi_nulls on
set quoted_identifier on
go

if object_id('zbx.GetSQLVersion') is null exec ('create procedure zbx.GetSQLVersion as begin return end')
go
alter procedure zbx.GetSQLVersion
as begin
    set nocount on
    
    select serverproperty('productversion')
    union
    select serverproperty('edition') 
    order by 1 

end
go



