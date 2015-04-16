use DB
DBCC SHRINKFILE (DBName_log, truncateonly)

alter database DBName
modify file (
	name = 'DBName_log',
	size = 100MB,
	filegrowth = 100MB,
	maxsize = unlimited
)