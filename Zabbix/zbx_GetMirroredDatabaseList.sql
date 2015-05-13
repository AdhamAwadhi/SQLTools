use Adm
go
set ansi_nulls on
set quoted_identifier on
go

if object_id('zbx.GetMirroredDatabaseList') is null exec ('create procedure zbx.GetMirroredDatabaseList as begin return end')
go
alter procedure zbx.GetMirroredDatabaseList
as begin
    set nocount on
    
    select convert(xml,'{"data":['+ dd + ' ]}') 
    from ( 
		  (
			 select STUFF(
						  (	 select ',' + '{"{#DBNAME}":"' + d.Name + '"}' 
							 from sys.database_mirroring dm
								join sys.databases d on d.database_id = dm.database_id
							 where dm.mirroring_state is not null
							 order by d.name
							 for xml path('')

						  ), 1, 1, '') as dd
		  )
    ) as df




end
go



