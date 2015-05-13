use Adm
go
create schema [zbx] authorization dbo
go
create user [NT AUTHORITY\SYSTEM] for login [NT AUTHORITY\SYSTEM]
go
grant execute on schema::zbx to [NT AUTHORITY\SYSTEM]