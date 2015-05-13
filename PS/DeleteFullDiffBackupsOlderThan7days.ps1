ls \\M-Backup01\Backup -Recurse -Include ('*.full', '*.diff') -Exclude ('monthly_*') | Where-Object {$_.CreationTime -lt (get-date(Get-Date -Format D)).AddDays(- (get-date).DayOfWeek)} | Remove-Item
#| Remove-Item
# 
# Select Name, CreationTime | Sort CreationTime
