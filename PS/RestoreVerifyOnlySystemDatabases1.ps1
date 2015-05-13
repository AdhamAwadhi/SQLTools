$backupFolder = "D:\backup";
$fileList = ls $backupFolder -Recurse -Include ('*master*.full', '*model*.full', '*msdb*.full', '*corupt*') -Exclude ('*VALIDATED*')
$validMark = "_VALIDATED.full"
$ext = ".full"

    foreach ($file in $fileList) {
        if ($file.FullName.Length -lt 5) { break; } 
        Invoke-Sqlcmd   -Query "exec adm.dbo.RestoryVerifyOnly @FileName = '$file'" `
                        -ServerInstance "BACKUP\MSX" `
                        -OutputSqlErrors $true `
                        -ErrorVariable err
    
        if ($err.Count -eq 0 ) {
            if (!$file.FullName.Contains($validMark)) {
                $file.MoveTo($file.FullName.Replace($ext, $validMark))
            }
        } 
    }

    if ($err.Count -gt 0 ) {
        throw $err
        Remove-Variable err
        Write-Error "Error has occured" -ErrorAction Stop
    }