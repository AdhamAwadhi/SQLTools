select	SUSER_SNAME(owner_sid),
		'ALTER AUTHORIZATION ON DATABASE::'+name+' to sa;',
		*
from sys.databases
where  SUSER_SNAME(owner_sid) = 'login' 