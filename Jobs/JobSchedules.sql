-- Query to display schedules of jobs.  
--      copied from http://www.sqlservercentral.com/scripts/Maintenance+and+Management/62222/
--               posted there by "Cowboy DBA"
--    ----------
-- Revised 3/21/08 John Arnott
--   added default "ELSE" to case that would put plural "S" in schedule description.  (find comment " -- Added default 3/21/08; John Arnott"
-- Revised 6/19/08 John Arnott
--   re-coded the time parsing routines. Old code didn't handle first hour of the day (00:04, for instance).  
--   new code uses division by power of 10 to isolate hour, then minute portion of time,  
--   then a little trick with REPLICATE to left-fill the minutes with a zero if needed.
SELECT
  -- @@servername as [Server]
   j.name as [JobName]
 , CASE
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
where j.name like '%index%'
	or j.name like '%mainte%'
	or j.name like '%statis%'
order by 2