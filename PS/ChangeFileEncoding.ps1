$Path = "path"
$FileName = ""

foreach( $i in ls $Path  -Recurse -name ) {
    $FileName = ($Path +"\" +$i) 
    $NewFileName = ($FileName + "_")
    Write-Host $FileName
    get-content $FileName -Encoding String| out-file -encoding utf8 -filepath $NewFileName
    Remove-Item $FileName
    Rename-Item $NewFileName -newname $FileName    
}