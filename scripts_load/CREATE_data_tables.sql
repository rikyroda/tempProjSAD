CREATE TABLE t_dim_users(
	user_id		NUMBER(10),
	user_natural_key	NUMBER(10),
	turma_id		NUMBER(10),
	temporario	NUMBER(1),
	hashorariocompleto		NUMBER(1),
	ramo		VARCHAR2(10),
	regime		VARCHAR2(10),
	CONSTRAINT pk_tdimusers_userKey PRIMARY KEY (user_id)
);

CREATE TABLE t_dim_turnos(
	turno_id		NUMBER(10),
	turno_natural_key	NUMBER(10),
	anolectivo		NUMBER(11),
	regimeuc	VARCHAR2(10),
	turnouc		VARCHAR2(5),
	max_alunos		NUMBER(11),
	tipoturno		VARCHAR2(5),
	uc_id	NUMBER(10),
	CONSTRAINT pk_tdimturnos_turnoKey PRIMARY KEY (turno_id)
);


CREATE TABLE t_dim_aulas(
	aula_id		NUMBER(10),
	aula_natural_key	NUMBER(10),
	semana		VARCHAR2(4),
	diasemana	NUMBER(11),
	horainicio		VARCHAR2(10),
	horafim		VARCHAR2(10),
	sala		VARCHAR2(50),
	dia	NUMBER(11),
	mes	NUMBER(11),
	ano_civil	NUMBER(11),
	turno_id	NUMBER(10),
	num_presencas	NUMBER(11),
	CONSTRAINT pk_tdimturnos_turnoKey PRIMARY KEY (turno_id)
);

CREATE TABLE t_dim_ucs(
	uc_id		NUMBER(10),
	uc_natural_key	NUMBER(10),
	nomeuc		VARCHAR2(50),
	abrevuc	VARCHAR2(10),
	anouc		NUMBER(11),
	semestreuc		NUMBER(11),
	ramouc		VARCHAR2(30),
	area_cientifica_sigla	VARCHAR2(10),
	area_cientifica	VARCHAR2(80),
	departamento	VARCHAR2(50),
	departamento_sigla	VARCHAR2(10),
	CONSTRAINT pk_tdimucs_ucKey PRIMARY KEY (uc_id)
);

CREATE TABLE t_dim_date(
	date_key		NUMBER(6),
	date_full_date		CHAR(10),
	date_month_full		CHAR(7),
	date_day_nr		NUMBER(2),
	date_is_holiday		CHAR(3),
	date_month_name		VARCHAR2(12),
	date_month_short_name	CHAR(3),
	date_month_nr		NUMBER(2),
	date_quarter_nr		NUMBER(1),
	date_quarter_full	CHAR(7),
	date_semester_nr	NUMBER(1),
	date_semester_full	CHAR(7),
	date_event		VARCHAR2(100),
	date_year		NUMBER(4),
	CONSTRAINT pk_tDimDate_dateKey PRIMARY KEY (date_key)
);

CREATE TABLE t_dim_time(
	time_key		NUMBER(6),
	time_full_time		CHAR(8),
	time_period_of_day	VARCHAR2(20),
	time_minutes_after_midnight	NUMBER(4),
	time_hour_nr		NUMBER(2),
	time_minute_nr		NUMBER(2),
	time_second_nr		NUMBER(2),
	CONSTRAINT pk_tDimTime_timeKey PRIMARY KEY (time_key)
);

CREATE TABLE t_fact_presencas(
	--aula_user_key		NUMBER(10),
	time_key		NUMBER(6),
	date_key		NUMBER(6),
	user_id		NUMBER(10),
	uc_id		NUMBER(10),
	turno_id		NUMBER(10),
	aula_id		NUMBER(10),
	presente		NUMBER(1),
	CONSTRAINT pk_tFactPresencas_pk 		PRIMARY KEY (aula_id, user_id),
	CONSTRAINT fk_tFactPresencas_aula_id	FOREIGN KEY (aula_id) REFERENCES t_dim_aulas(aula_id),
	CONSTRAINT fk_tFactPresencas_user_id 	FOREIGN KEY (user_id) REFERENCES t_dim_users(user_id),
	CONSTRAINT fk_tFactPresencas_timekey 	FOREIGN KEY (time_key) REFERENCES t_dim_time(time_key),
	CONSTRAINT fk_tFactPresencas_datekey 	FOREIGN KEY (date_key) REFERENCES t_dim_date(date_key),
	CONSTRAINT fk_tFactPresencas_turno_id 	FOREIGN KEY (turno_id) REFERENCES t_dim_turnos(turno_id),
	CONSTRAINT fk_tFactPresencas_uc_id 		FOREIGN KEY (uc_id) REFERENCES t_dim_ucs(uc_id)
);

CREATE TABLE t_fact_faltas(
	--aula_user_key		NUMBER(10),
	time_key		NUMBER(6),
	date_key		NUMBER(6),
	user_id		NUMBER(10),
	uc_id		NUMBER(10),
	turno_id		NUMBER(10),
	aula_id		NUMBER(10),
	faltou		NUMBER(1),
	CONSTRAINT pk_tFactFaltas_pk 		PRIMARY KEY (aula_id, user_id),
	CONSTRAINT fk_tFactFaltas_aula_id	FOREIGN KEY (aula_id) REFERENCES t_dim_aulas(aula_id),
	CONSTRAINT fk_tFactFaltas_user_id 	FOREIGN KEY (user_id) REFERENCES t_dim_users(user_id),
	CONSTRAINT fk_tFactFaltas_timekey 	FOREIGN KEY (time_key) REFERENCES t_dim_time(time_key),
	CONSTRAINT fk_tFactFaltas_datekey 	FOREIGN KEY (date_key) REFERENCES t_dim_date(date_key),
	CONSTRAINT fk_tFactFaltas_turno_id 	FOREIGN KEY (turno_id) REFERENCES t_dim_turnos(turno_id),
	CONSTRAINT fk_tFactFaltas_uc_id 	FOREIGN KEY (uc_id) REFERENCES t_dim_ucs(uc_id)
);


