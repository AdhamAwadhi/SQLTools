use Adm
go
set ansi_nulls on
set quoted_identifier on
go

if object_id('zbx.GetDatabaseList') is null exec ('create procedure zbx.GetDatabaseList as begin return end')
go
alter procedure zbx.GetDatabaseList
as begin
    set nocount on
    
    select convert(xml,'{"data":['+ dd + ' ]}') 
    from ( 
		  (
			 select STUFF(
						  (	 select ',' + '{"{#DBNAME}":"' + [Name] + '"}' 
							 from master..sysdatabases 
							 order by [Name] 
							 for xml path('')
						  ), 1, 1, '') as dd
		  )
    ) as df

end
go



