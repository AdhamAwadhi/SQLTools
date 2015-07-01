#Generate restore command for each backup file in $backupFolder
#Author: Evgeny Khabarov <ekhabarov@dev.ms>
#Date: 08.06.2015
 
#Import module for use SMO objects
Import-Module "SQLPS" -DisableNameChecking;
 
$sqlserver = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server('.');
$restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore;
 
$backupFolder = "D:\Backup"
$outFile = "D:\Backup\restore.sql"

if (Test-Path $outFile) {
    Remove-Item $outFile
}
 
foreach ($backupFile in $(ls -Recurse $backupFolder)) {
    
    #Skip folders
    if ($backupFile.Mode -eq "d----"){ continue; }
    
    #Get file information from full backup file over SMO
    $restoreDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($backupFile.FullName,'File');
    $restore.Devices.add($restoreDevice)
    
    #Get files list aka "RESTORE FILELISTONLY"
    $smoFileList = $restore.ReadFileList($sqlserver);
 
    #Get header aka "RESTORE HEADERONLY"
    $header = $restore.ReadBackupHeader($sqlserver) 
 
    #Make restore command
    $restoreCmd = 'restore database ' + $header.DatabaseName + "`r`n`t" + 'from disk = ''' + $backupFile.FullName + ''' with file = 1, '
    
    #Will contains "move" part of restore command
    $move = ''
 
    foreach($f in $smoFileList) {
        $move += "`r`n`t" + 'move ''' + $f.LogicalName + ''' to ''D:\SQLServer\' + $f.LogicalName + $(if ($f.Type -eq 'D')  { '.mdf' } else { '.ldf' }) + ''','
    }
 
    $restoreCmd += $move + "`r`n`tchecksum, stats = 25 `r`ngo"
    $restoreCmd | Out-File -Append $outFile
 
    $restore.Devices.remove($restoredevice) | Out-Null;
    
}