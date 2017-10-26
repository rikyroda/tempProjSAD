CREATE OR REPLACE PACKAGE PCK_TRANSFORM AS

   PROCEDURE main (p_duplicate_last_iteration BOOLEAN);
   PROCEDURE screen_product_dimensions (p_iteration_key t_tel_iteration.iteration_key%TYPE,
										p_source_key t_tel_source.source_key%TYPE,
										p_screen_order t_tel_schedule.screen_order%TYPE);
										
   /*PROCEDURE screen_incorrect_brands (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                      p_source_key t_tel_source.source_key%TYPE,
                                      p_screen_order t_tel_schedule.screen_order%TYPE);*/

   PROCEDURE screen_null_liq_weight (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                     p_source_key t_tel_source.source_key%TYPE,
                                     p_screen_order t_tel_schedule.screen_order%TYPE);
END PCK_TRANSFORM;
/

create or replace PACKAGE BODY pck_transform IS

   e_transformation EXCEPTION;
   
   -- *********************************************
   -- * PUTS AN ERROR IN THE FACT TABLE OF ERRORS *
   -- *********************************************
   PROCEDURE error_log(p_screen_name t_tel_screen.screen_name%TYPE,
                       p_hora_deteccao DATE,
                       p_source_key      t_tel_source.source_key%TYPE,
                       p_iteration_key   t_tel_iteration.iteration_key%TYPE,
                       p_record_id       t_tel_error.record_id%TYPE) IS
      v_date_key t_tel_date.date_key%TYPE;
      v_screen_key t_tel_screen.screen_key%TYPE;
   BEGIN
      -- obtém o id da dimensão «date» referente ao dia em que o erro foi detectado
      BEGIN
         SELECT date_key
         INTO v_date_key
         FROM t_tel_date
         WHERE date_full=TO_CHAR(p_hora_deteccao,'DD-MM-YYYY');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pck_log.write_log('    -- ERROR --   could not find date key from "t_tel_date" ['||sqlerrm||']');
            RAISE e_transformation;
      END;

      BEGIN
         SELECT screen_key
         INTO v_screen_key
         FROM t_tel_screen
         WHERE UPPER(screen_name)=UPPER(p_screen_name);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pck_log.write_log('    -- ERROR --   could not find screen key from "t_tel_screen" ['||sqlerrm||']');
            RAISE e_transformation;
      END;

      INSERT INTO t_tel_error (date_key,screen_key,source_key,iteration_key, record_id) VALUES (v_date_key,v_screen_key,p_source_key,p_iteration_key, p_record_id);
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('    -- ERROR --   could not write quality problem to "t_tel_error" fact table ['||sqlerrm||']');
         RAISE e_transformation;
   END;



   -- *******************************************
   -- * DUPLICATES THE LAST SCHEDULED ITERATION *
   -- *******************************************
   PROCEDURE duplicate_last_iteration(p_start_date t_tel_iteration.iteration_start_date%TYPE) IS
      v_last_iteration_key t_tel_iteration.iteration_key%TYPE;
      v_new_iteration_key t_tel_iteration.iteration_key%TYPE;
      
      CURSOR c_scheduled_screens(p_iteration_key t_tel_iteration.iteration_key%TYPE) IS
         SELECT s.screen_key as screen_key,screen_name,screen_order, s.source_key
         FROM t_tel_schedule s, t_tel_screen
         WHERE iteration_key=p_iteration_key AND
               s.screen_key = t_tel_screen.screen_key;
   BEGIN
      pck_log.write_log('  Creating new iteration by duplicating the previous one');
      
      -- FIND THE LAST ITERATIONS'S KEY
      BEGIN
         SELECT MAX(iteration_key)
         INTO v_last_iteration_key
         FROM t_tel_iteration;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pck_log.write_log('    -- ERROR --   could not find iteration key ['||sqlerrm||']');
            RAISE e_transformation;
      END;

      INSERT INTO t_tel_iteration(iteration_start_date) VALUES (p_start_date) RETURNING iteration_key INTO v_new_iteration_key;
      FOR rec IN c_scheduled_screens(v_last_iteration_key) LOOP
         -- schedule screen
         INSERT INTO t_tel_schedule(screen_key,iteration_key,source_key,screen_order)
         VALUES (rec.screen_key,v_new_iteration_key,rec.source_key,rec.screen_order);
      END LOOP;
      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    -- ERROR --   previous iteration has no screens to reschedule');
         RAISE e_transformation;
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;


   PROCEDURE screen_product_dimensions (p_iteration_key t_tel_iteration.iteration_key%TYPE,
										p_source_key t_tel_source.source_key%TYPE,
										p_screen_order t_tel_schedule.screen_order%TYPE) IS
      -- SEARCH FOR EXTRACTED PRODUCTS CONTAINING PROBLEMS
      CURSOR products_with_problems IS
         SELECT rowid
         FROM t_data_products
         WHERE rejected_by_screen='0'
               AND (((width IS NULL OR height IS NULL OR depth IS NULL) AND UPPER(pack_type) IN (SELECT pack_type
                                                                          FROM t_lookup_pack_dimensions
                                                                          WHERE has_dimensions='1'))
               OR ((width>=0 OR height>=0 OR depth>=0 AND UPPER(pack_type) IN (SELECT pack_type
                                                                               FROM t_lookup_pack_dimensions
                                                                               WHERE has_dimensions='0'))));
      i PLS_INTEGER:=0;
      v_screen_name VARCHAR2(30):='screen_product_dimensions';
   BEGIN
      pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');
      FOR rec IN products_with_problems LOOP
         -- RECORDS THE ERROR IN THE TRANSFORMATION ERROR LOGGER BUT DOES * NOT REJECT THE LINE *
         error_log(v_screen_name,SYSDATE,p_source_key,p_iteration_key,rec.rowid);
         i:=i+1;
      END LOOP;
      pck_log.write_log('    Data quality problems in '|| i || ' row(s).','    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    No data quality problems found.','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;
 

   -- *************************************************************************************
   -- * GOAL: detect and reject packed products with an empty liquid weight               *
   -- * QUALITY CRITERIUM: "Completude"                                                   *
   -- * PARAMETERS:                                                                       *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************
   PROCEDURE screen_null_liq_weight (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                     p_source_key t_tel_source.source_key%TYPE,
                                     p_screen_order t_tel_schedule.screen_order%TYPE) IS
      -- SOMETHING IS MISSING
      -- ???

      i PLS_INTEGER:=0;
      v_screen_name VARCHAR2(30):='screen_null_liq_weight';
   BEGIN
      pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

      -- SOMETHING IS MISSING
      null;

      pck_log.write_log('    Data quality problems in '|| i || ' row(s).','    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    No data quality problems found.','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;


   
   
   -- *************************************************************************************
   -- * GOAL: detect incorrect data in products                                        *
   -- * QUALITY CRITERIUM: "Correção"                                                 *
   -- * PARAMETERS:                                                                       *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************
	PROCEDURE screen_incorrect_products (	p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                            p_source_key t_tel_source.source_key%TYPE,
                                            p_screen_order t_tel_schedule.screen_order%TYPE) IS
		-- SOMETHING IS MISSING
		-- ???
         
		i PLS_INTEGER:=0;
		v_screen_name VARCHAR2(30):='screen_incorrect_products';
	BEGIN     
		pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

		-- SOMETHING IS MISSING
		null;

      pck_log.write_log('    Data quality problems in '|| i || ' row(s).','    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    No data quality problems found.','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;

   


   
   
   
   
   
   

   -- ####################### TRANSFORMATION ROUTINES #######################

	PROCEDURE transform_products IS
	BEGIN
		pck_log.write_log('  Transforming data ["TRANSFORM_PRODUCTS"]');

		INSERT INTO t_clean_products(id,name,brand,pack_size,pack_type,diet_type,liq_weight,category_name)
		SELECT prod.id,prod.name,brand,height||'x'||width||'x'||depth,pack_type,cal.type,liq_weight,categ.name
		FROM t_data_products prod, t_lookup_calories cal, t_data_categories categ
		WHERE 	categ.rejected_by_screen='0'
				AND prod.rejected_by_screen='0'
				AND calories_100g>=cal.min_calories_100g
				AND calories_100g<=cal.max_calories_100g
				AND	categ.id=prod.category_id;

		-- SOMETHING IS MISSING
		null;

		pck_log.write_log('    Done!');
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			pck_log.write_log('    Found no lines to transform','    Done!');
		WHEN OTHERS THEN
           pck_log.write_uncomplete_task_msg;
		   RAISE e_transformation;
	END;



   -- **********************************************************
   -- * TRANSFORMATION OF STORES ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_stores IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_STORES"]');

      INSERT INTO t_clean_stores(name,reference,address,zip_code,location,district,telephones,fax,status,manager_name,manager_since)
      SELECT name,s.reference,CASE building WHEN '-' THEN NULL ELSE building||' - ' END || address||' / '||zip_code||', '||location,zip_code,location,district,SUBSTR(REPLACE(REPLACE(telephones,'.',''),' ',''),1,9),fax,CASE WHEN closure_date IS NULL THEN 'ACTIVE' ELSE 'INACTIVE' END, manager_name,manager_since
      FROM (SELECT name,reference,building,address,zip_code,location,district,telephones,fax,closure_date
            FROM t_data_stores_new
            WHERE rejected_by_screen='0'
            MINUS
            SELECT name,reference,building,address,zip_code,location,district,telephones,fax,closure_date
            FROM t_data_stores_old) s, t_data_managers_new d
      WHERE s.reference=d.reference AND
            d.rejected_by_screen='0';

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;


   -- *********************************************************
   -- * TRANSFORMATION OF SALES ACCORDING TO LOGICAL DATA MAP *
   -- *********************************************************
   PROCEDURE transform_sales IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_SALES"]');

      INSERT INTO t_clean_sales(id,sale_date,store_id)
      SELECT id,sale_date,store_id
      FROM t_data_sales
      WHERE rejected_by_screen='0';

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;




   -- *****************************************************************
   -- * TRANSFORMATION OF LINES OF SALE ACCORDING TO LOGICAL DATA MAP *
   -- *****************************************************************
   PROCEDURE transform_linesofsale IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_LINESOFSALE"]');

      INSERT INTO t_clean_linesofsale(id,sale_id,product_id,promo_id,quantity,ammount_paid,line_date)
      SELECT los.id,los.sale_id,los.product_id,losp.promo_id,quantity,ammount_paid, los.line_date
      FROM t_data_linesofsale los LEFT JOIN (SELECT line_id,promo_id
                                            FROM t_data_linesofsalepromotions
                                            WHERE rejected_by_screen='0') losp ON los.id=losp.line_id, t_data_sales
      WHERE los.rejected_by_screen='0' AND
            t_data_sales.id=los.sale_id;

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;


   -- *****************************************************************************************************
   -- *                                             MAIN                                                  *
   -- *                                                                                                   *
   -- * EXECUTE THE TRANSFORMATION PROCESS                                                               *
   -- * IN                                                                                                *
   -- *     p_duplicate_last_iteration: TRUE=duplicate last iteration and its schedule (FOR TESTS ONLY!) *
   -- *****************************************************************************************************
   PROCEDURE main (p_duplicate_last_iteration BOOLEAN) IS

      -- GET ALL SCHEDULED SCREENS
      cursor scheduled_screens_cursor(p_iteration_key t_tel_iteration.iteration_key%TYPE) IS
         SELECT UPPER(screen_name) screen_name,source_key,screen_order
         FROM t_tel_schedule, t_tel_screen
         WHERE iteration_key=p_iteration_key AND
              t_tel_schedule.screen_key=t_tel_screen.screen_key;

      v_iteration_key t_tel_iteration.iteration_key%TYPE;
   BEGIN
      pck_log.write_log(' ','*****  TRANSFORM  TRANSFORM  TRANSFORM  TRANSFORM  TRANSFORM  TRANSFORM  *****');      -- DUPLICATES THE LAST ITERATION AND THE CORRESPONDING SCREEN SCHEDULE
      -- DUPLICATES THE LAST ITERATION WITH THEN CORRESPONDING SCHEDULE
      IF p_duplicate_last_iteration THEN
         duplicate_last_iteration(SYSDATE);
      END IF;

      -- CLEAN ALL _clean TABLES
      pck_log.write_log('  Deleting old _clean tables');
      DELETE FROM t_clean_products;
      DELETE FROM t_clean_linesofsale;
      DELETE FROM t_clean_stores;
      DELETE FROM t_clean_promotions;
      DELETE FROM t_clean_sales;
      pck_log.write_log('    Done!');

      -- FIND THE MOST RECENTLY SCHEDULED ITERATION
      BEGIN
         -- SOMETHING IS MISSING
         null;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_transformation;
      END;
	  
      -- RUN ALL SCHEDULED SCREENS
      FOR rec IN scheduled_screens_cursor(v_iteration_key) LOOP
         -- SOMETHING IS MISSING
         null;
      END LOOP;

      pck_log.write_log('  All screens have been run.');
      -- EXECUTE THE TRANSFORMATION ROUTINES
      transform_products;
      transform_stores;
      transform_sales;
      transform_linesofsale;
      
		COMMIT;
		pck_log.write_log('  All transformed data commited to database.');
	EXCEPTION
		WHEN e_transformation THEN
			pck_log.write_halt_msg;
			ROLLBACK;
		WHEN OTHERS THEN
			ROLLBACK;
			pck_log.write_uncomplete_task_msg;
			pck_log.write_halt_msg;
	END;

end pck_transform;
/