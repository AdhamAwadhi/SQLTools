Import-Module sqlps -DisableNameChecking

$ScriptPath = "C:\tmp\programmability"
$InstanceName = "server.name"
$DatabaseName = "db_name"

$files = ls -Recurse $scriptPath -Include *.sql | Select-Object FullName, Directory | Sort-Object Directory 

foreach ($f in $files) {
   Write-Host "Run script: " $f.FullName
   
   Invoke-Sqlcmd `
        -InputFile $f.FullName `
        -ServerInstance $InstanceName `
        -Database $DatabaseName `
        -OutputSqlErrors $true `
        -ErrorVariable err `
        -QueryTimeout 0
        
        if ($err.Count -gt 0 ) {
            throw $err
            Remove-Variable err
            #Write-Error "Error has occured" -ErrorAction Stop
        }   
}
    
 