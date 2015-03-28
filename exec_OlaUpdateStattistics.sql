EXECUTE adm.dbo.IndexOptimize
	@Databases = 'DB',
	@FragmentationLow = NULL,
	@FragmentationMedium = NULL,
	@FragmentationHigh = NULL,
	@UpdateStatistics = 'ALL'