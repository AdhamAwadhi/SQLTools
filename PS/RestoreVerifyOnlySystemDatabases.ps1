Import-Module "SQLPS" -DisableNameChecking

$sqlserver = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server(".\MSX");
$restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore;
$backupFolder = "D:\backup";

$fileList = ls $backupFolder -Recurse -Include ('*master*.full', '*model*.full', '*msdb*.full') 

#foreach ($file in $fileList) {
#    Write-Host $file.FullName
#}
$file = "D:\backup\full\DBName_backup.full";

$devicetype = [Microsoft.SqlServer.Management.Smo.DeviceType]::File;
$restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($file.FullName, $devicetype);
$restore.Devices.add($restoredevice)
$restore.ReadMediaHeader($sqlserver)

$restore.Devices.remove($restoredevice)

