select 'alter database [' + name + '] set restricted_user with rollback immediate; 
ALTER DATABASE [' + name + '] SET ALLOW_SNAPSHOT_ISOLATION ON; 
ALTER DATABASE [' + name + '] SET READ_COMMITTED_SNAPSHOT ON; 
alter database [' + name + '] set multi_user', snapshot_isolation_state_desc 
from sys.databases
