--Server role membership
select	 *
from (
    select  m.name as MemberName,
		  m.type_desc as MemberType,
		  convert(int, m.is_disabled) as IsDisabled,
		  sp.name as RoleName
	   
    from sys.server_principals m
	   left join sys.server_role_members rm on rm.member_principal_id = m.principal_id
	   left join sys.server_principals sp on sp.principal_id = rm.role_principal_id
    where m.type_desc != 'SERVER_ROLE' 
) p
pivot (
	count(p.RoleName) 
	for p.RoleName in ([sysadmin],[securityadmin],[serveradmin],[setupadmin],[processadmin],[diskadmin],[dbcreator],[bulkadmin])
) as Pvt
order by pvt.MemberName