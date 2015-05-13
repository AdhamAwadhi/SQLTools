#Database backup validation script.
#Restore full and diff backups. After restore rename backup file by add "_VALIDATED" mark to file name.

Import-Module "SQLPS" -DisableNameChecking

$sqlserver = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server(".\MSX");
$restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore;

$backupFolder = "D:\backup"
$restoreFolder = "D:\Databases"
$Server = "RestoreFromServer"
$Database = "Dstribution"
$Query = ""
$splt = $path.Split('.').Split('\')
$CreateDBName = $splt[$splt.Count - 2]


$fileList = ls $backupFolder -Recurse -Include ("*$Database*.*") -Exclude ('*_VALIDATED*') | Select-Object FullName, CreationTime | Sort-Object CreationTime

foreach ($file in $fileList) {

    if ($file.FullName.Length -lt 5) { break; } 

    $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($file.FullName, [Microsoft.SqlServer.Management.Smo.DeviceType]::File);
    $restore.Devices.add($restoredevice)
    $fl = $restore.ReadFileList($sqlserver);
    $dataFile = $fl.LogicalName[0]
    $logFile = $fl.LogicalName[1]
    $restore.Devices.remove($restoredevice);
    
    $ext = "." + $file.FullName.Split('.')[1]

    $validMark = "_VALIDATED" + $ext

    $Query = "exec adm.dbo.RestoreFullDiff 
                    @Path = '$($file.FullName)', 
                    @Database = '$CreateDBName', 
                    @mdfPath = '$restoreFolder\$CreateDBName.mdf', 
                    @mdfName = '$dataFile',
                    @ldfPath = '$restoreFolder\$CreateDBName.ldf', 
                    @ldfName = '$logFile'" 
#    $Query

    Invoke-Sqlcmd   -Query $Query `
                    -ServerInstance "BACKUP\MSX" `
                    -OutputSqlErrors $true `
                    -ErrorVariable err
    
    if ($err.Count -eq 0 ) {
        if (!$file.FullName.Contains($validMark)) {
            $NewName = $file.FullName.Replace($ext, $validMark)
            Rename-Item $file.FullName -NewName $NewName            
        }
    } 
}

    if ($err.Count -gt 0 ) {
        throw $err
        Remove-Variable err
        Write-Error "Error has occured" -ErrorAction Stop
    }