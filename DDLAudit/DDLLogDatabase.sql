declare @DataPath sysname,
	   @LogPath sysname,
	   @sql nvarchar(4000)
SELECT @Datapath = convert(nvarchar(4000), SERVERPROPERTY('InstanceDefaultDataPath')),@LogPath = convert(nvarchar(4000), SERVERPROPERTY('InstanceDefaultLogPath'))


set @sql = 'create database DDLLog
on Primary (
	Name = ''DDLLog'',
	FileName = '''+ case when @@servername = 'Server' then 'D:\SQLData\' else  @DataPath end +'DDLLog.mdf'',
	Size = 100MB,
	MaxSize = unlimited,
	FileGrowth = 100mb
)
Log on (
	Name = ''DDLLog_log'',
	FileName = ''' + case when @@servername = 'Server' then 'L:\SQLLog\' else @LogPath end + 'DDLLog_log.ldf'',
	Size = 100mb,
	MaxSize = unlimited,
	FileGrowth = 100mb
)'

exec (@sql )
go

alter database DDLLog set recovery simple;
go
