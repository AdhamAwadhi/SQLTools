$ServerList = @('ServerName')

Function GetCounters {
	$MonSQLInstance = 'ServerName'
	$MonSQLDatabase = 'Monitoring'

	$Counters = @(  'logicaldisk(c:)\% free space',
                    'logicaldisk(c:)\free megabytes',

                    'logicaldisk(d:)\% free space',
                    'logicaldisk(d:)\free megabytes',

                    'logicaldisk(e:)\% free space',
                    'logicaldisk(e:)\free megabytes',

                    'memory\available mbytes',
                    'paging file(\??\c:\pagefile.sys)\% usage',

                    'physicaldisk(0 c:)\avg. disk read queue length',
                    'physicaldisk(0 c:)\avg. disk write queue length',
                    'physicaldisk(0 c:)\disk reads/sec',
                    'physicaldisk(0 c:)\disk writes/sec',

                    'physicaldisk(2 d:)\avg. disk read queue length',
                    'physicaldisk(2 d:)\avg. disk write queue length',
                    'physicaldisk(2 d:)\disk reads/sec',
                    'physicaldisk(2 d:)\disk writes/sec',

                    'physicaldisk(3 e:)\avg. disk read queue length',
                    'physicaldisk(3 e:)\avg. disk write queue length',
                    'physicaldisk(3 e:)\disk reads/sec',
                    'physicaldisk(3 e:)\disk writes/sec',

                    'processor information(_total)\% processor time',
                    'processor information(_total)\% user time',
                    'sqlserver:access methods\full scans/sec',
                    'sqlserver:access methods\index searches/sec',
                    'sqlserver:access methods\page compression attempts/sec',
                    'sqlserver:access methods\page splits/sec',
                    'sqlserver:access methods\worktables created/sec',
                    'sqlserver:buffer manager\buffer cache hit ratio',
                    'sqlserver:buffer manager\checkpoint pages/sec',
                    'sqlserver:buffer manager\lazy writes/sec',
                    'sqlserver:clr\clr execution',
                    'sqlserver:databases(*)\log file(s) size (kb)',
                    'sqlserver:databases(*)\log file(s) used size (kb)',
                    'sqlserver:databases(*)\percent log used',
                    'sqlserver:databases(*)\transactions/sec',
                    'sqlserver:general statistics\active temp tables',
                    'sqlserver:general statistics\logical connections',
                    'sqlserver:general statistics\logins/sec',
                    'sqlserver:general statistics\logouts/sec',
                    'sqlserver:general statistics\processes blocked',
                    'sqlserver:general statistics\user connections',
                    'sqlserver:latches\average latch wait time (ms)',
                    'sqlserver:latches\latch waits/sec',
                    'sqlserver:latches\number of superlatches',
                    'sqlserver:latches\superlatch demotions/sec',
                    'sqlserver:latches\superlatch promotions/sec',
                    'sqlserver:locks(_total)\lock requests/sec',
                    'sqlserver:locks(_total)\lock wait time (ms)',
                    'sqlserver:locks(_total)\number of deadlocks/sec',
                    'sqlserver:memory manager\target server memory (kb)',
                    'sqlserver:memory manager\total server memory (kb)',
                    'sqlserver:sql statistics\batch requests/sec',
                    'sqlserver:sql statistics\sql compilations/sec',
                    'sqlserver:sql statistics\sql re-compilations/sec',
                    'sqlserver:workload group stats(default)\active parallel threads',
                    'sqlserver:workload group stats(default)\active requests',
                    'sqlserver:workload group stats(internal)\active parallel threads',
                    'sqlserver:workload group stats(internal)\active requests'
                    )

	foreach ($ServerName in $ServerList) {
		$CounterXml = (Get-Counter -ComputerName $ServerName -Counter $Counters).CounterSamples	|
					Select-Object -Property Path, InstanceName, CookedValue, Timestamp | ConvertTo-Xml -as String
        Invoke-sqlcmd 	-ServerInstance $MonSQLInstance `
						-Database $MonSQLDatabase `
						-Query "dbo.PerfMonDataAdd '$CounterXml';"
	}
}

GetCounters