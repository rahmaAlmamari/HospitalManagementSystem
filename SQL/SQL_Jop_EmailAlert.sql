USE [msdb]
GO

/****** Object:  Job [Doctor Appointment Alert]    Script Date: 6/28/2025 3:28:28 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 6/28/2025 3:28:28 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Doctor Appointment Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends email if any doctor has over 10 appointments in one day', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'LAPTOP-IUF9HHIH\Lenovo', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Appointments]    Script Date: 6/28/2025 3:28:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Appointments', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'   IF EXISTS (
   SELECT DoctorID, AppointmentDate
   FROM DoctorsSchema.Appointments
   GROUP BY DoctorID, AppointmentDate
   HAVING COUNT(*) > 10
   )
   BEGIN
   EXEC msdb.dbo.sp_send_dbmail --Built-in stored procedure that sends emails from SQL Server.
    @profile_name = ''HospitalAlertProfile'',  -- replace with your profile name
    @recipients = ''rahma.almamari2021@gmail.com'',
    @subject = ''x( Doctor Alert: Overloaded Schedule'',
    @body = ''One or more doctors have more than 10 appointments scheduled today. Please check the schedule.'';
   END', 
		@database_name=N'HospitalManagementSystem', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DailyCheck', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20250628, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
		@active_end_time=235959, 
		@schedule_uid=N'bb83c644-1138-4731-86fa-80021697d645'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

------------------------------------Help sql-------------------

--Run this SQL query in SSMS to list all existing mail profiles
SELECT name 
FROM msdb.dbo.sysmail_profile;

--to get all email sent by the jop
SELECT sent_status, subject, recipients, last_mod_date
FROM msdb.dbo.sysmail_allitems
ORDER BY last_mod_date DESC;

--run the jop code manually to check if it succeufly send a email or not 
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'HospitalAlertProfile',  -- Replace with your actual profile name
    @recipients = 'rahma.almamari2021@gmail.com',
    @subject = 'Test Email',
    @body = 'This is a manual test of Database Mail.';
