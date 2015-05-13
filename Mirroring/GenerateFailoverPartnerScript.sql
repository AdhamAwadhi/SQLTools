select 'alter database ' + QUOTENAME( d.name) + ' set partner failover'
from sys.database_mirroring m
    join sys.databases d on d.database_id = m.database_id 
where m.mirroring_guid is not null