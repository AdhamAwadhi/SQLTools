#Database backup validation script.
#Restore full and diff backups. After restore rename backup file by add "_VALIDATED" mark to file name.
cls

#Import module for use SMO objects
Import-Module "SQLPS" -DisableNameChecking

$InstanceName = "BACKUP\MSX";

$sqlserver = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server($InstanceName);
$restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore;

$backupFolder = "D:\backup"
$restoreFolder = "D:\Databases"
$fullFolder = $backupFolder + "\full"
#Get previos full backup. 
$serverList = ls $fullFolder #| select Name -First 3 | select -Last 1
$err = ""
$CheckingDatabseName = ""
#$serverList


foreach ($Srv in $serverList) {
 
    #Get full backup list
    #"$($Srv.Name)_*S_*dist*.full" - distribution databases
    #Write-Output $($Srv.Name)
    $fullList = ls $backupFolder -Recurse -Include("$($Srv.Name)*S_Distribution*.full") -Exclude ("*_VALIDATED*", "*master*", "*model*", "*msdb*") | `
                    Select-Object FullName, Name, CreationTime | Where-Object {$_.CreationTime -gt (Get-Date(Get-Date -Format D)).AddDays(-7)}
    $fullList 
    if (!$fullList) { continue; }

    #Get database names
    $dbList = $fullList.Name -replace "^$($Srv.Name)_","" -replace "_201(.*)$","" | Sort -Unique

    foreach ($db in $dbList) {
        $CheckingDatabseName = $srv.Name + "." + $db
        #Write-Output $Srv.Name $db
        #Get last full backup for every db
        $lastFull = $fullList | Where-Object { $_.Name -match $db + "_201" } | Sort-Object CreationTime | select -last 2 | select -First 1 
        #$lastFull.Name

        #Get file information from full backup file over SMO
        $restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($lastFull.FullName, [Microsoft.SqlServer.Management.Smo.DeviceType]::File);
        $restore.Devices.add($restoredevice)
        $fl = $restore.ReadFileList($sqlserver);
        #Logical datafile name
        $dataFile = $fl.LogicalName[0]
        #Logical logfile name
        $logFile = $fl.LogicalName[1]
        $restore.Devices.remove($restoredevice) | Out-Null;

        #Get all diff backup after last full
        $diffList = ls $backupFolder -Recurse -Include("$($Srv.Name)_$($db)_201*.diff") -Exclude ("*_VALIDATED*") | `
                    Select-Object FullName, CreationTime | Sort-Object CreationTime | `
                    Where-Object { ($_.CreationTime -gt $lastFull.CreationTime) -and ($_.CreationTime -lt $lastFull.CreationTime.AddDays(8)) } 
        #$diffList
        
        $splt = $lastFull.FullName.Split('.').Split('\')
        #Created database
        $CreateDBName = $splt[$splt.Count - 2]

        Write-Output "Start processing database $srv.$db. " (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

        #Restore Full backup
        $Query = "exec adm.dbo.RestoreFull 
                        @Path = '$($lastFull.FullName)', 
                        @Database = '$CreateDBName', 
                        @mdfPath = '$restoreFolder\$CreateDBName.mdf', 
                        @mdfName = '$dataFile',
                        @ldfPath = '$restoreFolder\$CreateDBName.ldf', 
                        @ldfName = '$logFile'"
        
        Invoke-Sqlcmd `
            -Query $Query `
            -ServerInstance $InstanceName `
            -OutputSqlErrors $true `
            -ErrorVariable err `
            -QueryTimeout 0

        if ($err.Count -eq 0 ) {
            if (!$lastFull.FullName.Contains($validMark)) {
                #Get file extention
                $ext = "." + $lastFull.FullName.Split('.')[1]
                $validMark = "_VALIDATED" + $ext
                $NewName = $lastFull.FullName.Replace($ext, $validMark)
                #$NewName
                Rename-Item $lastFull.FullName -NewName $NewName            
            } else  {
                throw $err
                Write-Error "Error has occured in RestoreFull section. (FileName: $($lastFull.FullName)) " -ErrorAction Stop
            }
        }       
                
        if ($diffList.Count -lt 1) {
            Write-Output "There aren't diff backups"
        } else {
            foreach ($diff in $diffList) {

                Write-Output "Restoring diff backup $($diff.FullName)..." 

                $Query = "exec adm.dbo.RestoreDiff 
                            @Path = '$($diff.FullName)', 
                            @Database = '$CreateDBName'"

                Invoke-Sqlcmd `
                    -Query $Query `
                    -ServerInstance $InstanceName `
                    -OutputSqlErrors $true `
                    -ErrorVariable err `
                    -QueryTimeout 0
   
                if ($err.Count -eq 0 ) {
                    if (!$diff.FullName.Contains($validMark)) {
                        #Get file extention
                        $ext = "." + $diff.FullName.Split('.')[1]
                        $validMark = "_VALIDATED" + $ext
                        $NewName = $diff.FullName.Replace($ext, $validMark)
                        Rename-Item $diff.FullName -NewName $NewName            
                    }
                } else  {
                    throw $err
                    Write-Error "Error has occured in RestoreDiff section. (FileName: $($diff.FullName)) " -ErrorAction Stop
                }

            }
        } #$diffList.Count

        #Restore with RECOVERY
        $Query = "exec adm.dbo.RestoreWithRecovery @Database = '$CreateDBName'"

        Invoke-Sqlcmd `
            -Query $Query `
            -ServerInstance $InstanceName `
            -OutputSqlErrors $true `
            -ErrorVariable err `
            -QueryTimeout 0

        if ($err.Count -gt 0 ) {
            throw $err
            Remove-Variable err
            Write-Error "Error has occured in RestoreWithRecovery section" -ErrorAction Stop
        }        

        #Run DBCC CheckDB
        Write-Output "Run DBCC CheckDB" (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        $Query = "exec adm.dbo.DBCCCheckDB @Database = '$CreateDBName'"

        Invoke-Sqlcmd `
            -Query $Query `
            -ServerInstance $InstanceName `
            -OutputSqlErrors $true `
            -ErrorVariable err `
            -Verbose `
            -QueryTimeout 0
            

        if ($err.Count -gt 0 ) {
            throw $err
            Remove-Variable err
            Write-Error "Error has occured in DBCCCheckDB section (DatabaseName: $CreateDBName)" -ErrorAction Stop
        } else {
            Write-Output $CheckingDatabseName " has checked up. " (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

            #drop restored database
            Invoke-Sqlcmd `
                -Query "drop database [$CreateDBName]" `
                -ServerInstance $InstanceName `
                -OutputSqlErrors $true `
                -ErrorVariable err `
                -QueryTimeout 0
        
            if ($err.Count -gt 0 ) {
                throw $err
                Remove-Variable err
                Write-Error "Error has occured in DROP DATABASE section (DatabaseName: $CreateDBName)" -ErrorAction Stop
            } else {
                Write-Output "Database " $CheckingDatabseName " has been droped. " (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            }


        }

    }
   
}