create database DDLLog
on Primary (
	Name = 'DDLLog',
	FileName = 'F:\DATA\DDLLog.mdf',
	Size = 100MB,
	MaxSize = unlimited,
	FileGrowth = 100mb
)
Log on (
	Name = 'DDLLog',
	FileName = 'E:\LOG\DDLLog_log.ldf',
	Size = 100mb,
	MaxSize = unlimited,
	FileGrowth = 100mb
)
go
alter database DDLLog set recovery simple;
go
