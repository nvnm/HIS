GO
IF NOT EXISTS(SELECT 1 FROM Information_Schema.Routines	WHERE Routine_Name = 'InsertUpdateRegistration')
BEGIN
  EXEC('create procedure dbo.InsertUpdateRegistration as RAISERROR (136001, -1, -1, ''InsertUpdateRegistration'');');
END
 
GO

Alter PROCEDURE [dbo].[InsertUpdateRegistration] (
  @Trans_Num       numeric(18),
	@HRN_Num         varchar(13),
    @Episode_Num     int
)
AS

BEGIN
    SET NOCOUNT ON;
	DECLARE @iStatusCode INT;
	DECLARE @iMessage varchar(max);
	DECLARE @iCount INT;
	DECLARE @CreationTime DATETIME;
	DECLARE @LastModifiedDTimeMins DATETIME;
	DECLARE @SysDateTime DATETIME;

	declare @hrn varchar(18);
	declare @trans numeric;
	declare @episode int;
	declare @demoid int;
	declare @tfc varchar(15);
	declare @spouseid int;
	declare @patlastname varchar(30);
	declare @patfirstname varchar(30);
	declare @title varchar(10);
	declare @sex char(1);
	declare @regid int;
	declare @patid int;

	DECLARE @dbname nvarchar(128);
	SET @dbname = 'Project';

	IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = @dbname)
		BEGIN
			create database Project;
		END

	IF NOT EXISTS (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'Project' AND table_name = 'HIS_Demographics')
	BEGIN
		CREATE TABLE HIS_Demographics(demo_id Integer PRIMARY KEY IDENTITY, trans_num numeric(10) NOT NULL, hrn_num varchar(13) NOT NULL, episode_num int NOT NULL, pat_num int NULL,
		pat_last_nm varchar(30), pat_first_nm varchar(30), other_nm varchar(40), title_cd varchar(10), sex_cd char(1), ident_tp char(1), ident_num varchar(15), dob datetime, tfc_reg_num varchar(15), block_num varchar(10),
		level_num varchar(3), unit_num varchar(5), street1_nm varchar(40), street2_nm varchar(40), street3_nm varchar(40), postal_cd varchar(8), home_num varchar(12), 
		office_num varchar(12), hp_num varchar(30), corr_block_num varchar(10), corr_level_num char(3), corr_unit_num char(5), corr_street1_nm varchar(40), corr_street2_nm varchar(40),
		corr_street3_nm varchar(40), corr_postal_cd varchar(8), email_id varchar(256), create_ts datetime NOT NULL, Status_fl char(1) NOT NULL);

		--insert into HIS_Demographics(trans_num, hrn_num, episode_num, pat_num, pat_first_nm, sex_cd, tfc_reg_num, create_ts, Status_fl)	values(10,'100', 1000, 789, 'Sindhu', 'F', '3333', GETDATE(), 'N');
	END

		IF NOT EXISTS (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'Project' AND table_name = 'HIS_Spouse')
		BEGIN
			CREATE TABLE HIS_Spouse (spouse_id Integer PRIMARY KEY IDENTITY, demo_id int FOREIGN KEY REFERENCES HIS_Demographics(demo_id), trans_num numeric, hrn_num varchar(13) NOT NULL, 
			episode_num int NOT NULL, s_pat_last_nm varchar(30), s_pat_first_nm varchar(30), s_title_cd varchar(10), s_sex_cd char(1), ident_tp char(1), ident_num varchar(15), dob datetime, block_num varchar(10),
			level_num varchar(3), unit_num varchar(5), street1_nm varchar(40), street2_nm varchar(40), street3_nm varchar(40), postal_cd varchar(8), home_num varchar(12), office_num varchar(12),
			hp_num varchar(30), create_ts datetime NOT NULL, Status_fl char(1) NOT NULL);

			insert into HIS_Spouse(demo_id, trans_num, hrn_num, episode_num, s_pat_first_nm, s_sex_cd, create_ts, Status_fl)
			values(1, 20, 100, 1000, 'YYY', 'M', GETDATE(), 'N');
		END

		IF NOT EXISTS (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'Project' AND table_name = 'CM_Registration')
		BEGIN
			CREATE TABLE CM_Registration (reg_id Integer PRIMARY KEY IDENTITY, trans_num numeric, hrn_num varchar(13) NOT NULL, episode_num int NOT NULL, tfc_reg_num varchar(15), 
			clin_id numeric, start_date datetime, sensitive tinyint, archived tinyint, remarks varchar(255), demo_id Integer FOREIGN KEY REFERENCES HIS_Demographics(demo_id),
			spouse_id int FOREIGN KEY REFERENCES HIS_Spouse(spouse_id), deleted tinyint, deleted_by varchar(30), deleted_at datetime, created_by varchar(30), created_at datetime NOT NULL, 
			updated_by varchar(30), updated_at datetime);

		END

		IF NOT EXISTS (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'Project' AND table_name = 'CM_Patient')
		BEGIN
			CREATE TABLE CM_Patient (pat_id Integer PRIMARY KEY IDENTITY, hrn_num varchar(13) NOT NULL, 
			pat_num int, pat_last_nm varchar(30), pat_first_nm varchar(30), other_nm varchar(40), title_cd varchar(10), sex_cd char(1), ident_tp char(1), ident_num varchar(15), dob datetime, block_num varchar(10), 
			level_num varchar(3) null, unit_num	varchar(5) null, street1_nm	varchar(40) null, street2_nm varchar(40) null, street3_nm varchar(40) null, postal_cd varchar(8) null, home_num	varchar(12) null,
			office_num varchar(12) null, hp_num varchar(30) null, corr_level_num char(3) null, corr_unit_num char(5) null, corr_street1_nm varchar(40) null, corr_street2_nm varchar(40) null, 
			corr_street3_nm	varchar(40) null, corr_postal_cd varchar(8) null, email_id varchar(256), demo_id int FOREIGN KEY REFERENCES HIS_Demographics(demo_id), spouse_id int FOREIGN KEY REFERENCES HIS_Spouse(spouse_id), deleted tinyint, deleted_by varchar(30) null, deleted_at	datetime null, created_by varchar(30) null, created_at datetime not null, 
			updated_by varchar(30) null, updated_at	datetime null);
		END

		IF NOT EXISTS (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'Project' AND table_name = 'CM_Patient_Relationship')
		BEGIN
			CREATE TABLE CM_Patient_Relationship(rel_id Integer PRIMARY KEY IDENTITY, reg_id Integer FOREIGN KEY REFERENCES CM_Registration(reg_id), demo_id Integer FOREIGN KEY REFERENCES HIS_Demographics(demo_id),
			pat_id Integer FOREIGN KEY REFERENCES CM_Patient(pat_id), spouse_id Integer FOREIGN KEY REFERENCES HIS_Spouse(spouse_id));
		END

	BEGIN 
		SET @SysDateTime           = GETDATE();
		SET @CreationTime          = @SysDateTime;
		SET @LastModifiedDTimeMins = @SysDateTime;

		-- Registration table insertion --

		IF(select count(*) from HIS_Demographics inner join HIS_Spouse on HIS_Demographics.hrn_num = HIS_Spouse.hrn_num AND HIS_Demographics.trans_num = HIS_Spouse.trans_num AND HIS_Demographics.episode_num = HIS_Spouse.episode_num AND HIS_Demographics.Status_fl = 'N' AND HIS_Spouse.Status_fl = 'N') > 0
			BEGIN
				DECLARE @LoopCounter INT , @Max INT, @LoopSpouseId INT, @LoopSpouseIdEnd INT;
				SELECT @LoopCounter = min(HIS_Demographics.demo_id) , @Max = max(HIS_Demographics.demo_id), @LoopSpouseId = min(HIS_Spouse.spouse_id), @LoopSpouseIdEnd = max(HIS_Spouse.spouse_id)
				FROM HIS_Demographics inner join HIS_Spouse on HIS_Demographics.hrn_num = HIS_Spouse.hrn_num AND HIS_Demographics.trans_num = HIS_Spouse.trans_num AND HIS_Demographics.episode_num = HIS_Spouse.episode_num AND HIS_Demographics.Status_fl = 'N' AND HIS_Spouse.Status_fl = 'N' AND  (select DATEDIFF(MINUTE, HIS_Demographics.create_ts, @SysDateTime)) >= 5 AND  (select DATEDIFF(MINUTE, HIS_Spouse.create_ts, @SysDateTime)) >= 5

			WHILE(@LoopCounter IS NOT NULL AND @LoopCounter <= @Max)
				BEGIN

					set @hrn = (select hrn_num from HIS_Demographics WHERE demo_id = @LoopCounter);
					set @trans = (select trans_num from HIS_Demographics WHERE demo_id = @LoopCounter);
					set @episode = (select episode_num from HIS_Demographics WHERE demo_id = @LoopCounter);
					set @demoid = @LoopCounter;
					set @tfc = (select tfc_reg_num from HIS_Demographics WHERE demo_id = @LoopCounter);
					set @spouseid = (select spouse_id from HIS_Spouse WHERE demo_id = @LoopCounter);
					set @patfirstname = (select pat_first_nm from HIS_Demographics WHERE demo_id = @LoopCounter AND trans_num = @trans AND hrn_num = @hrn AND episode_num = @episode);
					set @patlastname = (select pat_last_nm from HIS_Demographics WHERE demo_id = @LoopCounter AND trans_num = @trans AND hrn_num = @hrn AND episode_num = @episode);
					set @title = (select title_cd from HIS_Demographics WHERE demo_id = @LoopCounter AND trans_num = @trans AND hrn_num = @hrn AND episode_num = @episode);
					set @sex = (select sex_cd from HIS_Demographics WHERE demo_id = @LoopCounter AND trans_num = @trans AND hrn_num = @hrn AND episode_num = @episode);	

					/** Registration table insertion **/
					IF(select count(*) from CM_Registration where trans_num = @trans AND hrn_num = @hrn AND episode_num = @episode) < 1
						BEGIN
							INSERT INTO CM_Registration (trans_num, hrn_num, episode_num, demo_id, tfc_reg_num, spouse_id, created_at)
							Values (@trans, @hrn, @episode, @demoid, @tfc, @spouseid, @SysDateTime);
						END

					/** Registration table update by Demographics **/
					ELSE
						BEGIN
							update CM_Registration set tfc_reg_num = @tfc, demo_id = @demoid, spouse_id = @spouseid, updated_at=@SysDateTime where trans_num = @trans AND hrn_num = @hrn AND episode_num = @episode;

						END


					/** Patient table insertion by Demographics **/
					IF(select count(*) from CM_Patient where hrn_num = @hrn) < 1
						BEGIN
							INSERT INTO CM_Patient(hrn_num, pat_last_nm, pat_first_nm, title_cd, sex_cd, demo_id, spouse_id, created_at) values(@hrn, @patlastname, @patfirstname, @title, @sex, @demoid, @spouseid, @SysDateTime);

							Print 'Patient records successfully inserted by demographics';
						END

					/** Patient table update by Demographics **/
					ELSE
						BEGIN
							update CM_Patient set pat_first_nm = @patfirstname, pat_last_nm = @patlastname, title_cd = @title, sex_cd = @sex, demo_id = @demoid, spouse_id = @spouseid, updated_at = @SysDateTime where hrn_num = @hrn;
							Print 'Patient records successfully updated by demographics';
						END



					/** Patient table insertion by Spouse **/
					IF(select count(*) from CM_Patient where spouse_id = @spouseid) < 1
						BEGIN
							INSERT INTO CM_Patient(hrn_num, pat_last_nm, pat_first_nm, title_cd, sex_cd, demo_id, spouse_id, created_at)
							Values (@hrn, @patlastname, @patfirstname, @title, @sex, @demoid, @spouseid, @SysDateTime);

							Print 'Patient records successfully inserted by Spouse';
						END

					/** Patient table update by Spouse **/
					ELSE
						BEGIN
							update CM_Patient set pat_first_nm = @patfirstname, pat_last_nm = @patlastname, title_cd = @title, sex_cd = @sex, demo_id = @demoid, spouse_id = @spouseid, updated_at = @SysDateTime where hrn_num = @hrn AND spouse_id = @spouseid;
							
							Print 'Patient records successfully updated by Spouse';
						END
			

					set @regid = (select reg_id from CM_Registration where demo_id = @demoid AND spouse_id = @spouseid AND hrn_num = @hrn);
					set @patid = (select pat_id from CM_Patient where demo_id = @demoid AND spouse_id = @spouseid AND hrn_num = @hrn);

					IF(select count(*) from CM_Patient_Relationship where demo_id = @demoid AND spouse_id = @spouseid) < 1
						BEGIN
							INSERT INTO CM_Patient_Relationship(reg_id, pat_id, demo_id, spouse_id)
							Values(@regid, @patid, @demoid, @spouseid);
						END

					/** Update Relationship table **/
					ELSE
						BEGIN
							update CM_Patient_Relationship set reg_id = @regid, pat_id = @patid where demo_id = @demoid AND spouse_id = @spouseid;
						END


					-- Updating Demographics table flag --
					update HIS_Demographics set Status_fl='Y' where demo_id = @demoid;
					-- Updating Spouse table flag --
					update HIS_Spouse set Status_fl='Y' where spouse_id = @spouseid;

				SET @LoopCounter  = @LoopCounter  + 1;    
			END
		END
				 
		 
		 		 
	 END 
END

SUCCESS:
SELECT  StatusCode = @iStatusCode, StatusMessage = @iMessage; 
     
ERROR:
SELECT StatusCode = @iStatusCode, StatusMessage = @iMessage;         
    
GO