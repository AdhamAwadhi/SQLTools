
--Server permissions
select  *
from (
    select  prm.permission_name, 
		  prm.state_desc,
		  pr.Name as MemberName
    from sys.server_permissions prm
	   left join sys.server_principals pr on pr.principal_id = prm.grantee_principal_id 
    where class_desc = 'server'
) p
pivot (
	count(p.permission_name) 
	for p.permission_name in ( --change to dynamic sql 
						  [ADMINISTER BULK OPERATIONS], [ALTER ANY AVAILABILITY GROUP], [ALTER ANY CONNECTION], [ALTER ANY CREDENTIAL], [ALTER ANY DATABASE], 
						  [ALTER ANY ENDPOINT], [ALTER ANY EVENT NOTIFICATION], [ALTER ANY EVENT SESSION], [ALTER ANY LINKED SERVER], [ALTER ANY LOGIN], 
						  [ALTER ANY SERVER AUDIT], [ALTER ANY SERVER ROLE], [ALTER RESOURCES], [ALTER SERVER STATE], [ALTER SETTINGS], [ALTER TRACE], 
						  [AUTHENTICATE SERVER], [CONNECT ANY DATABASE], [CONNECT SQL], [CONTROL SERVER], [CREATE ANY DATABASE], [CREATE AVAILABILITY GROUP], 
						  [CREATE DDL EVENT NOTIFICATION], [CREATE ENDPOINT], [CREATE SERVER ROLE], [CREATE TRACE EVENT NOTIFICATION], [EXTERNAL ACCESS ASSEMBLY], 
						  [IMPERSONATE ANY LOGIN], [SELECT ALL USER SECURABLES], [SHUTDOWN], [UNSAFE ASSEMBLY], [VIEW ANY DATABASE], [VIEW ANY DEFINITION], [VIEW SERVER STATE])
) as Pvt
order by pvt.MemberName, pvt.state_desc

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




SELECT	--rm.role_principal_id, 
		r.name as RoleName, 
		--rm.member_principal_id, 
		m.name as MemberName
FROM sys.server_role_members rm
	left JOIN sys.server_principals r ON rm.role_principal_id = r.principal_id
	left JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id

select *
from sys.server_principals p
	left join sys.server_role_members m on m.member_principal_id = p.principal_id
	left join sys.server_principals r on r.principal_id = m.role_principal_id
where p.type in ('C', 'U')