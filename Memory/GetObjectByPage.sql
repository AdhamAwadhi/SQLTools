dbcc traceon(3604)
dbcc page(2,8,865)

--page 2:5:59 sysallocunits
--page 2:7:158418 sysschobjs
--page 2:8:865 syssingleobjrefs
select object_name(74)