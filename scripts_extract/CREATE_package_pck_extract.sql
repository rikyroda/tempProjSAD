CREATE OR REPLACE PACKAGE pck_extract IS
   PROCEDURE main (p_initialize BOOLEAN);
   PROCEDURE read_file(p_dir VARCHAR2, p_file_name VARCHAR2);
END pck_extract;

/


create or replace
PACKAGE BODY pck_extract IS

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
            DELETE FROM t_data_managers_new;
            DELETE FROM t_data_managers_old;
            DELETE FROM t_data_stores_new;
            DELETE FROM t_data_stores_old;
            pck_log.write_log('      Done!');
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
			pck_log.write_uncomplete_task_msg;
            RAISE e_extraction;
      END;

      v_source_table:='view_produtos@DBLINK_SADSB';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
      v_source_table:='view_promocoes@DBLINK_SADSB';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
      v_source_table:='view_vendas@DBLINK_SADSB';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
      v_source_table:='view_linhasvenda@DBLINK_SADSB';
      INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,v_source_table);
      v_source_table:='view_linhasvenda_promocoes@DBLINK_SADSB';
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
      -- SOMETHING IS MISSING
      null;

         --  find the date of change of the last record extracted in the previous extraction 
         v_sql:='SELECT last_timestamp FROM t_info_extractions WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
         EXECUTE IMMEDIATE v_sql INTO v_start_date;

         --    ---------------------
         --   |   FISRT EXTRACTION  |
         --    ---------------------
        IF v_start_date IS NULL THEN

            -- FIND THE DATE OF CHANGE OF THE MOST RECENTLY CHANGED RECORD IN THE SOURCE TABLE
            -- SOMETHING IS MISSING
			null;
            
            EXECUTE IMMEDIATE v_sql INTO v_end_date;
            

            -- EXTRACT ALL RELEVANT RECORDS FROM THE SOURCE TABLE TO THE DSA
            -- SOMETHING IS MISSING
            null;
            EXECUTE IMMEDIATE v_sql USING v_end_date;
                        
            -- UPDATE THE t_info_extractions TABLE
            -- SOMETHING IS MISSING
			null;
            EXECUTE IMMEDIATE v_sql USING v_end_date;
         ELSE
         --    -------------------------------------
         --   |  OTHER EXTRACTIONS AFTER THE FIRST  |
         --    -------------------------------------
            -- FIND THE DATE OF CHANGE OF THE MOST RECENTLY CHANGED RECORD IN THE SOURCE TABLE
            -- SOMETHING IS MISSING
            null;
			
            EXECUTE IMMEDIATE v_sql INTO v_end_date USING v_start_date;

            IF v_end_date>v_start_date THEN
               -- EXTRACT ALL RELEVANT RECORDS FROM THE SOURCE TABLE TO THE DSA
               -- SOMETHING IS MISSING
               null;
			   
               EXECUTE IMMEDIATE v_sql USING v_start_date, v_end_date;

               -- UPDATE THE t_info_extractions TABLE
               -- SOMETHING IS MISSING
               null;
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

      -- CLEAN _old TABLE
      EXECUTE IMMEDIATE 'DELETE FROM '||p_dsa_table_old;

      -- SOMETHING IS MISSING. THINK!
      null;

      -- SOMETHING IS MISSING. THINK HARDER!
      null;

      -- SOMETHING IS MISSING. THINK EVEN HARDER!
      null;

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
	  null;
	  table_extract('view_produtos@dblink_sadsb','t_data_products','src_id,src_name,src_brand,src_width,src_height,src_depth,src_pack_type,src_calories_100g,src_liq_weight,src_category_id','id,name,brand,width,height,depth,pack_type,calories_100g,liq_weight,category_id');
      table_extract('view_linhasvenda@dblink_sadsb', 't_data_linesofsale', 'src_id,src_sale_id,src_product_id,src_quantity,src_ammount_paid,src_line_date', 'id,sale_id,product_id,quantity,ammount_paid,line_date');
      table_extract('view_promocoes@dblink_sadsb', 't_data_promotions','src_id,src_name,src_start_date,src_end_date,src_reduction,src_on_outdoor,src_on_tv','id,name,start_date,end_date,reduction,on_outdoor,on_tv');
      table_extract('view_linhasvenda_promocoes@dblink_sadsb', 't_data_linesofsalepromotions','src_line_id,src_promo_id','line_id,promo_id');
      table_extract_non_incremental('view_categorias@dblink_sadsb', 't_data_categories', 'src_id,src_name', 'id,name');
	  
      -- SOMETHING IS MISSING: maybe... a file extraction
      file_extract ('t_ext_stores', 'name,refer,building,address,zip_code,city,district,phone_nrs,fax_nr,closure_date',
                     'name,reference,building,address,zip_code,location,district,telephones,fax,closure_date','t_data_stores_new', 't_data_stores_old');
	  null;
	  
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
/
