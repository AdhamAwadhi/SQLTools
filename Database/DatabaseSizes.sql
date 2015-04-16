select	F.database_id,
		d.name as DBName,
		F.Name as FileName,
		F.physical_name,
		F.type_desc,
		convert(decimal(12,2), round(F.size * 8. / 1024 / 1024 , 2)) as [FileSize (Gb)],
		d.recovery_model_desc,
		f.growth * 8. / 1024 as FileGrowthMB,
		f.max_size * 8. / 1024 MaxSizeMB,
		f.is_percent_growth,
		d.log_reuse_wait_desc,
		d.snapshot_isolation_state_desc,
		d.is_read_committed_snapshot_on,
		d.page_verify_option_desc,
		d.is_auto_create_stats_on,
		d.is_auto_update_stats_on,
		d.is_auto_update_stats_async_on,
		d.snapshot_isolation_state_desc,
		d.is_read_committed_snapshot_on
		--'alter database ' + d.name + ' set recovery simple',
		--'alter database ' + d.name + ' modify file (name = '''+ F.Name +''', newname = ''' + d.name + case when F.type_desc = 'LOG' then '_log' else '' end +''')',
		--'alter database ' + d.name + ' modify file (name = '''+ F.Name +''', filegrowth = 128MB, maxsize = unlimited)',
		--'use ' + d.name+ '; dbcc shrinkfile(' + F.Name + ', TRUNCATEONLY)'
from sys.master_files f
	join sys.databases d on d.database_id = f.database_id
where d.database_id > 4
	and d.state_desc = 'ONLINE'
	--and f.type_desc = 'LOG'
	--and d.recovery_model_desc = 'SIMPLE'
	--and F.name != d.name + case when F.type_desc = 'LOG' then '_log' else '' end
order by d.name, f.type_desc desc
--order by [FileSize (Gb)] desc





