$ServerList = @('Server1','Server2')

clear
foreach ($Server in $ServerList) {


	#Get-WmiObject -Class Win32_DiskDrive -ComputerName $Server | ft Model,$Server
	Get-WmiObject -Class Win32_SCSIController -ComputerName $Server | ft Name,$Server
	
	#ft @{Label="Server"; Expression={$Server}},Model
	#@{
#		Label="Size"; 
#		Expression=	{
#						([System.Math]::round($_.Size / 1024. / 1024 / 1024, 2))
					#}
	#}
}