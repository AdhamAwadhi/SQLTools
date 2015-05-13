$ServerList = @('Server1','Server2')

Function GetPowerPlan {
	foreach ($ServerName in $ServerList) {
		Get-WmiObject -Class Win32_PowerPlan -ComputerName $ServerName -Namespace "root\cimv2\power" | `
		Where-Object {$_.ISActive -eq "True"} | Select-Object @{Name = "ServerName"; `
			Expression = {$ServerName}}, @{Name = "PowerPlan"; Expression = {$_.ElementName}}
	}
}

GetPowerPlan 
