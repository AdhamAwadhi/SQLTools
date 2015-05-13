$SrvList = @('Server1','Server2')

function Get-MACAddress { 
    param ($strComputer) 
     
    $colItems = get-wmiobject -class "Win32_NetworkAdapterConfiguration" -computername $strComputer |Where{$_.IpEnabled -Match "True"}  
     
    foreach ($objItem in $colItems) {  
     
        $objItem |select PSComputerName, MACAddress
        }
}
Get-MACAddress ('ServerName')
#foreach ($s in $SrvList) {
#    Get-MACAddress ($s)    
#}

