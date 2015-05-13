create database DBName
on Primary (
	Name = 'DBName',
	FileName = 'D:\SQLData\DBName.mdf',
	Size = 1GB,
	MaxSize = unlimited,
	FileGrowth = 512mb
)
Log on (
	Name = 'DBName_log',
	FileName = 'L:\SQLLog\DBName_log.ldf',
	Size = 256mb,
	MaxSize = unlimited,
	FileGrowth = 512mb
)
go
alter database DBName set recovery simple;
go
