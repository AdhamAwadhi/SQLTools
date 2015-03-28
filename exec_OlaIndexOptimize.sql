exec adm.dbo.IndexOptimize 
	@Databases = 'DB',
	@FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = 5,
	@FragmentationLevel2 = 30,
	@SortInTempdb = 'N',
	@MaxDOP = 4,
	@Execute = 'Y',
	@LogToTable = 'Y',
	@LockTimeout = '300'