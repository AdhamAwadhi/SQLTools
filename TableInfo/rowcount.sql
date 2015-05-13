select	distinct
		s.name, 
		t.name,
		p.rows,
		'EXEC sp_estimate_data_compression_savings ''dbo'', '''+t.name+''', NULL, NULL, ''PAGE'' ;', 
		'ALTER TABLE dbo.'+t.name + ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE); '
from sys.tables t with(nolock)
	join sys.schemas s  with(nolock) on s.schema_id = t.schema_id
	join sys.partitions p  with(nolock) on p.object_id = t.object_id
--where --index_id = 1
		--and t.name = ''
order by p.rows desc


