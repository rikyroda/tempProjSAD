CREATE OR REPLACE PACKAGE PCK_TRANSFORM AS

   PROCEDURE main (p_duplicate_last_iteration BOOLEAN);

   PROCEDURE screen_regime_wrong (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                  p_source_key t_tel_source.source_key%TYPE,
                                  p_screen_order t_tel_schedule.screen_order%TYPE);

   PROCEDURE screen_ucs (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                  p_source_key t_tel_source.source_key%TYPE,
                                  p_screen_order t_tel_schedule.screen_order%TYPE);

   PROCEDURE screen_nome_ucs (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                  p_source_key t_tel_source.source_key%TYPE,
                                  p_screen_order t_tel_schedule.screen_order%TYPE);

    PROCEDURE screen_aulas_canceladas (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                  p_source_key t_tel_source.source_key%TYPE,
                                  p_screen_order t_tel_schedule.screen_order%TYPE);

    PROCEDURE screen_user_notenrolled (p_iteration_key t_tel_iteration.iteration_key%TYPE,
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
      -- obtÃ©m o id da dimensÃ£o Â«dateÂ» referente ao dia em que o erro foi detectado
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


   -- *************************************************************************************
   -- * GOAL: detect and reject users with no "regimes"                                   *
   -- *                           SCREEN_REGIME_WRONG                                     *
   -- * PARAMETERS:                                                                       *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************

   PROCEDURE screen_regime_wrong (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                     p_source_key t_tel_source.source_key%TYPE,
                                     p_screen_order t_tel_schedule.screen_order%TYPE) IS

      CURSOR users_with_problems IS
         SELECT rowid
         FROM t_data_users
         WHERE rejected_by_screen='0'
               AND (TRIM(regime) IS NULL OR TRIM(regime) = '0');

      i PLS_INTEGER:=0;
      v_screen_name VARCHAR2(30):='screen_regime_wrong';
   BEGIN
      pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

      FOR linha IN users_with_problems LOOP
         error_log(v_screen_name,SYSDATE,p_source_key,p_iteration_key,linha.rowid);
         UPDATE t_data_users
         SET regime = 'undefined'
         WHERE rowid = linha.rowid;
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
   -- * GOAL  : detect ucs with the same name                                               *
   -- *                           SCREEN_NOME_UCS                                         *
   -- * PARAMETERS:                                                                       *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************
   PROCEDURE screen_nome_ucs (  p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                            p_source_key t_tel_source.source_key%TYPE,
                                            p_screen_order t_tel_schedule.screen_order%TYPE) IS
    CURSOR ucs_repeated IS
      SELECT curso.rowid
      FROM t_data_curso_ei_new curso
      WHERE curso.rowid IN (
          SELECT MAX(rowid)
          FROM t_data_curso_ei_new
          WHERE uc = curso.uc
          GROUP BY uc
          HAVING COUNT(*)>1);

    i PLS_INTEGER:=0;
    v_screen_name VARCHAR2(30):='screen_nome_ucs';
  BEGIN
    pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

      FOR linha IN ucs_repeated LOOP
         UPDATE t_data_curso_ei_new
         SET rejected_by_screen = 1
         WHERE rowid = linha.rowid;
         error_log(v_screen_name,SYSDATE,p_source_key,p_iteration_key,linha.rowid);
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
   -- * GOAL: detect "ucs" wrongly written after                                          *
   -- *                         SCREEN_UCS                                                *
   -- * PARAMETERS:                                                                       *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************

PROCEDURE screen_ucs (  p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                            p_source_key t_tel_source.source_key%TYPE,
                                            p_screen_order t_tel_schedule.screen_order%TYPE) IS
      CURSOR ucs_with_problems IS
         SELECT u.rowid
         FROM t_data_curso_ei_new u
         JOIN t_lookup_nomeucs n ON (u.uc = n.nomeuc_incorreto)
         WHERE rejected_by_screen='0';

      i PLS_INTEGER:=0;
      v_screen_name VARCHAR2(30):='screen_ucs';
   BEGIN
      pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

      FOR linha IN ucs_with_problems LOOP
         -- UPDATE t_data_curso_ei_new
         -- SET rejected_by_screen = 1
         -- WHERE rowid = linha.rowid;
         error_log(v_screen_name,SYSDATE,p_source_key,p_iteration_key,linha.rowid);
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
   -- * GOAL: reject "aulas" that were canceled                                           *
   -- *                         SCREEN_AULAS_CANCELADAS                                   *
   -- * PARAMETERS:                                                                       *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************

PROCEDURE screen_aulas_canceladas (  p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                            p_source_key t_tel_source.source_key%TYPE,
                                            p_screen_order t_tel_schedule.screen_order%TYPE) IS
    CURSOR aulas_canceladas IS
         SELECT u.rowid
         FROM t_data_aulas_semana u
         WHERE rejected_by_screen='0' AND aula_cancelada=1;

    i PLS_INTEGER:=0;
    v_screen_name VARCHAR2(30):='screen_aulas_canceladas';
  BEGIN
    pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

    FOR linha IN aulas_canceladas LOOP
          UPDATE t_data_aulas_semana
          SET rejected_by_screen = 1
          WHERE rowid=linha.rowid;
         error_log(v_screen_name,SYSDATE,p_source_key,p_iteration_key,linha.rowid);
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
-- * GOAL: reject users that are not enrolled in the UC but goes to class              *
-- *                         SCREEN_USER_NOTENROLLED                                   *
-- * PARAMETERS:                                                                       *
-- *     p_iteration_key: key of the iteration in which the screen will be run         *
-- *     p_source_key: key of the source system related to the screen's execution      *
-- *     p_screen_order: order number in which the screen is to be executed            *
-- *************************************************************************************

PROCEDURE screen_user_notenrolled (  p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                         p_source_key t_tel_source.source_key%TYPE,
                                         p_screen_order t_tel_schedule.screen_order%TYPE) IS
 CURSOR presencas_invalidas IS
   SELECT p.rowid
    FROM t_data_presencas p
    WHERE p.user_id NOT IN (SELECT DISTINCT u.user_id FROM t_data_uc_users u) AND p.rejected_by_screen = 0 AND p.presente=1;

 i PLS_INTEGER:=0;
 v_screen_name VARCHAR2(30):='screen_user_notenrolled';
BEGIN
 pck_log.write_log('  Starting SCREEN ["'||UPPER(v_screen_name)||'"] with order #'||p_screen_order||'');

 FOR linha IN presencas_invalidas LOOP
       UPDATE t_data_presencas
       SET rejected_by_screen = 1
       WHERE rowid=linha.rowid;
      error_log(v_screen_name,SYSDATE,p_source_key,p_iteration_key,linha.rowid);
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


   -- ####################### TRANSFORMATION ROUTINES #######################

  -- **********************************************************
  -- * TRANSFORMATION OF USERS ACCORDING TO LOGICAL DATA MAP  *
  -- **********************************************************
   PROCEDURE transform_users IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_USERS"]');

      INSERT INTO t_clean_users(id,turma_id,temporario,hashorariocompleto,ramo,regime)
      SELECT u.id,u.turma_id,
            CASE WHEN
                u.temporario = '0'
            THEN
                'Nao'
            ELSE
                'Sim'
            END,
            CASE WHEN
                u.hashorariocompleto = '0'
            THEN
                'Nao'
            ELSE
                'Sim'
            END,
            CASE WHEN
                u.ramo = '0' OR TRIM(u.ramo) IS NULL
            THEN
                'undefined'
            ELSE
                u.ramo
            END,
            u.regime
    FROM t_data_users u
    WHERE u.rejected_by_screen='0'
      AND u.role=1;

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
           pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;

      -- **********************************************************
   -- * TRANSFORMATION OF FALTAS ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_faltas IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_FALTAS"]');

      INSERT INTO t_clean_faltas(id,aula_semana_id,user_id,turno_id,faltou,aula_date)
      SELECT p.id, p.aula_semana_id,p.user_id,turno.id,p.presente,
        TO_DATE(au.dia || '-' ||au.mes ||'-'||au.ano_civil, 'dd-mm-yyyy')
      FROM t_data_presencas p
      JOIN t_data_aulas_semana au ON (p.AULA_SEMANA_ID = au.id)
      JOIN t_data_turnos turno ON ( au.turno_id = turno.id)
      WHERE p.rejected_by_screen='0'
        AND p.presente=0;

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;

   -- **********************************************************
   -- * TRANSFORMATION OF PRESENCAS ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_presencas IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_PRESENCAS"]');

      INSERT INTO t_clean_presencas(id,aula_semana_id,user_id,turno_id,presente,aula_date)
      SELECT p.id, p.aula_semana_id,p.user_id,turno.id,p.presente,
            TO_DATE(au.dia || '-' ||au.mes ||'-'||au.ano_civil, 'dd-mm-yyyy')
      FROM t_data_presencas p
      JOIN t_data_aulas_semana au ON (p.AULA_SEMANA_ID = au.id)
      JOIN t_data_turnos turno ON ( au.turno_id = turno.id)
      WHERE p.rejected_by_screen='0'
        AND p.presente=1;

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;


   -- *********************************************************
   -- * TRANSFORMATION OF AULAS ACCORDING TO LOGICAL DATA MAP *
   -- *********************************************************
   PROCEDURE transform_aulas IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_AULAS"]');

      INSERT INTO t_clean_aulas(aula_id,semana,diasemana,horainicio,horafim,sala,dia,mes,ano_civil,turno_id,num_presencas)
      SELECT a.id,a.semana,a.diasemana,a.horainicio,a.horafim,a.sala,a.dia,a.mes,a.ano_civil,a.turno_id,
        a.num_presencas
      FROM t_data_aulas_semana a
      WHERE rejected_by_screen='0';
      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;


   -- **********************************************************
   -- * TRANSFORMATION OF TURNOS ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_turnos IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_TURNOS"]');

      INSERT INTO t_clean_turnos(turno_id,anolectivo,regimeuc,turnouc,max_alunos,tipoturno,uc_id)
      SELECT t.id,t.anolectivo,t.regimeuc,t.turnouc,t.max_alunos,t.tipoturno,t.uc_id
      FROM t_data_turnos t LEFT JOIN t_lookup_nomeucs ln ON (t.nomeuc LIKE ln.nomeuc_incorreto)
      WHERE t.rejected_by_screen='0';

      pck_log.write_log('    Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('    Found no lines to transform','    Done!');
      WHEN OTHERS THEN
         pck_log.write_uncomplete_task_msg;
         RAISE e_transformation;
   END;

   -- **********************************************************
   -- * TRANSFORMATION OF UCS ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_ucs IS
   BEGIN
      pck_log.write_log('  Transforming data ["TRANSFORM_UCS"]');
      --TODO
      --UPDATE T_DATA_CURSO_EI_NEW
      --SET

      INSERT INTO t_clean_ucs(UC_ID,
                              NOMEUC,
                              ABREVUC,
                              area_cientifica,
                              area_cientifica_sigla,
                              departamento,
                              departamento_sigla,
                              ANOUC,
                              SEMESTREUC,
                              RAMOUC)
      SELECT ucs.ID, ucs.nomeuc,
          ucs.ABREVUC,
          ac.name,
          substr(ac.sigla, 0, length(ac.sigla)-1),
          dp.NAME,
          ce.DEPARTAMENTO,
          ucs.ANOUC,
          ucs.SEMESTREUC,
          ucs.RAMOUC
      FROM T_DATA_UCS ucs
         LEFT JOIN T_DATA_CURSO_EI_NEW ce ON (ce.uc LIKE ucs.nomeuc OR ce.uc LIKE ucs.nomeuc||' %' )
         JOIN T_DATA_DEPARTAMENTOS_NEW dp ON ce.DEPARTAMENTO LIKE dp.SIGLA
         LEFT JOIN T_DATA_AREA_CIENTIFICA_NEW ac ON ( ce.AREA_CIENTIFICA LIKE substr(ac.sigla, 0, length(ac.sigla)-1))
         LEFT JOIN t_lookup_nomeucs ln ON (ce.uc LIKE ln.nomeuc_incorreto)
      WHERE ce.rejected_by_screen = 0;

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
      v_sql VARCHAR2(500);
   BEGIN
      pck_log.write_log(' ','*****  TRANSFORM  TRANSFORM  TRANSFORM  TRANSFORM  TRANSFORM  TRANSFORM  *****');      -- DUPLICATES THE LAST ITERATION AND THE CORRESPONDING SCREEN SCHEDULE
      -- DUPLICATES THE LAST ITERATION WITH THEN CORRESPONDING SCHEDULE
      IF p_duplicate_last_iteration THEN
         duplicate_last_iteration(SYSDATE);
      END IF;

      -- CLEAN ALL _clean TABLES
      pck_log.write_log('  Deleting old _clean tables');
      DELETE FROM t_clean_users;
      DELETE FROM t_clean_faltas;
      DELETE FROM t_clean_presencas;
      DELETE FROM t_clean_aulas;
      DELETE FROM t_clean_turnos;
      DELETE FROM t_clean_ucs;

      pck_log.write_log('    Done!');

      -- FIND THE MOST RECENTLY SCHEDULED ITERATION
      BEGIN
         SELECT MAX(i.iteration_key)
         INTO v_iteration_key
         FROM t_tel_iteration i
         WHERE TO_CHAR(SYSDATE, 'yyyy-mm-dd') = TO_CHAR (i.iteration_start_date, 'yyyy-mm-dd');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_transformation;
      END;

      -- RUN ALL SCHEDULED SCREENS
      FOR rec IN scheduled_screens_cursor(v_iteration_key) LOOP
        v_sql:= 'BEGIN pck_transform.' || rec.screen_name || '(' || v_iteration_key || ',' ||
            rec.source_key || ',' || rec.screen_order || '); END;';
        pck_log.write_log(v_sql);
        EXECUTE IMMEDIATE v_sql;
      END LOOP;

      pck_log.write_log('  All screens have been run.');
      -- EXECUTE THE TRANSFORMATION ROUTINES

      transform_users;
      transform_faltas;
      transform_presencas;
      transform_aulas;
      transform_turnos;
      transform_ucs;

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
