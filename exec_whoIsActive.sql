select top 1000 
	mg.session_id,
	mg.dop,
	mg.scheduler_id,
	mg.is_small,
	mg.is_next_candidate,
	mg.wait_order,
	mg.wait_time_ms,
	mg.request_time,
	mg.grant_time,
	datediff(ms, mg.request_time, mg.grant_time) as [GrantDuration (ms)],
	mg.requested_memory_kb,
	mg.granted_memory_kb,
	mg.required_memory_kb,
	mg.used_memory_kb,
	mg.max_used_memory_kb,
	mg.ideal_memory_kb,
	mg.query_cost,
	mg.pool_id
from sys.dm_exec_query_memory_grants mg
	--outer apply sys.dm_exec_query_plan(mg.plan_handle) p	
	--outer apply sys.dm_exec_sql_text(mg.sql_handle) t 
where session_id != @@SPID	
	and mg.grant_time is null  -- Only queries waiting for memory grants
order by mg.requested_memory_kb desc,
	mg.query_cost desc
	
select *
from sys.dm_exec_query_resource_semaphores

SELECT
    [owt].[session_id],
    [owt].[exec_context_id],
    [ot].[scheduler_id],
    [owt].[wait_duration_ms],
    [owt].[wait_type],
    [owt].[blocking_session_id],	 
    [owt].[resource_description],
    CASE [owt].[wait_type]
        WHEN N'CXPACKET' THEN
            RIGHT ([owt].[resource_description],
                CHARINDEX (N'=', REVERSE ([owt].[resource_description])) - 1)
        ELSE NULL
    END AS [Node ID],
    [es].[program_name],
    [est].text,
    [er].[database_id],
    --[eqp].[query_plan],
    [er].[cpu_time]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_os_tasks [ot] ON [owt].[waiting_task_address] = [ot].[task_address]
INNER JOIN sys.dm_exec_sessions [es] ON [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON [es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE [es].[is_user_process] = 1
	--and [owt].[session_id] = 237
ORDER BY
    [owt].[session_id],
    [owt].[exec_context_id];
GO	 

exec adm.dbo.sp_WhoIsActive 
--@help = 1	
	--@filter  = '[login]',
	--@filter_type  = 'login',
	@get_full_inner_text = 0,
	@get_outer_command = 1,
	@show_own_spid = 1,
	@show_system_spids = 0,
	@show_sleeping_spids = 0,		
	@get_plans = 2,
	@get_locks = 1,
	@get_transaction_info = 1,	
	@get_task_info = 2,
	@find_block_leaders = 1,
	@get_additional_info = 1,
	@delta_interval = 0


	
