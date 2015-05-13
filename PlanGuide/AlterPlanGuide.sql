select *,
    'exec sp_control_plan_guide N''DROP'', N'''+pg.name+''';'+ case when pg.is_disabled = 1 then '' else  ' exec sp_create_plan_guide @name = N''' + pg.name + ''', @stmt = N'''+replace(pg.query_text,'''','''''') +''', @type = N''SQL'',@module_or_batch = NULL, @params = NULL, @hints = N''OPTION (MAXDOP 1, KEEP PLAN, OPTIMIZE FOR UNKNOWN)'';' end
from sys.plan_guides pg


