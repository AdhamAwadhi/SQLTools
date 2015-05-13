select *
from adm.dbo.CommandLog
--where CommandType = 'xp_delete_file'
--	and DatabaseName = 'fintender_documentstorage' 
--where [ERRORNUMBER] is not null and [ERRORNUMBER] > 0
order by 1 desc


select	L.DatabaseName,
		L.CommandType,
		L.Command,
		L.StartTime,
		L.EndTime,
		datediff(second, L.StartTime, L.EndTime) as [Duration (Sec)],
		L.ErrorNumber,
		L.ErrorMessage
from adm.dbo.CommandLog L
--where CommandType = 'xp_delete_file'
--	and DatabaseName = 'fintender_documentstorage' 
--where [ERRORNUMBER] is not null and [ERRORNUMBER] > 0
order by L.ID desc