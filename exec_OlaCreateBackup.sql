exec adm.dbo.DatabaseBackup
	@Databases = 'DB',
	@Directory = '\\Backup1\BACKUP',
	@BackupType = 'FULL',
	@Verify = 'Y',
	@Compress = 'Y',
	@CheckSum = 'Y',
	@CleanupTime = 168, --one week
	@LogToTable = 'Y',
	@Execute = 'Y'

