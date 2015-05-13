select dc.name, c.name
from sys.tables t 
    join sys.schemas s on s.schema_id = t.schema_id
    join sys.columns c on c.object_id = t.object_id
    join sys.default_constraints dc on dc.parent_column_id = c.column_id and dc.parent_object_id = t.object_id
where t.name = 'TableName'
    and s.name = 'Schema'
    and c.name in ('')