-- DATA FOR LOOKUP TABLES
INSERT INTO t_lookup_calories(min_calories_100g,max_calories_100g,type,description) VALUES (0,10,'Extra-light','Sobretudo para dietas');
INSERT INTO t_lookup_calories(min_calories_100g,max_calories_100g,type,description) VALUES (11,30,'Light','Poucas calorias');
INSERT INTO t_lookup_calories(min_calories_100g,max_calories_100g,type) VALUES (31,70,'Regular');
INSERT INTO t_lookup_calories(min_calories_100g,max_calories_100g,type,description) VALUES (71,9999,'Fat','Muitas calorias');

INSERT INTO t_lookup_pack_dimensions (pack_type,has_dimensions) VALUES ('CAIXA',1);
INSERT INTO t_lookup_pack_dimensions (pack_type,has_dimensions) VALUES ('SACO',0);
INSERT INTO t_lookup_pack_dimensions (pack_type,has_dimensions) VALUES ('LATA',1);
INSERT INTO t_lookup_pack_dimensions (pack_type,has_dimensions) VALUES ('PEL�CULA',0);

INSERT INTO t_lookup_brands (brand_wrong, brand_transformed) VALUES ('C�pina','Campina');
INSERT INTO t_lookup_brands (brand_wrong, brand_transformed) VALUES ('Canpina','Campina');

-- DATA FOR THE TEL INNER SYSTEM
DECLARE
  v_iteration_key t_tel_iteration.iteration_key%TYPE;
  v_source_1 t_tel_source.source_key%TYPE;
  v_source_2 t_tel_source.source_key%TYPE;
  v_screen_1 t_tel_screen.screen_key%TYPE;
  v_screen_2 t_tel_screen.screen_key%TYPE;
  v_screen_3 t_tel_screen.screen_key%TYPE;
BEGIN
-- INSERTING into T_TEL_ITERATION
INSERT INTO t_tel_iteration (ITERATION_KEY,ITERATION_START_DATE,ITERATION_END_DATE,ITERATION_DURATION_REAL)
VALUES (1,SYSDATE,null,null) RETURNING iteration_key INTO v_iteration_key;

-- INSERTING into t_tel_source
INSERT INTO t_tel_source (source_key,source_file_name,source_database_name,source_host_ip,source_host_os,source_description)
VALUES (1,null,'SALES_SRC','172.20.19.21','LINUX RED HAT 3.0','Base de dados operacional da cadeia de lojas SB') RETURNING source_key INTO v_source_1;
INSERT INTO t_tel_source (source_key,source_file_name,source_database_name,source_host_ip,source_host_os,source_description)
VALUES (2,'LOJAS.XLS',null,'172.20.19.21','LINUX RED HAT 3.0','Ficheiro contendo informa��o das lojas da cadeia de lojas e dos seus gestores') RETURNING source_key INTO v_source_2;

-- INSERTING into t_tel_screen
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (1,'SCREEN_PRODUCT_DIMENSIONS','CORRE��O','Dimens�o errada','2.8','NO') RETURNING screen_key INTO v_screen_1;
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (2,'SCREEN_NULL_LIQ_WEIGHT','COMPLETUDE','Peso l�quido com problemas','2.8','NO') RETURNING screen_key INTO v_screen_2;
INSERT INTO t_tel_screen (SCREEN_KEY,SCREEN_NAME,SCREEN_CLASS,SCREEN_DESCRIPTION,SCREEN_VERSION,SCREEN_EXPIRED) values (3,'SCREEN_INCORRECT_BRANDS','CORRE��O','Marca inexistente','2.8','NO') RETURNING screen_key INTO v_screen_3;

-- INSERTING into T_TEL_DATE
INSERT INTO t_tel_date (DATE_KEY, DATE_FULL, YEAR_NR, MONTH_NR, MONTH_NAME_FULL, MONTH_NAME_SHORT, DAY_NR) 
SELECT date_key, date_full_date, date_year, date_month_nr, date_month_name, date_month_short_name, date_day_nr
FROM t_tel_ext_dates;

   -- INSERTING into T_TEL_SCHEDULE
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_1,v_iteration_key,v_source_1,1);
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_2,v_iteration_key,v_source_1,2);
   INSERT INTO t_tel_schedule (SCREEN_KEY,ITERATION_KEY,SOURCE_KEY,SCREEN_ORDER) values (v_screen_3,v_iteration_key,v_source_1,3);

   COMMIT;
END;
/

