use Adm
go
set ansi_nulls on
set quoted_identifier on
go

if object_id('dbo.DatabaseRoleMembership') is null exec ('create procedure dbo.DatabaseRoleMembership as begin return end')
go
alter procedure dbo.DatabaseRoleMembership   
as begin
    set nocount on;

    declare @T table (DatabaseName sysname null, DatabaseRole sysname null, DatabaseUser sysname null, M int)
    declare @sql varchar(max) = ''


    select @sql += 'select '''+name+''' as DatabaseName,
		  r.name collate Cyrillic_General_CI_AS as DatabaseRole,
		  p.Name collate Cyrillic_General_CI_AS as DatabaseUser,
		  case when p.name is not null then 1 end as M
    from '+name+'.sys.database_principals r
	   left join '+name+'.sys.database_role_members rm on rm.role_principal_id = r.principal_id
	   left join '+name+'.sys.database_principals p on p.principal_id = rm.member_principal_id
    where r.type_desc = ''DATABASE_ROLE'' union all
    '
    from sys.databases 
    where state_desc = 'ONLINE'

    set @sql = left(@sql, len(@sql) - 11)

    insert @T
    exec(@sql)

    select *
    from @T


end
go


