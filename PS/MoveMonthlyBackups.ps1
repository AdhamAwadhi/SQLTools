$backupfolder = '\\backup\backup'
$moveTo1C = '\\BACKUP\MonthlyBackup$\Area1'
$moveToADTS = '\\BACKUP\MonthlyBackup$\Area2'
$moveToOther = '\\BACKUP\MonthlyBackup$\Area3'

ls $backupfolder -Recurse -Include ("*-01_*.full", "*-01_*.diff") | ForEach-Object { 

            Move-Item $_.FullName $( 
                if ($_.Name -like "*1C*") # 1C databases & system databases from 1CServer.
                    { 
                        $moveTo1C 
                    } 
                elseif ($_.Name -like "*ADTS*" -or $_.Name -like "*distribution*" -or $_.Name -like "*master*" -or $_.Name -like "*model*" -or $_.Name -like "*msdb*" ) 
                    { 
                        $moveToADTS 
                    } 
                else 
                    {  
                        $moveToOther
                    } 
                )
        }

                   

ls $backupfolder -Recurse -Include ("*.full") | `
Where-Object {$_.CreationTime -lt (get-date(Get-Date -Format D)).AddDays(- (Get-Date).Day + 1)} | ` 
Group-Object { $_.Name.Split("_")[0] }, { $_.Name -replace "^$($_.Name.Split("_")[0])_","" -replace "_201(.*)$",""} | `
Select-Object Name, Group | ForEach-Object { $_.Group | select -Last 1 } 

<#`
Select FullName, @{ Label= "TEst"; Expression = { 
 
                    if ($_.Name -like "*1C*") { "1C" } 
                    elseif ($_.Name -like "*S*" -or $_.Name -like "*distribution*" -or $_.Name -like "*master*" -or $_.Name -like "*model*" -or $_.Name -like "*msdb*" ) { "S" } 
                    else {"Other"}
            } 
 
        } | Sort Test, FullName;
#>