declare @sql varchar(8000),
		@Schema sysname = 'Schema',
		@Table sysname = 'Table'

declare @c cursor 
set @c = cursor fast_forward for 
	select 'alter table ' + quotename(@Schema) + '.' + quotename(@Table) + ' drop constraint ' +  quotename(dc.name)
	--dc.name, c.name
	from sys.tables t 
		join sys.schemas s on s.schema_id = t.schema_id
		join sys.columns c on c.object_id = t.object_id
		join sys.default_constraints dc on dc.parent_column_id = c.column_id and dc.parent_object_id = t.object_id
	where t.name = @Table
		and s.name = @Schema
		and c.name in ('DF1', 'DF2', 'DF3')
open @c

fetch @c into @sql
while @@FETCH_STATUS = 0 begin

	print (@sql)
	fetch @c into @sql
end