select r.*
from sys.dm_exec_connections c 
	join sys.dm_exec_sessions s on s.session_id = c.session_id
	join sys.dm_exec_requests r on r.session_id = s.session_id
where s.program_name like  'Pur%'