-- Create a Database Mail account

declare @MailServerName sysname = 'mail.server.tld'
declare @DisplayName sysname = 'SQL-'+ replace(@@ServerName, '\', '-') 
declare @ServerEmail sysname = 'no_reply@server.tld'

exec msdb.dbo.sysmail_add_account_sp
    @account_name = @MailServerName,
    @description = '',
    @email_address = @ServerEmail,
    @replyto_address = @ServerEmail,
    @display_name = @DisplayName,
    @mailserver_name = @MailServerName ,
	@port = 25,
    @username = 'smtp_user',
	@password = 'smtp_pass' ,
	@enable_ssl = 0


-- Create a Database Mail profile

exec msdb.dbo.sysmail_add_profile_sp
    @profile_name = @MailServerName,
    @description = '' ;

-- Add the account to the profile

exec msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @MailServerName,
    @account_name = @MailServerName,
    @sequence_number = 1 ;

-- Grant access to the profile to all users in the msdb database

exec msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @MailServerName,
    @principal_name = 'public',
    @is_default = 1 ;