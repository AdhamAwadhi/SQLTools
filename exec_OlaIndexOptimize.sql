exec adm.dbo.IndexOptimize 
	@Databases = 'ALL_DATABASES',
	@FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = 5,
	@FragmentationLevel2 = 30,
	@SortInTempdb = 'N',
	@Execute = 'Y',
	@LogToTable = 'Y',
	@LockTimeout = '300'