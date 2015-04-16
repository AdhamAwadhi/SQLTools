EXECUTE adm.dbo.IndexOptimize
	@Databases = 'ALL_DATABASES',
	@FragmentationLow = NULL,
	@FragmentationMedium = NULL,
	@FragmentationHigh = NULL,
	@UpdateStatistics = 'ALL',
	@OnlyModifiedStatistics = 'Y',
	@Execute = 'Y',
	@LogToTable = 'N',
	@LockTimeout = '300'