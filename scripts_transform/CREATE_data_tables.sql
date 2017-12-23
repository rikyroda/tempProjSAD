-- CREATE TABLE t_clean_products(
-- 	id		NUMBER(10),
-- 	name		VARCHAR2(30),
-- 	brand		VARCHAR2(30),
-- 	pack_size	VARCHAR2(20),
-- 	pack_type	VARCHAR2(30),
-- 	diet_type	VARCHAR2(15),
-- 	liq_weight	NUMBER(8,2),
-- 	category_name	VARCHAR2(20)
-- );

-- CREATE TABLE t_clean_stores(
-- 	name		VARCHAR2(100),
-- 	reference	CHAR(6),
-- 	address		VARCHAR2(250),
-- 	zip_code	CHAR(8),
-- 	location	VARCHAR2(40),
-- 	district	VARCHAR2(30),
-- 	telephones	CHAR(9),
-- 	fax		CHAR(9),
-- 	status		VARCHAR2(8),
-- 	manager_name	VARCHAR2(100),
-- 	manager_since	DATE
-- );


-- CREATE TABLE t_clean_promotions(
-- 	id		NUMBER(10),
-- 	name		VARCHAR2(100),
-- 	start_date	DATE,
-- 	end_date	DATE,
-- 	reduction	NUMBER(3,2),
-- 	on_street	VARCHAR2(3),
-- 	on_tv		VARCHAR2(3)
-- );


-- CREATE TABLE t_clean_sales(
-- 	id		NUMBER(10),
-- 	sale_date	DATE,
-- 	store_id   	CHAR(6)
-- );


-- CREATE TABLE t_clean_linesofsale(
-- 	id		NUMBER(10),
-- 	sale_id		NUMBER(10),
-- 	product_id	NUMBER(10),
-- 	promo_id	NUMBER(10),
-- 	line_date	DATE,
-- 	quantity	NUMBER(8,2),
-- 	ammount_paid	NUMBER(11,2)
-- );


CREATE TABLE t_clean_users(
	id		NUMBER(10),
	--created_at	TIMESTAMP(6),
	turma_id		NUMBER(10),
	temporario	VARCHAR2(5),
	hashorariocompleto	VARCHAR2(5),
	--preferencia	VARCHAR2(10),
	ramo	VARCHAR2(10),
	regime	VARCHAR2(10)
	--role	NUMBER(11)
);

CREATE TABLE t_clean_faltas(
	id				NUMBER(10),
	aula_semana_id	NUMBER(10),
	user_id			NUMBER(10),
	turno_id 		NUMBER(10),
	faltou			NUMBER(1),
	aula_date		DATE
);

CREATE TABLE t_clean_presencas(
	id				NUMBER(10),
	aula_semana_id	NUMBER(10),
	user_id			NUMBER(10),
	turno_id 		NUMBER(10),
	presente		NUMBER(1),
	aula_date		DATE
);

CREATE TABLE t_clean_aulas(
	AULA_ID                       NUMBER(10),
	SEMANA                   VARCHAR2(4),
	DIASEMANA                NUMBER(11),
	HORAINICIO               VARCHAR2(10),
	HORAFIM                  VARCHAR2(10),
	SALA                     VARCHAR2(50),
	DIA                      NUMBER(11),
	MES                      NUMBER(11),
	ANO_CIVIL                NUMBER(11),
	TURNO_ID                 NUMBER(10),
	--PROF_ID                  NUMBER(10),
	--MARCOU_PRESENCA          NUMBER(1),
	NUM_PRESENCAS            NUMBER(11)
	--AULA_CANCELADA           NUMBER(4)
);

CREATE TABLE t_clean_turnos(
	TURNO_ID                 NUMBER(10),
	ANOLECTIVO               NUMBER(11),
	--NOMEUC                   VARCHAR2(50),
	REGIMEUC                 VARCHAR2(10),
	--ABREVUC                  VARCHAR2(10),
	--ANOUC                    NUMBER(11),
	--SEMESTREUC               NUMBER(11),
	--RAMOUC                   VARCHAR2(5),
	TURNOUC                  VARCHAR2(5),
	MAX_ALUNOS               NUMBER(11),
	TIPOTURNO                VARCHAR2(5),
	UC_ID                    NUMBER(10)
);

CREATE TABLE t_clean_ucs(
	UC_ID                    NUMBER(10),
	NOMEUC                   VARCHAR2(50),
	ABREVUC                  VARCHAR2(10),
	area_cientifica 		 VARCHAR2(80),
	area_cientifica_sigla 	 VARCHAR2(10),
	departamento 			 VARCHAR2(50),
	departamento_sigla 		 VARCHAR2(10),
	ANOUC                    NUMBER(11),
	SEMESTREUC               NUMBER(11),
	RAMOUC                   VARCHAR2(30)
);
