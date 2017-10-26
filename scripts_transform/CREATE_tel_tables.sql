CREATE TABLE t_tel_date(
	date_key	NUMBER(10),
	date_full	CHAR(10),
	year_nr		NUMBER(4),
	month_nr	NUMBER(2),
	month_name_full	VARCHAR2(9),
	month_name_short	CHAR(3),
	day_nr_in_week	NUMBER(1),
	day_nr		NUMBER(2),
	day_name_full	VARCHAR2(20),
	day_name_short	CHAR(3),
	CONSTRAINT pk_telDate_dateKey PRIMARY KEY (date_key)
);


CREATE TABLE t_tel_iteration(
	iteration_key			NUMBER(10),
	iteration_start_date		DATE,
	iteration_end_date			DATE,
	iteration_duration_real		INTEGER,
	CONSTRAINT pk_telIteration_iterationKey PRIMARY KEY (iteration_key)
);


CREATE TABLE t_tel_source(
	source_key		     NUMBER(5),
	source_file_name     VARCHAR2(20),
	source_database_name VARCHAR2(20),
	source_host_ip       VARCHAR2(15),
	source_host_os       VARCHAR2(100),
	source_description	 VARCHAR2(250),
	CONSTRAINT pk_telSource_sourceKey PRIMARY KEY (source_key)
);


CREATE TABLE t_tel_screen(
	screen_key		NUMBER(5),
	screen_name		VARCHAR2(30),
	screen_class		VARCHAR2(15),		-- COMPLETUDE, CORREÇÃO, COERÊNCIA, CLAREZA
	screen_description	VARCHAR2(200),
	screen_version		VARCHAR2(10),		-- EX: 2.7
	screen_expired		VARCHAR2(3),		-- {YES,NO}
	CONSTRAINT pk_telScreen_screenKey PRIMARY KEY (screen_key)
);


CREATE TABLE t_tel_error(
	date_key	NUMBER(10),
	screen_key	NUMBER(5),
	iteration_key	NUMBER(10),
	source_key	NUMBER(5),
	record_id	VARCHAR2(100)	NOT NULL,
	CONSTRAINT pk_telError 		PRIMARY KEY (date_key,screen_key,iteration_key,source_key,record_id),
	CONSTRAINT fk_telError_dateKey 	FOREIGN KEY (date_key) REFERENCES t_tel_date(date_key),
	CONSTRAINT fk_telError_screenKey 	FOREIGN KEY (screen_key) REFERENCES t_tel_screen(screen_key),
	CONSTRAINT fk_telError_iterationKey 	FOREIGN KEY (iteration_key) REFERENCES t_tel_iteration(iteration_key),
	CONSTRAINT fk_telError_sourceKey 	FOREIGN KEY (source_key) REFERENCES t_tel_source(source_key)
);

CREATE TABLE t_tel_schedule(
	screen_key	NUMBER(5),
	iteration_key	NUMBER(10),
	source_key	NUMBER(5),
	screen_order	NUMBER(3),
	CONSTRAINT pk_telSchedule 		PRIMARY KEY (screen_key,iteration_key,source_key),
	CONSTRAINT fk_telSchedule_screenKey 	FOREIGN KEY (screen_key) REFERENCES t_tel_screen(screen_key),
	CONSTRAINT fk_telSchedule_iterationKey FOREIGN KEY (iteration_key) REFERENCES t_tel_iteration(iteration_key),
	CONSTRAINT fk_telSchedule_sourceKey 	FOREIGN KEY (source_key) REFERENCES t_tel_source(source_key)
);



CREATE TABLE t_tel_ext_dates(
	DATE_KEY		NUMBER(10),
	DATE_FULL_DATE		CHAR(10),
	DATE_DAY_NR		NUMBER(2),
	DATE_MONTH_FULL		CHAR(7),
	DATE_MONTH_NR		NUMBER(2),
	DATE_MONTH_SHORT_NAME	CHAR(3),
	DATE_MONTH_NAME		VARCHAR2(12),
	DATE_YEAR		NUMBER(5)
)
ORGANIZATION EXTERNAL
(
	TYPE oracle_loader
	DEFAULT DIRECTORY src_files
	ACCESS PARAMETERS
	(
		RECORDS DELIMITED BY newline
		CHARACTERSET WE8MSWIN1252
		BADFILE 'tel_date.bad'
		DISCARDFILE 'tel_date.dis'
		LOGFILE 'tel_date.log'
		SKIP 1
		FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' MISSING FIELD VALUES ARE NULL
		(
			DATE_KEY			CHAR,
			DATE_FULL_DATE		CHAR,
			DATE_DAY_NR			CHAR,
			DATE_MONTH_FULL		CHAR,
			DATE_MONTH_NR		CHAR,
			DATE_MONTH_SHORT_NAME	CHAR,
			DATE_MONTH_NAME		CHAR,
			DATE_IS_HOLIDAY		CHAR,
			DATE_EVENT			CHAR,
			DATE_QUARTER_FULL		CHAR,
			DATE_QUARTER_NR		CHAR(1),
			DATE_SEMESTER_FULL	CHAR,
			DATE_SEMESTER_NR		CHAR,
			DATE_YEAR			CHAR
		)
	)
	LOCATION ('dates.csv')
)
REJECT LIMIT UNLIMITED;
