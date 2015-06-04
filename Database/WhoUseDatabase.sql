--who use database
select 'kill ' + CONVERT(varchar(10), spid),
		db_name(dbid)
from sys.sysprocesses
where db_name(dbid) in ('distribution')
	and spid>50
