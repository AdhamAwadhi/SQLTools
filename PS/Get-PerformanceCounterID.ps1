function Get-PerformanceCounterID
{
    param
    (
        [Parameter(Mandatory=$true)]
        $Name
    )
 
    if ($script:perfHash -eq $null)
    {
        Write-Progress -Activity 'Retrieving PerfIDs' -Status 'Working'
 
        $key = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009'
        $counters = (Get-ItemProperty -Path $key -Name Counter).Counter
        $script:perfHash = @{}
        $all = $counters.Count
 
        for($i = 0; $i -lt $all; $i+=2)
        {
           Write-Progress -Activity 'Retrieving PerfIDs' -Status 'Working' -PercentComplete ($i*100/$all)
           $script:perfHash.$($counters[$i+1]) = $counters[$i]
        }
    }
 
    $script:perfHash.$Name
}
#Clear-Variable "$script"

Get-PerformanceCounterID -Name 'LogicalDisk'
Get-PerformanceCounterID -Name 'Free Megabytes'
Get-PerformanceCounterID -Name '% Free Space'
Get-PerformanceCounterID -Name 'Current Disk Queue Length' 
Get-PerformanceCounterID -Name 'Avg. Disk Read Queue Length' 
Get-PerformanceCounterID -Name 'Avg. Disk Write Queue Length' 
