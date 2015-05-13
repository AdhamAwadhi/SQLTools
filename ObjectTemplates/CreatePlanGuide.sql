select --t.text,
    mg.plan_handle,
    count(*)
    --mg.sql_handle
    ,'exec sp_create_plan_guide_from_handle @name =  N''PlanGuide_' +convert(varchar(40), newid())+ ''', @plan_handle =' + '0x' + cast('' as xml).value('xs:hexBinary(sql:column("mg.plan_handle") )', 'varchar(max)')

from sys.dm_exec_query_memory_grants mg
	outer apply sys.dm_exec_query_plan(mg.plan_handle) p	
	outer apply sys.dm_exec_sql_text(mg.sql_handle) t 
where session_id != @@SPID	
group  by mg.plan_handle
order by 2 desc
