declare @T table (Drive varchar(100), FreeSpaceMB int)
insert @T
exec master..xp_fixeddrives

select	Drive,
		FreeSpaceMB * 1. / 1024 as [FreeSpace (GB)]
from @T
order by Drive