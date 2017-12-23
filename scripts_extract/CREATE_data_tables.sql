-- CREATE TABLE t_data_products(
-- 	id		NUMBER(10),
-- 	name		VARCHAR2(30),
-- 	brand		VARCHAR2(30),
-- 	width		NUMBER(5),
-- 	height		NUMBER(5),
-- 	depth   	NUMBER(5),
-- 	pack_type	VARCHAR2(30),
-- 	calories_100g	NUMBER(3),
-- 	liq_weight	NUMBER(8,2),
-- 	category_id	CHAR(5),
-- 	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );

-- CREATE TABLE t_data_stores_new(
-- 	name		VARCHAR2(100),
-- 	reference	CHAR(6),
-- 	building	VARCHAR2(250),
-- 	address		VARCHAR2(250),
-- 	zip_code	CHAR(8),
-- 	location	VARCHAR2(100),
-- 	district	VARCHAR2(100),
-- 	telephones	VARCHAR2(50),
-- 	fax		VARCHAR2(50),
-- 	closure_date	DATE,
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );

-- CREATE TABLE t_data_stores_old AS SELECT * FROM t_data_stores_new;


-- CREATE TABLE t_data_managers_new(
-- 	reference	CHAR(6),
-- 	manager_name	VARCHAR2(100),
-- 	manager_since	DATE,
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );

-- CREATE TABLE t_data_managers_old AS SELECT * FROM t_data_managers_new;

-- CREATE TABLE t_data_promotions(
-- 	id		NUMBER(10),
-- 	name		VARCHAR2(100),
-- 	start_date	DATE,
-- 	end_date	DATE,
-- 	reduction	NUMBER(3,2),
-- 	on_outdoor	NUMBER(1),
-- 	on_tv		NUMBER(1),
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );


-- CREATE TABLE t_data_sales(
-- 	id		NUMBER(10),
-- 	sale_date		DATE,
-- 	store_id   	CHAR(6),
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );


-- CREATE TABLE t_data_linesofsale(
-- 	id		NUMBER(14),
-- 	sale_id		NUMBER(10),
-- 	product_id	NUMBER(10),
-- 	quantity	NUMBER(8,2),
-- 	line_date	DATE,
-- 	ammount_paid	NUMBER(11,2),
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );


-- CREATE TABLE t_data_linesofsalepromotions(
-- 	line_id		NUMBER(10),
-- 	promo_id	NUMBER(10),
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );


-- CREATE TABLE t_data_categories(
-- 	id		CHAR(5),
-- 	name		VARCHAR2(30),
-- 	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
-- );

CREATE TABLE t_data_users(
	CREATED_AT                  TIMESTAMP(6),  
	REMEMBER_TOKEN              VARCHAR2(100), 
	TURMA_ID           			NUMBER(10),    
	TEMPORARIO                  NUMBER(1),     
	HASHORARIOCOMPLETO          NUMBER(1),     
	PREFERENCIA                 VARCHAR2(10),  
	RAMO                        VARCHAR2(10),  
	REGIME                      VARCHAR2(10),  
	ROLE                        NUMBER(11),    
	ID                          NUMBER(10),
	rejected_by_screen CHAR	DEFAULT(0)   
);

CREATE TABLE t_data_uc_users(
	USER_ID                   NUMBER(10),
	UC_ID                     NUMBER(10),
	rejected_by_screen CHAR	DEFAULT(0)
);


CREATE TABLE t_data_ucs(
	ID                        NUMBER(10),   
	NOMEUC                    VARCHAR2(50),
	ABREVUC                   VARCHAR2(10), 
	ANOUC                     NUMBER(11),   
	SEMESTREUC                NUMBER(11),   
	RAMOUC                    VARCHAR2(30), 
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0)
);

CREATE TABLE t_data_turno_user(
	 USER_ID                   NUMBER(10),   
	TURNO_ID                  NUMBER(10),   
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0)
);

CREATE TABLE t_data_turnos(
	ID                        NUMBER(10),   
	ANOLECTIVO                NUMBER(11),   
	NOMEUC                    VARCHAR2(50), 
	REGIMEUC                  VARCHAR2(10),
	ABREVUC                   VARCHAR2(10), 
	ANOUC                     NUMBER(11), 
	SEMESTREUC                NUMBER(11), 
	RAMOUC                    VARCHAR2(5),
	TURNOUC                   VARCHAR2(5),
	MAX_ALUNOS                NUMBER(11),
	TIPOTURNO                 VARCHAR2(5),
	UC_ID                     NUMBER(10),
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0)
);

