-- DATA FOR LOOKUP TABLES

INSERT INTO t_lookup_nomeucs (nomeuc_incorreto, nomeuc_correto) VALUES ('Algoritmos e Estruturas de Dados I','Algoritmos e Estruturas de Dados');
INSERT INTO t_lookup_nomeucs (nomeuc_incorreto, nomeuc_correto) VALUES ('Engenharia de Software II','Engenharia de Software');

INSERT INTO t_lookup_area_cientifica (nomeuc_acincorreto, nomeuc_accorreto) VALUES ('EI-SI','SI');
INSERT INTO t_lookup_area_cientifica (nomeuc_acincorreto, nomeuc_accorreto) VALUES ('EI-TIC','TIC');

-- DATA FOR THE TEL INNER SYSTEM
DECLARE
  v_iteration_key t_tel_iteration.iteration_key%TYPE;
  v_source_1 t_tel_source.source_key%TYPE;
  v_source_2 t_tel_source.source_key%TYPE;
  v_source_3 t_tel_source.source_key%TYPE;
  v_source_4 t_tel_source.source_key%TYPE;

  v_screen_1 t_tel_screen.screen_key%TYPE;
  v_screen_2 t_tel_screen.screen_key%TYPE;
  v_screen_3 t_tel_screen.screen_key%TYPE;
  v_screen_4 t_tel_screen.screen_key%TYPE;
  v_screen_5 t_tel_screen.screen_key%TYPE;

BEGIN
-- INSERTING into T_TEL_ITERATION
INSERT INTO t_tel_iteration (ITERATION_KEY,ITERATION_START_DATE,ITERATION_END_DATE,ITERATION_DURATION_REAL)
VALUES (1,SYSDATE,null,null) RETURNING iteration_key INTO v_iteration_key;

-- INSERTING into t_tel_source
INSERT INTO t_tel_source (source_key,source_file_name,source_database_name,source_host_ip,source_host_os,source_description)
VALUES (1,null,'BDADOS','172.20.19.20','LINUX RED HAT 3.0','Base de dados operacional das presencas dos estudantes') RETURNING source_key INTO v_source_1;
INSERT INTO t_tel_source (source_key,source_file_name,source_database_name,source_host_ip,source_host_os,source_description)
VALUES (2,'CURSO_EI.CSV',null,'172.20.19.20','LINUX RED HAT 3.0','Ficheiro contendo informa��o do Curso EI') RETURNING source_key INTO v_source_2;
INSERT INTO t_tel_source (source_key,source_file_name,source_database_name,source_host_ip,source_host_os,source_description)
VALUES (3,'AREAS_CIENTIFICAS.CSV',null,'172.20.19.20','LINUX RED HAT 3.0','Ficheiro contendo informa��o das Areas Cientificas') RETURNING source_key INTO v_source_3;
INSERT INTO t_tel_source (source_key,source_file_name,source_database_name,source_host_ip,source_host_os,source_description)
VALUES (4,'DEPARTAMENTOS.CSV',null,'172.20.19.20','LINUX RED HAT 3.0','Ficheiro contendo informa��o dos Departamentos') RETURNING source_key INTO v_source_4;

-- INSERTING into t_tel_screen
-- INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (1,'SCREEN_PRODUCT_DIMENSIONS','CORRE��O','Dimens�o errada','2.8','NO') RETURNING screen_key INTO v_screen_1;
-- INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (2,'SCREEN_NULL_LIQ_WEIGHT','COMPLETUDE','Peso l�quido com problemas','2.8','NO') RETURNING screen_key INTO v_screen_2;
-- INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (3,'SCREEN_INCORRECT_BRANDS','CORRE��O','Marca inexistente','2.8','NO') RETURNING screen_key INTO v_screen_3;

INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (1,'SCREEN_REGIME_WRONG','CORRECAO','Regime Indefinido','2.8','NO') RETURNING screen_key INTO v_screen_1;
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (2,'SCREEN_UCS','CORRECAO','UC Mal Escrita','2.8','NO') RETURNING screen_key INTO v_screen_2;
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (3,'SCREEN_NOME_UCS','CORRECAO','UC Repetida','2.8','NO') RETURNING screen_key INTO v_screen_3;
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (4,'SCREEN_AULAS_CANCELADAS','CORRECAO','Aula Cancelada','2.8','NO') RETURNING screen_key INTO v_screen_4;
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (5,'SCREEN_USER_NOTENROLLED','CORRECAO','Utilizador nao inscrito','2.8','NO') RETURNING screen_key INTO v_screen_5;

-- INSERTING into T_TEL_DATE
INSERT INTO t_tel_date (DATE_KEY, DATE_FULL, YEAR_NR, MONTH_NR, MONTH_NAME_FULL, MONTH_NAME_SHORT, DAY_NR)
SELECT date_key, date_full_date, date_year, date_month_nr, date_month_name, date_month_short_name, date_day_nr
FROM t_tel_ext_dates;

   -- INSERTING into T_TEL_SCHEDULE
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_1,v_iteration_key,v_source_1,1);
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_2,v_iteration_key,v_source_1,2);
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_3,v_iteration_key,v_source_1,3);
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_4,v_iteration_key,v_source_1,4);
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_5,v_iteration_key,v_source_1,5);


   COMMIT;
END;
/
