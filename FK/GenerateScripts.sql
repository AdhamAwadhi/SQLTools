--select *
--from sys.foreign_keys k
--where 'CASCADE'  in (k.delete_referential_action_desc, k.update_referential_action_desc) 
--order by 1 


--CREATE TABLE #x -- feel free to use a permanent table
--(
--  drop_script NVARCHAR(MAX),
--  create_script NVARCHAR(MAX)
--);
  
DECLARE @drop   NVARCHAR(MAX) = N'',
        @create NVARCHAR(MAX) = N'';

-- drop is easy, just build a simple concatenated list from sys.foreign_keys:
SELECT char(10) + N'if exists (select  1 
			from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			where TABLE_NAME = '''+ ct.name +''' 
			and TABLE_SCHEMA ='''+ cs.name +''' 
			and CONSTRAINT_NAME = '''+fk.name +'''
			and CONSTRAINT_TYPE = ''FOREIGN KEY'') begin 
	 ALTER TABLE ' + QUOTENAME(cs.name) + '.' + QUOTENAME(ct.name) 
    + ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + '; ' + char(10)+ 'end'
FROM sys.foreign_keys AS fk 
	INNER JOIN sys.tables AS ct ON fk.parent_object_id = ct.[object_id]
	INNER JOIN sys.schemas AS cs ON ct.[schema_id] = cs.[schema_id]
where fk.delete_referential_action_desc != 'NO_ACTION' 
	or  fk.update_referential_action_desc != 'NO_ACTION'
--order by cs.name, ct.name
--INSERT #x(drop_script) SELECT @drop;

-- create is a little more complex. We need to generate the list of 
-- columns on both sides of the constraint, even though in most cases
-- there is only one column.
union all

SELECT char(10) + N'if not exists (	select  1 
					from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
					where TABLE_NAME = '''+ ct.name +''' 
					and TABLE_SCHEMA ='''+ cs.name +''' 
					and CONSTRAINT_NAME = '''+fk.name +''' 
					and CONSTRAINT_TYPE = ''FOREIGN KEY'') begin 
ALTER TABLE ' 
   + QUOTENAME(cs.name) + '.' + QUOTENAME(ct.name) 
   + char(10) + '	ADD CONSTRAINT ' + QUOTENAME(fk.name) 
   + char(10) + '	FOREIGN KEY (' + STUFF((SELECT ',' + QUOTENAME(c.name)
   -- get all the columns in the constraint table
    FROM sys.columns AS c 
		INNER JOIN sys.foreign_key_columns AS fkc ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.[object_id]
    WHERE fkc.constraint_object_id = fk.[object_id]
    ORDER BY fkc.constraint_column_id 
    FOR XML PATH(N''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, N'')
		  + ') ' + char(10)+ '	REFERENCES ' + QUOTENAME(rs.name) + '.' + QUOTENAME(rt.name)
		  + '(' + STUFF((SELECT ',' + QUOTENAME(c.name)
		   -- get all the referenced columns
    FROM sys.columns AS c 
		INNER JOIN sys.foreign_key_columns AS fkc ON fkc.referenced_column_id = c.column_id AND fkc.referenced_object_id = c.[object_id]
    WHERE fkc.constraint_object_id = fk.[object_id]
    ORDER BY fkc.constraint_column_id 
    FOR XML PATH(N''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 1, N'') + ')' + char(10) + '	ON DELETE NO ACTION ' + char(10) + '	ON UPDATE NO ACTION; ' + char(10)+ 'end'
FROM sys.foreign_keys AS fk 
	INNER JOIN sys.tables AS rt ON fk.referenced_object_id = rt.[object_id] -- referenced table
	INNER JOIN sys.schemas AS rs ON rt.[schema_id] = rs.[schema_id]
	INNER JOIN sys.tables AS ct ON fk.parent_object_id = ct.[object_id] -- constraint table 
	INNER JOIN sys.schemas AS cs ON ct.[schema_id] = cs.[schema_id]
WHERE rt.is_ms_shipped = 0 AND ct.is_ms_shipped = 0
	and (fk.delete_referential_action_desc != 'NO_ACTION' 
	or  fk.update_referential_action_desc != 'NO_ACTION')
order by 1
--UPDATE #x SET create_script = @create;

--select  @drop;
--select @create;