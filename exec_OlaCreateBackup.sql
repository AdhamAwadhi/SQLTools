exec adm.dbo.DatabaseBackup
	@Databases = 'USER_DATABASES',
	@Directory = 'N:\BACKUP',
	@BackupType = 'FULL',
	@Verify = 'Y',
	@Compress = 'Y',
	@CheckSum = 'Y',
	--@CleanupTime = 168, --one week
	@LogToTable = 'Y',
	@Execute = 'Y'
 --	@BufferCount = 50,
 --     @MaxTransferSize = 4194304,
 --     @NumberOfFiles = 48

