select m.physical_device_name
from msdb..restorehistory h
	join msdb..backupset s on s.backup_set_id = h.backup_set_id
	join msdb..backupmediafamily m on m.media_set_id = s.media_set_id
where h.destination_database_name = 'DBName'
order by restore_date desc