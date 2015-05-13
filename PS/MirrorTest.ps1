cls
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=Server1; Failover Partner=Server2; Database=MirrorTest; Integrated Security = SSPI;"
write $conn.ConnectionString
$conn.Open()


$sql = "insert dbo.A(Name) values (convert(varchar(100), getdate(), 126)); select @@servername; waitfor delay '00:00:03.000'"
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql,$conn)
$reader = New-Object System.Data.SqlClient.SqlDataReader;

$conn.State 

while (1) {
    if ($conn.State -ne "Open") { $conn.Open(); }

    try {
        $reader = $cmd.ExecuteReader();
        $reader.Read();
        write $reader[0];
       
    } catch {
        $conn.Close();
    }

}

$conn.Close();


