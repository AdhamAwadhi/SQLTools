$databaseName = 'DBName'
$path = 'TestPath'
$backupFolder = 'D:\Backup\' + $databaseName
$outFile = "c:\tmp\" + $databaseName  + ".txt"

$restoreDatabase = "restore database {0}_20150220 from disk = '{2}\{1}'
with file = 1,
	move '{0}' to 'D:\SQLData\{0}_20150220.mdf',
	move '{0}_log' to 'D:\SQLData\{0}_20150220_log.ldf',	
	STATS = 2,			
	checksum,	
	norecovery; 
go

"

$restoreLog = "restore log {0}_20150220 from disk = '{2}\{1}'
with file = 1,	
	STATS = 10,			
	checksum,	
	norecovery; 
go

"

ls -R $backupFolder | Where-Object {$_.mode -match "a"} | Sort-Object LastWriteTime | 
    ForEach-Object {
           
           Write-Output ((&{If($_.Directory.Name -eq "LOG") {$restoreLog} Else {$restoreDatabase}}) -f $databaseName, $_.Name, $_.DirectoryName) >> $outFile
            
   }