--select	d.database_id,
--		d.name as DBName,
--		sum(convert(decimal(12,2), round(F.size * 8. / 1024 / 1024 , 2))) as [FileSize (Gb)]
--from sys.master_files f
--	join sys.databases d on d.database_id = f.database_id
--where d.database_id > 4
--	and d.database_id not in (37,29)
--group by d.database_id,
--		d.name
--with rollup
--having	(GROUPING (d.database_id) = 0 and GROUPING (d.name) = 0) or 
--		(GROUPING (d.database_id) = 1 and GROUPING (d.name) = 1)
--order by d.name

declare @name sysname,
		@sql nvarchar(4000)

declare @R table (DatabaseName sysname, TableCount int)

declare @c cursor
set @c = cursor fast_forward for 
	select	d.name
	from sys.master_files f
		join sys.databases d on d.database_id = f.database_id
	where d.database_id > 4
		and d.database_id not in (37,29)
		and d.state_desc = 'ONLINE'	
	group by d.database_id,
			d.name
	 
open @c
fetch @c into @name

while @@fetch_status = 0 begin
	set @sql = 'use ['+ @name +']; select db_name(), count(*) from sys.tables with(nolock)'
	
	insert @R (DatabaseName, TableCount)
	exec (@sql)
		
	fetch  @c into @name
end
close @c
deallocate @c

--select *
--from @R 
--order by DatabaseName


select	d.database_id,
		d.name as DBName,
		replace(convert(varchar(100), sum(convert(decimal(12,2), round(F.size * 8. / 1024 / 1024 , 2)))),'.',',') as [FileSize (Gb)],
		R.TableCount
from sys.master_files f
	join sys.databases d on d.database_id = f.database_id
	left join @R R on R.DatabaseName = d.name
where d.database_id > 4
	and d.database_id not in (37,29)
group by d.database_id,
		d.name,
		R.TableCount
with rollup
having	(GROUPING (d.database_id) = 0 and GROUPING (d.name) = 0 and GROUPING (R.TableCount) = 0) or 
		(GROUPING (d.database_id) = 1 and GROUPING (d.name) = 1 and GROUPING (R.TableCount) = 1)
order by d.name
