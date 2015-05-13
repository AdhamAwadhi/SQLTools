--Create login

create login [login] from windows;
create  login [login] with password ='p4ssW0rd', CHECK_EXPIRATION = off, CHECK_POLICY = off
alter server role [server_role] add member [domain\user]


--Create user in database
use DBName
create  user [login] for login [login];

--Add role

--2012 and above
alter role db_datareader add member [login]
alter role db_datawriter add member [login]
alter role db_owner add member [login]
alter role db_ddladmin add member [login]

--2008
exec sp_addrolemember 'role', 'login'

--restore sql user
exec sp_change_users_login  'Update_One', 'dbuser', 'dbuser'


--Generate script for several databases

declare @Login sysname = '[login]',
		@role sysname = 'role'
select name, 'use ' + name + '; create user ' + @login +' for login '+ @login + '; alter role ' + @role +  ' add member ' + @Login
from sys.databases 
where state_desc = 'ONLINE'
	and name not in ('adm','master', 'tempdb', 'model', 'msdb', 'distribution', 'ReportServer', 'ReportServerTempDB' )