CREATE TABLE t_data_turma_turno(
	TURMA_ID                  NUMBER(10),
	TURNO_ID                  NUMBER(10), 
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0)
);

CREATE TABLE t_data_turmas(
	ID                        NUMBER(10),    
	ANOLECTIVO                NUMBER(11),    
	SEMESTRE                  NUMBER(11),    
	NOME                      VARCHAR2(50),  
	DESCRICAO                 VARCHAR2(255), 
	NUMESTUDANTES             NUMBER(11),    
	RAMO                      VARCHAR2(30),  
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0)  
);

CREATE TABLE t_data_trocas_turmas(
	ID                           NUMBER(10),   
	ANOLECTIVO                   NUMBER(11),   
	SEMESTRE                     NUMBER(11),   
	USER_SENDER                  NUMBER(10),   
	TURMA_ID_CORRENTE            NUMBER(10),   
	USER_RECEIVER                NUMBER(10),   
	TURMA_ID_PRETENDIDA          NUMBER(10),   
	ESTADOTROCA                  NUMBER(11),   
	TROCAGLOBAL                  NUMBER(1),    
	CREATED_AT                   TIMESTAMP(6), 
	SRC_LAST_CHANGED             TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0) 
);

CREATE TABLE t_data_trocas(
	ID                           NUMBER(10),   
	ANOLECTIVO                   NUMBER(11),   
	SEMESTRE                     NUMBER(11),   
	USER_SENDER                  NUMBER(10),   
	TURNO_ID_CORRENTE            NUMBER(10),   
	USER_RECEIVER                NUMBER(10),   
	TURNO_ID_PRETENDIDO          NUMBER(10),   
	ESTADOTROCA                  NUMBER(11),   
	TROCAGLOBAL                  NUMBER(1),    
	CREATED_AT                   TIMESTAMP(6), 
	SRC_LAST_CHANGED             TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0) 
);
CREATE TABLE t_data_settings(
	ID                        NUMBER(10),   
	ANOLECTIVO                NUMBER(11),   
	SEMESTRE                  NUMBER(11),   
	PERMITIRTROCAS            NUMBER(4),    
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0) 
);

CREATE TABLE t_data_presencas(
	ID                        NUMBER(10),   
	AULA_SEMANA_ID            NUMBER(10),   
	USER_ID                   NUMBER(10),   
	PRESENTE                  NUMBER(1),    
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen 		  CHAR	DEFAULT(0) 

);
CREATE TABLE t_data_aulas_semana(
	ID                        NUMBER(10),   
	SEMANA                    VARCHAR2(4),  
	DIASEMANA                 NUMBER(11),   
	HORAINICIO                VARCHAR2(10), 
	HORAFIM                   VARCHAR2(10), 
	SALA                      VARCHAR2(50), 
	DIA                       NUMBER(11),   
	MES                       NUMBER(11),  
	ANO_CIVIL                 NUMBER(11),   
	TURNO_ID                  NUMBER(10),   
	PROF_ID                   NUMBER(10),   
	MARCOU_PRESENCA           NUMBER(1),    
	NUM_PRESENCAS             NUMBER(11),   
	AULA_CANCELADA            NUMBER(4),   
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0) 
);

CREATE TABLE t_data_aulas(
	ID                        NUMBER(10),   
	DIASEMANA                 NUMBER(11),   
	HORAINICIO                VARCHAR2(10), 
	HORAFIM                   VARCHAR2(10), 
	SALA                      VARCHAR2(50), 
	SEMANAS                   VARCHAR2(50), 
	PROFESSOR                 VARCHAR2(50), 
	TURNO_ID                  NUMBER(10),  
	SRC_LAST_CHANGED          TIMESTAMP(6),
	rejected_by_screen CHAR	DEFAULT(0) 
);

CREATE TABLE t_data_area_cientifica_new(
	name        VARCHAR2(80),
    sigla       VARCHAR2(10)
);

CREATE TABLE t_data_area_cientifica_old AS SELECT * FROM t_data_area_cientifica_new;

CREATE TABLE t_data_departamentos_new(
	name        VARCHAR2(80),
    sigla       VARCHAR2(10)
);

CREATE TABLE t_data_departamentos_old AS SELECT * FROM t_data_departamentos_new;

CREATE TABLE t_data_curso_ei_new(
	uc          VARCHAR2(100),
    area_cientifica     VARCHAR2(10),
    departamento        VARCHAR2(10),
    rejected_by_screen  CHAR DEFAULT(0)
);

CREATE TABLE t_data_curso_ei_old AS SELECT * FROM t_data_curso_ei_new;