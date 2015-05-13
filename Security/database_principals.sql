

select	r.name as RoleName,
		p.name as MemberName,
		sp.name as ServerPrincipalName
from sys.database_principals p
	left join sys.server_principals sp on sp.sid = p.sid
	left join sys.database_role_members m on m.member_principal_id = p.principal_id
	left join sys.database_principals r on r.principal_id = m.role_principal_id
where p.type not in ('U', 'S')

select *
from adm.sec.MemberInDatabaseRoles p
	--join sys.server_principals pp on pp.name = p.serverprincipalname and pp.is_disabled = 0

pivot (
	count(p.ID) 
	for p.DatabaseRole in ([db_accessadmin],[db_backupoperator],[db_datareader],[db_datawriter],[db_ddladmin],[db_denydatareader],[db_denydatawriter],[db_executor],
				[db_owner],[db_securityadmin],[public],[u_supp_speditor],[u_supp_spexecutor])
) as Pvt
where pvt.ServerPrincipalName is not null
order by 2,1

create table adm.sec.DatabaseRoles (Name sysname)
create table adm.sec.MemberInDatabaseRoles (ID int identity not null, DatabaseName sysname, ServerPrincipalName sysname null, DatabasePrincipalName sysname null, DatabaseRole sysname null)

select 'use ' + QUOTENAME(d.name) + '; insert adm.sec.DatabaseRoles select p.Name from sys.database_principals p where p.type = ''R'' and p.name collate Cyrillic_General_CI_AS  not in (select name from adm.sec.DatabaseRoles) '
from sys.databases d
where d.state_desc = 'ONLINE'
	and d.database_id > 4
	
select 'use ' + QUOTENAME(d.name) + '; insert adm.sec.MemberInDatabaseRoles (DatabaseName, ServerPrincipalName, DatabasePrincipalName, DatabaseRole)
	select	DB_NAME(),
			sp.name as ServerPrincipalName,
			p.name as MemberName,
			r.name as RoleName
	from sys.database_principals p
		left join sys.server_principals sp on sp.sid = p.sid
		left join sys.database_role_members m on m.member_principal_id = p.principal_id
		left join sys.database_principals r on r.principal_id = m.role_principal_id
	where p.type in (''U'', ''S'')'
from sys.databases d
where d.state_desc = 'ONLINE'
	and d.database_id > 4


declare @x varchar(1000) = ''
select @x += quotename(name) + ','

from (
	select distinct *
	from adm.sec.DatabaseRoles
	
	) A

select @x

select distinct 
		r.dataBasename,
		r.DatabasePrincipalName,
		r.DatabaseRole,
		
		
		'use ' + QUOTENAME(r.dataBasename) + '; alter role ' + QUOTENAME(r.DatabaseRole) + ' drop member ' + QUOTENAME(r.DatabasePrincipalName)  + '; ' as [Drop from dbo],
		'use ' + QUOTENAME(r.dataBasename) + '; alter role [db_datareader] add member ' + QUOTENAME(r.DatabasePrincipalName)  + '; ' as [Add to readers],
		'use ' + QUOTENAME(r.dataBasename) + '; alter role [db_datawriter] add member ' + QUOTENAME(r.DatabasePrincipalName)  + '; ' as [Add to writers],
		'use ' + QUOTENAME(r.dataBasename) + '; alter role [db_executor] add member ' + QUOTENAME(r.DatabasePrincipalName)  + '; '+CHAR(10) + CHAR(13)+' go' as [Add to executors]
from adm.sec.MemberInDatabaseRoles R
	join sys.server_principals p on p.name = r.serverprincipalname and p.is_disabled = 0
	left join sys.server_role_members m on m.member_principal_id = p.principal_id
	left join sys.server_principals rr on rr.principal_id = m.role_principal_id and rr.name != 'sysadmin' 
where  r.databaseRole = 'db_securityadmin'
	and r.DatabasePrincipalName not in ('dbo')
order by 2,1


