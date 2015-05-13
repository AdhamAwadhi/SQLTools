SELECT
c.Name AS ReportName,
'Next Run Date' = CASE next_run_date
WHEN 0 THEN null
ELSE
substring(convert(varchar(15),next_run_date),1,4) + '/' +
substring(convert(varchar(15),next_run_date),5,2) + '/' +
substring(convert(varchar(15),next_run_date),7,2)
END,
'Next Run Time' = isnull(CASE len(next_run_time)
WHEN 3 THEN cast('00:0'
+ Left(right(next_run_time,3),1)
+':' + right(next_run_time,2) as char (8))
WHEN 4 THEN cast('00:'
+ Left(right(next_run_time,4),2)
+':' + right(next_run_time,2) as char (8))
WHEN 5 THEN cast('0' + Left(right(next_run_time,5),1)
+':' + Left(right(next_run_time,4),2)
+':' + right(next_run_time,2) as char (8))
WHEN 6 THEN cast(Left(right(next_run_time,6),2)
+':' + Left(right(next_run_time,4),2)
+':' + right(next_run_time,2) as char (8))
END,'NA'),
Convert(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="TO"])[1]','nvarchar(50)') as [To]
,Convert(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="CC"])[1]','nvarchar(50)') as [CC]
,Convert(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="RenderFormat"])[1]','nvarchar(50)') as [Render Format]
,Convert(XML,[ExtensionSettings]).value('(//ParameterValue/Value[../Name="Subject"])[1]','nvarchar(50)') as [Subject]
,A.Schedule
FROM 
 dbo.[Catalog] c
