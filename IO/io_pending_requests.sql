select r.io_handle_path,
		count(*)
from sys.dm_io_pending_io_requests r
group by r.io_handle_path
order by 2 desc