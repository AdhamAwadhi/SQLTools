set ansi_nulls, quoted_identifier on
go
if object_id('dbo.ObjectDescript') is null exec ('create procedure dbo.ObjectDescript as begin return end')
go
alter procedure dbo.ObjectDescript
	@ObjectName varchar(512),
	@Descript sql_variant

as begin
	set nocount on;
	
	declare @Schema sysname,
			@Object sysname,
			@Column sysname = null,
			@Object_ID int,
			@P int = 1

	set @P = charindex('.', REVERSE(@ObjectName))	
	if PATINDEX('%.%.%' , @ObjectName) > 0 begin
		set @Column = REVERSE(left(REVERSE(@ObjectName), @P - 1))
		set @Object = REVERSE(right(REVERSE(@ObjectName), len(@ObjectName) - @P ))
	end else 
		if PATINDEX ('%.%', @ObjectName) > 0 begin
			set @Object = @ObjectName
		end else begin
			raiserror ( 'Incorrect object name: %s', 16,1, @ObjectName)
			return
		end

	set @Object_ID = Object_id(@Object)

	if @Object_ID is null begin
		raiserror ( 'Object %s not found', 16,1, @Object)
		return
	end 

	set @Schema = OBJECT_SCHEMA_NAME(@Object_ID)


	if isnull(@Schema, '') = '' begin
		raiserror ( 'Schema is null', 16,1 )
		return
	end

	declare @ObjectType sysname,
			@Level2Type sysname = case when isnull(@Column, '') != '' then 'COLUMN' else null end

	if (@Column is not null) and (Columnproperty(@Object_ID, @Column,'ColumnID') is null)  begin
		raiserror ( 'Column %s in object %s not found', 16,1, @Column, @Object)
		return
	end

	
	select @ObjectType = case  O.[Type] 
							when 'U' then 'TABLE'
							when 'P' then 'PROCEDURE'
							when 'FN' then 'FUNCTION'
							when 'TR' then 'TRIGGER'
							when 'V' then 'VIEW'
						end
	from sys.objects O
	where object_id = @Object_ID
	
	set @Object = replace(@Object, @Schema + '.', '')

	exec sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = @Descript,
			@level0type = N'SCHEMA', @level0name = @Schema,
			@level1type = @ObjectType, @level1name = @Object,
			@level2type = @Level2Type, @level2name = @Column
end
go
