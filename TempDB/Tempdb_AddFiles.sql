alter database tempdb 
modify file (
	Name = 'templog',
	--newname = 'tempdev_8',	
	--filename = 'E:\SQLData\TempDB\tempdev_8.ndf',
	Size = 1GB,
	FILEGROWTH = 512MB,
	MAXSIZE = unlimited
)

alter database tempdb 
add file (
	Name = 'tempdev_12',
	filename = 'Q:\SQLData\tempdev_12.ndf',
	Size = 1GB,
	FILEGROWTH = 512MB,
	MAXSIZE = unlimited
)


declare @sql nvarchar(4000) = '',
		@size int = 1,
		@MaxLogSize int = 24,
		@Step int = 4,
		@MaxFileCount int = 8,
		@CurentFileCount int = 2,
		@FileName nvarchar(4000) 

--Step-by-step TempDB log file increase
--while @size <= @MaxLogSize  begin
--	set @sql =  '	alter database tempdb 
--					modify file (
--						Name = ''templog'',
--						Size = ' + convert(nvarchar(10), @size) + 'GB,
--						FILEGROWTH = 512MB,
--						MAXSIZE = unlimited
--					)'
--	exec (@sql)
--	set @size += @Step
--end


while @CurentFileCount <= @MaxFileCount begin
	set @FileName = 'tempdev_' + convert(nvarchar(4000) , @CurentFileCount) 
	set @sql = '
alter database tempdb 
add file (
	Name = ' + @FileName + ',
	filename = ''F:\DATA\' + @FileName + '.ndf'',
	Size = 1GB,
	filegrowth= 512MB
					
);
go'
				--MAXSIZE = unlimited
	print (@sql)
	set @CurentFileCount += 1
end

select 'alter database tempdb modify file (name = ' + name +', filename = ''H:\TempDB\'+name+'.ndf'')' + char(10) + 'go' + char(10),
'alter database tempdb modify file (name = ' + name +', size = 64MB)' + char(10) + 'go' + char(10)
from tempdb.sys.database_files
where physical_name like '%tempdev%'



