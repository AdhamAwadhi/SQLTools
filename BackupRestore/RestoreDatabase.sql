RESTORE FILELISTONLY FROM  DISK =  '\\Backup\DBBackup.bak'

restore database  DB
from disk = '\\Backup\DBBackup.bak'  
with file = 1,
	move 'data' to 'D:\SQLData\DB.mdf',
	move 'log' to 'L:\SQLLog\DB_log.ldf',	
	STATS = 2,			
	checksum
	,norecovery
	--,replace
	--,standby = 'D:\SQLData\DB.tuf',	

restore log DB
from disk = '\\Backup\DBBackup.trn'
with file = 1,
	stats = 10
	,checksum
	,norecovery
	--,stopat = '2014-02-17 14:10:00.000'
	--,standby = 'D:\SQLData\DB.tuf'	



restore database DB with recovery
alter database DB set recovery simple