INNER JOIN dbo.[Subscriptions] S ON c.ItemID = S.Report_OID
INNER JOIN dbo.ReportSchedule R ON S.SubscriptionID = R.SubscriptionID
left  JOIN msdb.dbo.sysjobs J ON Convert(nvarchar(128),R.ScheduleID) = J.name
left  JOIN msdb.dbo.sysjobschedules JS ON J.job_id = JS.job_id
left join (SELECT
	s.schedule_id,
    CASE
       WHEN j.enabled = 0 THEN 'Disabled'
       WHEN j.job_id IS NULL THEN 'Unscheduled'
       WHEN s.freq_type = 0x1 -- OneTime
           THEN
               'Once on '
             + CONVERT(
                          CHAR(10)
                        , CAST( CAST( s.active_start_date AS VARCHAR ) AS DATETIME )
                        , 102 -- yyyy.mm.dd
                       )
       WHEN s.freq_type = 0x4 -- Daily
           THEN 'Daily'
       WHEN s.freq_type = 0x8 -- weekly
           THEN
               CASE
                   WHEN s.freq_recurrence_factor = 1
                       THEN 'Weekly on '
                   WHEN s.freq_recurrence_factor > 1
                       THEN 'Every '
                          + CAST( s.freq_recurrence_factor AS VARCHAR )
                          + ' weeks on '
               END
             + LEFT(
                         CASE WHEN s.freq_interval &  1 =  1 THEN 'Sunday, '    ELSE '' END
                       + CASE WHEN s.freq_interval &  2 =  2 THEN 'Monday, '    ELSE '' END
                       + CASE WHEN s.freq_interval &  4 =  4 THEN 'Tuesday, '   ELSE '' END
                       + CASE WHEN s.freq_interval &  8 =  8 THEN 'Wednesday, ' ELSE '' END
                       + CASE WHEN s.freq_interval & 16 = 16 THEN 'Thursday, '  ELSE '' END
                       + CASE WHEN s.freq_interval & 32 = 32 THEN 'Friday, '    ELSE '' END
                       + CASE WHEN s.freq_interval & 64 = 64 THEN 'Saturday, '  ELSE '' END
                     , LEN(
                                CASE WHEN s.freq_interval &  1 =  1 THEN 'Sunday, '    ELSE '' END
                              + CASE WHEN s.freq_interval &  2 =  2 THEN 'Monday, '    ELSE '' END
                              + CASE WHEN s.freq_interval &  4 =  4 THEN 'Tuesday, '   ELSE '' END
                              + CASE WHEN s.freq_interval &  8 =  8 THEN 'Wednesday, ' ELSE '' END
                              + CASE WHEN s.freq_interval & 16 = 16 THEN 'Thursday, '  ELSE '' END
                              + CASE WHEN s.freq_interval & 32 = 32 THEN 'Friday, '    ELSE '' END
                              + CASE WHEN s.freq_interval & 64 = 64 THEN 'Saturday, '  ELSE '' END
                           )  - 1  -- LEN() ignores trailing spaces
                   )
       WHEN s.freq_type = 0x10 -- monthly
           THEN
               CASE
                   WHEN s.freq_recurrence_factor = 1
                       THEN 'Monthly on the '
                   WHEN s.freq_recurrence_factor > 1
                       THEN 'Every '
                          + CAST( s.freq_recurrence_factor AS VARCHAR )
                          + ' months on the '
               END
             + CAST( s.freq_interval AS VARCHAR )
             + CASE
                   WHEN s.freq_interval IN ( 1, 21, 31 ) THEN 'st'
                   WHEN s.freq_interval IN ( 2, 22     ) THEN 'nd'
                   WHEN s.freq_interval IN ( 3, 23     ) THEN 'rd'
                   ELSE 'th'
               END
       WHEN s.freq_type = 0x20 -- monthly relative
           THEN
               CASE
                   WHEN s.freq_recurrence_factor = 1
                       THEN 'Monthly on the '
                   WHEN s.freq_recurrence_factor > 1
                       THEN 'Every '
                          + CAST( s.freq_recurrence_factor AS VARCHAR )
                          + ' months on the '
               END
             + CASE s.freq_relative_interval
                   WHEN 0x01 THEN 'first '
                   WHEN 0x02 THEN 'second '
                   WHEN 0x04 THEN 'third '
                   WHEN 0x08 THEN 'fourth '
                   WHEN 0x10 THEN 'last '
               END
             + CASE s.freq_interval
                   WHEN  1 THEN 'Sunday'
                   WHEN  2 THEN 'Monday'
                   WHEN  3 THEN 'Tuesday'
                   WHEN  4 THEN 'Wednesday'
                   WHEN  5 THEN 'Thursday'
                   WHEN  6 THEN 'Friday'
                   WHEN  7 THEN 'Saturday'
                   WHEN  8 THEN 'day'
                   WHEN  9 THEN 'week day'
                   WHEN 10 THEN 'weekend day'
               END
       WHEN s.freq_type = 0x40
           THEN 'Automatically starts when SQLServerAgent starts.'
       WHEN s.freq_type = 0x80
           THEN 'Starts whenever the CPUs become idle'
       ELSE ''
   END
 + CASE
       WHEN j.enabled = 0 THEN ''
       WHEN j.job_id IS NULL THEN ''
       WHEN s.freq_subday_type = 0x1 OR s.freq_type = 0x1
           THEN ' at '
			+ Case  -- Depends on time being integer to drop right-side digits
				when(s.active_start_time % 1000000)/10000 = 0 then 
						  '12'
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100)))
						+ convert(char(2),(s.active_start_time % 10000)/100) 
						+ ' AM'
				when (s.active_start_time % 1000000)/10000< 10 then
						convert(char(1),(s.active_start_time % 1000000)/10000) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ convert(char(2),(s.active_start_time % 10000)/100) 
						+ ' AM'
				when (s.active_start_time % 1000000)/10000 < 12 then
						convert(char(2),(s.active_start_time % 1000000)/10000) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ convert(char(2),(s.active_start_time % 10000)/100) 
						+ ' AM'
				when (s.active_start_time % 1000000)/10000< 22 then
						convert(char(1),((s.active_start_time % 1000000)/10000) - 12) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ convert(char(2),(s.active_start_time % 10000)/100) 
						+ ' PM'
				else	convert(char(2),((s.active_start_time % 1000000)/10000) - 12)
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ convert(char(2),(s.active_start_time % 10000)/100) 
						+ ' PM'
			end
       WHEN s.freq_subday_type IN ( 0x2, 0x4, 0x8 )
           THEN ' every '
             + CAST( s.freq_subday_interval AS VARCHAR )
             + CASE freq_subday_type
                   WHEN 0x2 THEN ' second'
                   WHEN 0x4 THEN ' minute'
                   WHEN 0x8 THEN ' hour'
               END
             + CASE
                   WHEN s.freq_subday_interval > 1 THEN 's'
				   ELSE '' -- Added default 3/21/08; John Arnott
               END
       ELSE ''
   END
 + CASE
       WHEN j.enabled = 0 THEN ''
       WHEN j.job_id IS NULL THEN ''
       WHEN s.freq_subday_type IN ( 0x2, 0x4, 0x8 )
           THEN ' between '
			+ Case  -- Depends on time being integer to drop right-side digits
				when(s.active_start_time % 1000000)/10000 = 0 then 
						  '12'
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100)))
						+ rtrim(convert(char(2),(s.active_start_time % 10000)/100))
						+ ' AM'
				when (s.active_start_time % 1000000)/10000< 10 then
						convert(char(1),(s.active_start_time % 1000000)/10000) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_start_time % 10000)/100))
						+ ' AM'
				when (s.active_start_time % 1000000)/10000 < 12 then
						convert(char(2),(s.active_start_time % 1000000)/10000) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_start_time % 10000)/100)) 
						+ ' AM'
				when (s.active_start_time % 1000000)/10000< 22 then
						convert(char(1),((s.active_start_time % 1000000)/10000) - 12) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_start_time % 10000)/100)) 
						+ ' PM'
				else	convert(char(2),((s.active_start_time % 1000000)/10000) - 12)
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_start_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_start_time % 10000)/100))
						+ ' PM'
			end
             + ' and '
			+ Case  -- Depends on time being integer to drop right-side digits
				when(s.active_end_time % 1000000)/10000 = 0 then 
						'12'
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100)))
						+ rtrim(convert(char(2),(s.active_end_time % 10000)/100))
						+ ' AM'
				when (s.active_end_time % 1000000)/10000< 10 then
						convert(char(1),(s.active_end_time % 1000000)/10000) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_end_time % 10000)/100))
						+ ' AM'
				when (s.active_end_time % 1000000)/10000 < 12 then
						convert(char(2),(s.active_end_time % 1000000)/10000) 
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_end_time % 10000)/100))
						+ ' AM'
				when (s.active_end_time % 1000000)/10000< 22 then
						convert(char(1),((s.active_end_time % 1000000)/10000) - 12)
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_end_time % 10000)/100)) 
						+ ' PM'
				else	convert(char(2),((s.active_end_time % 1000000)/10000) - 12)
						+ ':'  
						+Replicate('0',2 - len(convert(char(2),(s.active_end_time % 10000)/100))) 
						+ rtrim(convert(char(2),(s.active_end_time % 10000)/100)) 
						+ ' PM'
			end
       ELSE ''
   END AS Schedule

FROM         msdb.dbo.sysjobs j
			 INNER JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id 
			 INNER JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
) A on A.schedule_id = js.schedule_ID
order by 1