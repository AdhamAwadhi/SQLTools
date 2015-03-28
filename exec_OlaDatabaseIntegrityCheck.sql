exec adm.dbo.DatabaseIntegrityCheck
	@Databases = 'USER_DATABASES',
	@CheckCommands = 'CHECKDB',
	@ExtendedLogicalChecks = 'Y',
	@LogToTable = 'Y',
	@Execute = 'Y'

