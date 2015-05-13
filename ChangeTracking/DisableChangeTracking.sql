--Generate disable script for all tables under change tracking
select 'alter table ' + quotename(s.name) +'.' + quotename(t.name) + ' disable change_tracking' 
from sys.change_tracking_tables CTT
	join sys.tables T on T.object_id = CTT.object_id
	join sys.schemas S on S.schema_id = T.schema_id
order by s.name, t.name

--Disable database change tracking
ALTER DATABASE DB SET CHANGE_TRACKING = OFF