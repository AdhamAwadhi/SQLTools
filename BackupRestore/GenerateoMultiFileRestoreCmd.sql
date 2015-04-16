select *,
    'disk = ''' + replace('\\Backup1\BACKUP\PARSERS_DB\parserFTP44FL\FULL\PARSERS_DB_parserFTP44FL_FULL_20150402_221513_xx.bak', 'xx', case when len(r) < 2 then '0'+r else r end) + ''','
from (

    select top 48
	   convert(varchar(10), ROW_NUMBER() over(order by (select 1))) r
    
    from master..spt_values
) A