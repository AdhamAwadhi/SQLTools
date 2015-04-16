--who use database
select 'kill ' + CONVERT(varchar(10), spid),
		*
from sys.sysprocesses
where db_name(dbid) = 'dbname'
	and spid>50