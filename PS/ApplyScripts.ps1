cls

<#

    Repo folder structure
    -root
        |-upgrade (DDL upgrade scripts. Apply new scripts only)
            |-db1
            |-db2
            |-... 
        |-programmability (Stored procs, Views, etc. Apply every time without any conditions)
            |-db1
            |-db2
            |-...
#>

#Settings
    
    #TFS repo
    $_tfsUrl = "https://<TFS server>/<CollectionName>"
    $_tfsPath = "$/"
    $_destFolder = "C:\<save_to>"
    $_folders =  @{'u' = 'upgrade'}, @{'p'='programmability'}

    #Database
    $_instanceName = 'ServerName'
    $_databasePrefix = ''
    $_log_table = "LogTable"
    $scripts = ""
    
#First part: Get new files from TFS

Add-PSSnapin Microsoft.TeamFoundation.PowerShell

function Get-FilesFomTFS {
    Param(  [string]$tfsCollectionUrl,
            [string]$tfsPath,
            [string]$destFolder) 

    $tfsServer = Get-TfsServer -name $tfsCollectionUrl
    $items = Get-TfsChildItem $tfsPath -Server $tfsServer -Recurse

    $tfsCollection = New-Object -TypeName Microsoft.TeamFoundation.Client.TfsTeamProjectCollection -ArgumentList $tfsCollectionUrl
    $tfsVersionControl = $tfsCollection.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])


    foreach ($item in $items) {
        Write-Host "Download TFS item: " $($item.ServerItem) -ForegroundColor yellow

        $dest = $item.ServerItem.Replace($tfsPath, $destFolder)

        if ($item.ItemType -eq "Folder") {
            New-Item $dest -ItemType Directory -Force
        }
        else {
            $tfsVersionControl.DownloadFile($item.ServerItem, $dest)
        } 
    }
}

function Get-ScriptsForApply {

     Param( [string]$InstanceName,
            [string]$DatabaseName,
            [string]$LogTable,
            [string]$SourceFolder,
            [ref]$List) 

        #Second part: determine which scripts have been applied already 

        #Import module for use SMO objects
        Import-Module "SQLPS" -DisableNameChecking;

        Write-Host "`nCreate file list for $DatabaseName"  -ForegroundColor Cyan
        $us = ls -Recurse $SourceFolder -Include 'SQLScript*.sql' 
        $qr = @(Invoke-Sqlcmd `
                            -ServerInstance $InstanceName `
                            -Database $DatabaseName `
                            -OutputSqlErrors $true `
                            -ErrorVariable err `
                            -QueryTimeout 180 `
                            -Query $("select ScriptName from " + $LogTable) 
                        )| Select-Object -expand ScriptName
        
                    if ($err.Count -gt 0 ) {
                        throw $err
                        Remove-Variable err
                    }   

        #Intersect lists
        Write-Host "`nDetermine which scripts we need to apply" -ForegroundColor Cyan
        $List.Value = @($us | ? { $qr -notcontains $_.Name })
}

function ApplyScripts {
    Param(  [string]$InstanceName,
            [string]$DatabaseName,
            [string]$LogTable,
            [string]$SourceFolder,
            $List)

    #Check are there new scripts?
    if ($List.Count -eq 0) { 
        Write-Host "`nNothing to apply from upgrade..." -ForegroundColor Red
    } else  {

        Write-Host "`n============================================" -ForegroundColor Green
        Write-Host " Upgrade scripts to apply for $DatabaseName" -ForegroundColor Green
        Write-Host "============================================`n" -ForegroundColor Green

        $List.Name

        $ans = Read-Host "`nOK? (y/n)"

        if ($ans -ne "y") { exit 0 }

        $List | ForEach-Object {
            Write-Host "Run script: " $_.FullName -ForegroundColor yellow

            Invoke-Sqlcmd `
                -InputFile $_.FullName `
                -ServerInstance $InstanceName `
                -Database $DatabaseName `
                -OutputSqlErrors $true `
                -ErrorVariable err `
                -QueryTimeout 180         
        
                if ($err.Count -gt 0 ) {
                    throw $err
                    Remove-Variable err
                } else {
                    Invoke-Sqlcmd `
                        -ServerInstance $InstanceName `
                        -Database $DatabaseName `
                        -OutputSqlErrors $true `
                        -ErrorVariable err `
                        -QueryTimeout 180 `
                        -Query $("insert " + $LogTable + " (ScriptName, ExecuteDate) values ('" + $_.Name + "', getdate())")
                }
        }

    }

    $SourceFolder = $SourceFolder.Replace($_folders.u, $_folders.p)

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host "Apply SPs, Views, etc... to $DatabaseName from $SourceFolder" -ForegroundColor Green
    Write-Host "============================================`n" -ForegroundColor Green


    if (-not (Test-Path $SourceFolder)) { 
        
        Write-Host "Nothing to apply from $SourceFolder" -ForegroundColor Red
        return;
    }

    $files = ls $SourceFolder -Recurse -Include *.sql | Where-Object FullName -Like "*$_folders.p*"  | Select-Object FullName, Directory | Sort-Object Directory 
    $files.FullName 

    $ans = Read-Host "OK?(y/N)"

    if ($ans -ne "y") { 
        
        Write-Host "`nSkipping apply programmability scripts...`n " -ForegroundColor Red
        return;
    }
    
    
    foreach ($f in $files) {
   
       Write-Host "Run script: " $f.FullName -ForegroundColor yellow

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
            }   
    }
   
}

#====================================

$ans = Read-Host "Get latest version from TFS?(y/N)"

if ($ans -eq "y") { 
    Write-Host "Get new TFS items" -ForegroundColor cyan
    foreach ($f in $_folders) {
        Get-FilesFomTFS $_tfsUrl $($_tfsPath + $f.values) $($_destFolder + $f.Values)
    }
}
#====================================


foreach($ff in $_folders) {

    foreach($p in $($_destFolder + $ff.Values)) {
        
        foreach($db in $(ls $p)) {

            if ( ($db.Mode -ne 'd----') -or ($ff.Values -ne 'upgrade')) { continue }

            $db_name = $($_databasePrefix + $db.Name)
           
            $scripts = ""
            Get-ScriptsForApply $_instanceName $db_name $_log_table $db.FullName ([ref]$scripts)
            
            Write-Host "`n================================" -ForegroundColor Yellow
            Write-Host "Scripts will be apply to:" -ForegroundColor Yellow
            Write-Host "Server: " $_instanceName  -ForegroundColor Yellow
            Write-Host "Database: " $db_name  -ForegroundColor Yellow
            Write-Host "================================`n" -ForegroundColor Yellow

            #Backup database reminder
            $ans = Read-Host "Did you made a backup of $db_name ?(y/n)" 

            if ($ans -ne "y") { exit 0 }

            ApplyScripts $_instanceName $db_name $_log_table $db.FullName $scripts
            
        }
        
    }    
}


Write-Host "Done!" -ForegroundColor Magenta
