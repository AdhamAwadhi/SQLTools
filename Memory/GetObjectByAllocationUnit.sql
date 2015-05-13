pagelock fileid=1 pageid=31966420 dbid=12 subresource=FULL id=lock3aa073600 mode=X associatedObjectId=72057594667663360
pagelock fileid=1 pageid=28122262 dbid=12 subresource=FULL id=lock2423e8480 mode=X associatedObjectId=72057594667597824
	select o.name
	from sys.allocation_units au
		join sys.partitions p on p.hobt_id = au.container_id
		join sys.objects o on o.object_id = p.object_id
	where au.container_id = 72057594667663360

select Object_name(498100815)