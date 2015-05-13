select	
		s.name as SchemeName,
		t.name as TableName,
		c.name as ColumnName,
		p.name + ' (' + case when c.max_length = -1 then 'max' else convert(varchar, c.max_length) end + ')' as ColumnType,
		c.is_nullable,
		c.*,
		'[' + c.name + '] ' +p.name + 
				case when p.name not in ('int', 'bit', 'smallint', 'tinyint', 'datetime', 'image', 'timestamp') then ' (' + case when c.max_length = -1 then 'max' else convert(varchar, c.max_length) end + ') ' else '' end 
				
				+ 
			case when c.is_nullable = 1 then ' null' else ' not null' end + ','
from sys.tables t 
	join sys.columns c on c.object_id = t.object_id
	join sys.schemas s on s.schema_id = t.schema_id
	join sys.types p on p.system_type_id = c.system_type_id and p.user_type_id = c.user_type_id
where t.name = 'Tab4leName'
order by s.name, t.name, c.column_id

--select top 100 *
--from sys.columns