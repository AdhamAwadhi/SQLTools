clear
$ServerList = @('Server1','Server2')
foreach ($Server in $ServerList) {
	$ip = (nslookup $Server)[4].Split(': ')[3];
	Write-Host $ip ,$Server
}