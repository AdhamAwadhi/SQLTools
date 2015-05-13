declare @Domain nvarchar(100)

exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain',@Domain output

select UPPER(@@SERVERNAME + '.' + @Domain)

