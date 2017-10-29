create or replace PACKAGE BODY pck_extract IS

   e_extraction EXCEPTION;

   -- ************************************************************
   -- * USED FOR READING SOURCE TEXT FILES                       *
   -- ************************************************************
   PROCEDURE read_file(p_dir VARCHAR2, p_file_name VARCHAR2) IS
      v_line NVARCHAR2(32767);
      v_file UTL_FILE.FILE_TYPE;
   BEGIN
      SET TRANSACTION READ WRITE NAME 'read file from server''s directory';
      DELETE FROM t_info_file_reading;
      v_file := UTL_FILE.FOPEN_NCHAR(UPPER(p_dir),p_file_name,'R');
      LOOP
         UTL_FILE.GET_LINE_NCHAR(v_file,v_line,32767);
         INSERT INTO t_info_file_reading VALUES (v_line);
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         UTL_FILE.FCLOSE(v_file);
         COMMIT;
      WHEN UTL_FILE.INVALID_PATH THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20001,'invalid_path ['||sqlerrm||']');
      WHEN UTL_FILE.INVALID_MODE THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20002,'invalid_mode ['||sqlerrm||']');
      WHEN UTL_FILE.INVALID_FILEHANDLE THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20003,'invalid_filehandle ['||sqlerrm||']');
      WHEN UTL_FILE.INVALID_OPERATION THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20004,'invalid_operation ['||sqlerrm||']');
      WHEN UTL_FILE.READ_ERROR THEN
         ROLLBACK;
         UTL_FILE.FCLOSE(v_file);
         RAISE_APPLICATION_ERROR(-20005,'read_error ['||sqlerrm||']');
      WHEN UTL_FILE.INTERNAL_ERROR THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20007,'internal_error ['||sqlerrm||']');
      WHEN OTHERS THEN
         ROLLBACK;
         UTL_FILE.FCLOSE(v_file);
         RAISE_APPLICATION_ERROR(-20009,'unknown_error ['||sqlerrm||']');
   END;



   -- **********************************************
   -- * INTITALIZES THE t_info_extractions TABLE   *
   -- **********************************************
   PROCEDURE initialize_extractions_table (p_clean_before BOOLEAN) IS
      v_source_table VARCHAR2(100);
   BEGIN
      BEGIN
        pck_log.write_log('  Initializing data required for extraction ["INITIALIZE_EXTRACTIONS_TABLE"]');
         IF p_clean_before=TRUE THEN
            pck_log.write_log('    Deleting previous data');
            DELETE FROM t_info_extractions;
            pck_log.write_log('      Done!');

            pck_log.write_log('    Deleting %_new and %_old data');
            DELETE FROM t_data_area_cientifica_new;
            DELETE FROM t_data_area_cientifica_old; 
            DELETE FROM t_data_departamentos_new;
            DELETE FROM t_data_departamentos_old;
            --DELETE FROM t_data_curso_ei_new;
            --DELETE FROM t_data_curso_ei_old;
            pck_log.write_log('      Done!');
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
            RAISE e_extraction;
      END;
      
       v_source_table:='ei_sad_proj_gisem.v_ucs';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_turno_user';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_users';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_uc_user';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_turnos';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_turma_turno';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_turmas';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_trocas_turma';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_trocas';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_settings';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_presencas';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_aulas_semana';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
       v_source_table:='ei_sad_proj_gisem.v_aulas';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
      
      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_extraction;
   END;


   -- ********************************************************************
   -- *                     TABLE_EXTRACT                                *
   -- *                                                                  *
   -- * EXTRACT NEW AND CHANGED ROWS FROM SOURCE TABLE                   *
   -- * IN                                                               *
   -- *   p_source_table: the source table/view to use                   *
   -- *   p_attributes_src: list of attributes to extract from           *
   -- *   p_attributes_dest: list of attributes to fill                  *
   -- *   p_dsa_table: name of the t_data_* table to fill                *
   -- ********************************************************************
   PROCEDURE table_extract (p_source_table VARCHAR2, p_DSA_table VARCHAR2, p_attributes_src VARCHAR2, p_attributes_dest VARCHAR2) IS
      v_end_date TIMESTAMP;
      v_start_date t_info_extractions.LAST_TIMESTAMP%TYPE;
      v_sql  VARCHAR2(1000);
   BEGIN 
      pck_log.write_log('  Extracting data ["TABLE_EXTRACT ('||UPPER(p_source_table)||')"]');
     pck_log.rowcount(p_DSA_table,'Before');    -- Logs how many rows the destination table initially contains

      -- CLEAN DESTINATION TABLE
      v_sql := 'DELETE FROM '|| p_DSA_table;
      pck_log.write_log(v_sql);
      EXECUTE IMMEDIATE v_sql;

         --  find the date of change of the last record extracted in the previous extraction 
         v_sql:='SELECT last_timestamp FROM t_info_extractions WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
         EXECUTE IMMEDIATE v_sql INTO v_start_date;

         --    ---------------------
         --   |   FISRT EXTRACTION  |
         --    ---------------------
        IF v_start_date IS NULL THEN

            -- FIND THE DATE OF CHANGE OF THE MOST RECENTLY CHANGED RECORD IN THE SOURCE TABLE
            v_sql:='SELECT MAX(src_last_changed) FROM '|| p_source_table;
             pck_log.write_log(v_sql);

             EXECUTE IMMEDIATE v_sql INTO v_end_date;

            -- EXTRACT ALL RELEVANT RECORDS FROM THE SOURCE TABLE TO THE DSA
            -- SOMETHING IS MISSING
            v_sql := 'INSERT INTO '|| p_DSA_table ||'('||p_attributes_dest||') SELECT '|| p_attributes_src||' FROM '|| p_source_table || ' WHERE src_last_changed<= :1 OR src_last_changed IS null'; 
            pck_log.write_log(v_sql);
            EXECUTE IMMEDIATE v_sql USING v_end_date;

            -- UPDATE THE t_info_extractions TABLE
            -- SOMETHING IS MISSING
            v_sql:='UPDATE t_info_extractions SET last_timestamp = :1 '||
            'WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
        pck_log.write_log(v_sql);
            EXECUTE IMMEDIATE v_sql USING v_end_date;
         ELSE
         --    -------------------------------------
         --   |  OTHER EXTRACTIONS AFTER THE FIRST  |
         --    -------------------------------------
            -- FIND THE DATE OF CHANGE OF THE MOST RECENTLY CHANGED RECORD IN THE SOURCE TABLE
             v_sql:='SELECT MAX(src_last_changed) FROM '|| p_source_table || 'WHERE src_last_changed>=:1';
             pck_log.write_log(v_sql);

            EXECUTE IMMEDIATE v_sql INTO v_end_date USING v_start_date;

            IF v_end_date>v_start_date THEN
               -- EXTRACT ALL RELEVANT RECORDS FROM THE SOURCE TABLE TO THE DSA
               -- SOMETHING IS MISSING
                 v_sql := 'INSERT INTO '|| p_DSA_table ||'('||p_attributes_dest||') SELECT '|| p_attributes_src||' FROM '|| p_source_table || ' WHERE src_last_changed<= :2 AND src_last_changed>=:1'; 
                pck_log.write_log(v_sql);


               EXECUTE IMMEDIATE v_sql USING v_start_date, v_end_date;

              v_sql:='UPDATE t_info_extractions SET last_timestamp = :1 '||
            'WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
             pck_log.write_log(v_sql);
            EXECUTE IMMEDIATE v_sql USING v_end_date;

            END IF;
         END IF;

      pck_log.write_log('    Done!');
      pck_log.rowcount(p_DSA_table,'After');    -- Logs how many rows the destination table now contains
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_extraction;
   END;


   -- **************************************************************
   -- *                       FILE_EXTRACT                         *
   -- *                                                            *
   -- * EXTRACT ROWS FROM SOURCE FILE                              *
   -- * IN                                                         *
   -- *    p_external_table: the external table to use             *
   -- *    p_attributes_src: list of attributes to extract         *
   -- *    p_attributes_dest: list of attributes to fill           *
   -- *    p_dsa_table_new: name of the t_data_*_new table to fill *
   -- *    p_dsa_table_old: name of the t_data_*_old table to fill *
   -- **************************************************************
   PROCEDURE file_extract (p_external_table VARCHAR2, p_attributes_src VARCHAR2, p_attributes_dest VARCHAR2, p_dsa_table_new VARCHAR2, p_dsa_table_old VARCHAR2) IS
      v_sql  VARCHAR2(1000);
   BEGIN
      pck_log.write_log('  Extracting data ["FILE_EXTRACT ('||UPPER(p_external_table)||')"]');      
     pck_log.rowcount(p_dsa_table_new,'Before');    -- Logs how many rows the destination table initially contains

      -- 1º Operação = CLEAN _old TABLE
      v_sql := 'DELETE FROM '||p_dsa_table_old;
      pck_log.write_log(v_sql);
      EXECUTE IMMEDIATE v_sql;
      -- DELETE FROM p_dsa_table_old;       ->  não se faz assim, senão tentava procurar a tabela com aquele nome

      -- 2º Operação = transferir dados do ficheiro NEW para OLD
      v_sql := 'INSERT INTO ' || p_dsa_table_old || ' ('|| p_attributes_dest || ') SELECT ' || p_attributes_dest || ' FROM ' || p_dsa_table_new;
      pck_log.write_log(v_sql);
      EXECUTE IMMEDIATE v_sql;

      -- 3º Operação = limpar tabela NEW
      v_sql := 'DELETE FROM '||p_dsa_table_new;
      pck_log.write_log(v_sql);
      EXECUTE IMMEDIATE v_sql;

      -- 4º Operação = extrair dados do ficheiro
      v_sql := 'INSERT INTO ' || p_dsa_table_new || ' ('|| p_attributes_dest || ') SELECT ' || p_attributes_src || ' FROM ' || p_external_table;
      pck_log.write_log(v_sql);
      EXECUTE IMMEDIATE v_sql;

      -- records the operation's SUCCESSFUL ending
     pck_log.write_log('    Done!');
      pck_log.rowcount(p_dsa_table_new,'After');    -- Logs how many rows the destination table now contains
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_extraction;
   END;


   -- ********************************************************************
   -- *                TABLE_EXTRACT_NON_INCREMENTAL                     *
   -- *                                                                  *
   -- * EXTRACT ROWS FROM SOURCE TABLE IN NON INCREMENTAL WAY            *
   -- * IN: (same as table_extract)                                      *
   -- ********************************************************************
   PROCEDURE table_extract_non_incremental (p_source_table VARCHAR2, p_DSA_table VARCHAR2, p_attributes_src VARCHAR2, p_attributes_dest VARCHAR2) IS
      v_sql  VARCHAR2(1000);
   BEGIN 
      pck_log.write_log('  Extracting data ["TABLE_EXTRACT_NON_INCREMENTAL ('||UPPER(p_source_table)||')"]');
     pck_log.rowcount(p_DSA_table,'Before');    -- Logs how many rows the destination table initially contains

      -- LIMPAR A TABELA DESTINO
      EXECUTE IMMEDIATE 'DELETE FROM '||p_DSA_table;

      -- extrair TODOS os registos da tabela fonte para a tabela correspondente na DSA
      v_sql:='INSERT INTO '||p_DSA_table||'('|| p_attributes_dest||',rejected_by_screen) SELECT '||p_attributes_src||',''0'' FROM '||p_source_table;
      EXECUTE IMMEDIATE v_sql;

     pck_log.write_log('    Done!');     
     pck_log.rowcount(p_DSA_table,'After');    -- Logs how many rows the destination table now contains
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_extraction;
   END;


   -- *****************************************************************************
   -- *                                        MAIN                               *
   -- *                                                                           *
   -- * EXECUTE THE EXTRACTION PROCESS                                            *
   -- * IN                                                                        *
   -- *     p_initialize: TRUE=t_info_extractions will be cleaned and then filled *
   -- *****************************************************************************
   PROCEDURE main (p_initialize BOOLEAN) IS
   BEGIN
      pck_log.clean;
      pck_log.write_log('*****  EXTRACT  EXTRACT  EXTRACT  EXTRACT  EXTRACT  EXTRACT  EXTRACT  *****');      -- DUPLICATES THE LAST ITERATION AND THE CORRESPONDING SCREEN SCHEDULE

      -- INITIALIZE THE EXTRACTION TABLE t_info_extractions
      IF p_initialize = TRUE THEN
         initialize_extractions_table(TRUE);
      END IF;

      -- EXTRACT FROM SOURCE TABLES

     -- SOMETHING IS MISSING: maybe... a table extraction
     -- table_extract('view_produtos@dblink_sadsb','t_data_products','src_id,src_name,src_brand,src_width,src_height,src_depth,src_pack_type,src_calories_100g,src_liq_weight,src_category_id','id,name,brand,width,height,depth,pack_type,calories_100g,liq_weight,category_id');
     --  table_extract('view_linhasvenda@dblink_sadsb', 't_data_linesofsale', 'src_id,src_sale_id,src_product_id,src_quantity,src_ammount_paid,src_line_date', 'id,sale_id,product_id,quantity,ammount_paid,line_date');
     --  table_extract('view_promocoes@dblink_sadsb', 't_data_promotions','src_id,src_name,src_start_date,src_end_date,src_reduction,src_on_outdoor,src_on_tv','id,name,start_date,end_date,reduction,on_outdoor,on_tv');
     --  table_extract('view_linhasvenda_promocoes@dblink_sadsb', 't_data_linesofsalepromotions','src_line_id,src_promo_id','line_id,promo_id');
     table_extract('ei_sad_proj_gisem.v_ucs','t_data_ucs','id,nomeuc,abrevuc,anouc,semestreuc,ramouc,src_last_changed','id,nomeuc,abrevuc,anouc,semestreuc,ramouc,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_turno_user','t_data_turno_user','user_id,turno_id,src_last_changed','user_id,turno_id,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_users','t_data_users','created_at,remember_token,turma_id,temporario,hashorariocompleto,preferencia,ramo,regime,role,id','created_at,remember_token,turma_id,temporario,hashorariocompleto,preferencia,ramo,regime,role,id');
    table_extract('ei_sad_proj_gisem.v_uc_user','t_data_uc_users','user_id,uc_id','user_id,uc_id');
    table_extract('ei_sad_proj_gisem.v_turnos','t_data_turnos','id,anolectivo,nomeuc,regimeuc,abrevuc,anouc,semestreuc,ramouc,turnouc,max_alunos,tipoturno,uc_id,src_last_changed','id,anolectivo,nomeuc,regimeuc,abrevuc,anouc,semestreuc,ramouc,turnouc,max_alunos,tipoturno,uc_id,src_last_changed'); 
    table_extract('ei_sad_proj_gisem.v_turma_turno','t_data_turma_turno','turma_id,turno_id,src_last_changed','turma_id,turno_id,src_last_changed'); 
    table_extract('ei_sad_proj_gisem.v_turmas','t_data_turmas','id,anolectivo,semestre,nome,descricao,numestudantes,ramo,src_last_changed','id,anolectivo,semestre,nome,descricao,numestudantes,ramo,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_trocas_turma','t_data_trocas_turmas','id,anolectivo,semestre,user_sender,turma_id_pretendida,estadotroca,trocaglobal,created_at,src_last_changed','id,anolectivo,semestre,user_sender,turma_id_pretendida,estadotroca,trocaglobal,created_at,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_trocas','t_data_trocas','id,anolectivo,semestre,user_sender,turno_id_corrente,user_receiver,turno_id_pretendido,estadotroca,trocaglobal,created_at,src_last_changed','id,anolectivo,semestre,user_sender,turno_id_corrente,user_receiver,turno_id_pretendido,estadotroca,trocaglobal,created_at,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_settings','t_data_settings','id,anolectivo,semestre,permitirtrocas,src_last_changed','id,anolectivo,semestre,permitirtrocas,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_presencas','t_data_presencas','id,aula_semana_id,user_id,presente,src_last_changed','id,aula_semana_id,user_id,presente,src_last_changed');
    table_extract('ei_sad_proj_gisem.v_aulas_semana','t_data_aulas_semana','id,semana,diasemana,horainicio,horafim,sala,dia,mes,ano_civil,turno_id,prof_id,marcou_presenca,num_presencas,aula_cancelada,src_last_changed','id,semana,diasemana,horainicio,horafim,sala,dia,mes,ano_civil,turno_id,prof_id,marcou_presenca,num_presencas,aula_cancelada,src_last_changed');
     table_extract('ei_sad_proj_gisem.v_aulas','t_data_aulas','id,diasemana,horainicio,horafim,sala,semanas,professor,turno_id,src_last_changed','id,diasemana,horainicio,horafim,sala,semanas,professor,turno_id,src_last_changed');
     
     --  table_extract_non_incremental('view_categorias@dblink_sadsb', 't_data_categories', 'src_id,src_name', 'id,name');

      -- SOMETHING IS MISSING: maybe... a file extraction
      --file_extract ('t_ext_stores', 'name,refer,building,address,zip_code,city,district,phone_nrs,fax_nr,closure_date',
      --               'name,reference,building,address,zip_code,location,district,telephones,fax,closure_date','t_data_stores_new', 't_data_stores_old');

      --file_extract ('t_ext_managers', 'refer,store_manager_name,store_manager_since', 'reference,manager_name,manager_since', 't_data_managers_new', 't_data_managers_old');

     file_extract('t_ext_area_cientifica','name,sigla','name,sigla','t_data_area_cientifica_new','t_data_area_cientifica_old');
     file_extract('t_ext_departamentos','name,sigla','name,sigla','t_data_departamentos_new','t_data_departamentos_old');
     --file_extract('t_ext_curso_ei','uc,area_cientifica,departamento','uc,area_cientifica,departamento','t_data_curso_ei_new','t_data_curso_ei_old');

      COMMIT;
      pck_log.write_log('  All extracted data commited to database.');
   EXCEPTION
      WHEN e_extraction THEN
         pck_log.write_halt_msg;
         ROLLBACK;
      WHEN OTHERS THEN
         ROLLBACK;
         pck_log.write_uncomplete_task_msg;
         pck_log.write_halt_msg;
   END;

END pck_extract;