SELECT * FROM t_ext_curso_ei;
SELECT * FROM t_ext_area_cientifica;
SELECT * FROM t_ext_departamentos;

SELECT * FROM ei_sad_proj_gisem.v_turnos;

SELECT *
FROM t_ext_curso_ei ce JOIN t_ext_area_cientifica ac ON (ce.area_cientifica LIKE '%' || ac.sigla || '%');

SELECT *
FROM t_ext_curso_ei ce, t_ext_area_cientifica ac
WHERE ce.area_cientifica LIKE ac.sigla||'%';

SELECT *
FROM t_ext_area_cientifica
WHERE sigla LIKE 'CE%';

SELECT *
FROM t_ext_curso_ei
WHERE area_cientifica LIKE 'CE';

SELECT *
FROM t_ext_curso_ei ce JOIN t_ext_area_cientifica ac ON (ce.uc LIKE t.nomeuc || '%');

SELECT ce.uc, ce.area_cientifica, t.tipoturno, count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN t_ext_curso_ei ce ON (ce.uc LIKE t.nomeuc || '%')
GROUP BY ce.uc, t.tipoturno,ce.area_cientifica;


---------------------------------------

--  1.1
SELECT u.nomeuc, t.tipoturno, count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_ucs u ON (t.uc_id = u.id)
WHERE u.id = 229
GROUP BY u.nomeuc, t.tipoturno;

--  1.2
SELECT t.id, t.turnouc ,count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
WHERE t.uc_id = 229
GROUP BY t.id, t.turnouc;

--  1.3
SELECT t.anouc, t.tipoturno, count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
GROUP BY t.anouc, t.tipoturno;

SELECT t.anouc AS anoUc, t.tipoturno AS tipoTurno , t.turnouc AS turnoUc, count(*) AS numEstudantes
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
GROUP BY t.anouc, t.turnouc, t.tipoturno;   

SELECT anoUc, tipoTurno, MIN(numEstudantes), MAX(numEstudantes)
FROM (SELECT t.anouc AS anoUc, t.tipoturno AS tipoTurno , t.turnouc AS turnoUc, count(*) AS numEstudantes
        FROM ei_sad_proj_gisem.v_turnos t
            JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
        GROUP BY t.anouc, t.turnouc, t.tipoturno)
GROUP BY anoUc, tipoTurno
ORDER BY 1;

--  1.4
SELECT ce.uc, ce.area_cientifica, t.tipoturno, count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN t_ext_curso_ei ce ON (ce.uc LIKE t.nomeuc || '%')
GROUP BY ce.uc, t.tipoturno,ce.area_cientifica;

--  2.1
SELECT t.turnouc, aulas.num_presencas, aulas.semana, aulas.diasemana
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE t.uc_id = 229
ORDER BY 3;

--  2.1
SELECT t.turnouc, aulas.num_presencas, aulas.semana
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE t.uc_id = 229
ORDER BY 3
;

--  2.2
SELECT turnoUc, MIN(numPresencas), MAX(numPresencas)
FROM (SELECT t.turnouc AS turnoUc, aulas.num_presencas AS numPresencas
        FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
        WHERE t.uc_id = 229)
GROUP BY turnoUc
ORDER BY 1
;

--  2.3
SELECT t.turnouc, aulas.num_presencas, aulas.semana
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE t.uc_id = 229
ORDER BY 3
;

SELECT t.id, t.turnouc , count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
WHERE t.uc_id = 229
GROUP BY t.id, t.turnouc;

--  RESOLU��O
SELECT t.id, aulas.semana, aulas.diasemana , t.turnouc AS turnoUc, ROUND((aulas.num_presencas/tuc.cont)*100, 2)
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
    JOIN (SELECT t.id AS turnoId, t.turnouc , count(*) AS cont
        FROM ei_sad_proj_gisem.v_turnos t
            JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
        WHERE t.uc_id = 229
        GROUP BY t.id, t.turnouc) tuc ON (t.id = tuc.turnoId)
WHERE t.uc_id = 229;

SELECT t.id, t.turnouc , count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
WHERE t.uc_id = 229
GROUP BY t.id, t.turnouc;

--  2.4
SELECT t.id, t.turnouc , count(*)
FROM ei_sad_proj_gisem.v_turnos t
	JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
WHERE t.uc_id = 229
GROUP BY t.id, t.turnouc;

SELECT t.turnouc, ROUND(AVG(aulas.num_presencas), 0) AS "Media de Presencas"
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE t.uc_id = 229
GROUP BY t.turnouc
;

--  2.5
SELECT departamento AS "Departamento", nomeuc AS "Nome Uc", ROUND(AVG(percentagens),2) AS "Percentagem de Presencas"
FROM (SELECT dep.NAME AS departamento, curso.uc AS nomeuc, ROUND((aulas.num_presencas/tuc.cont)*100, 2) AS percentagens
FROM t_ext_departamentos dep 
    JOIN t_ext_curso_ei curso 
        ON (dep.sigla = curso.departamento)
    JOIN ei_sad_proj_gisem.v_turnos t
        ON (t.nomeuc = curso.uc)
    JOIN ei_sad_proj_gisem.v_aulas_semana aulas 
        ON (t.id = aulas.turno_id)
    JOIN (SELECT t.id AS turnoId, t.turnouc , count(*) AS cont
        FROM ei_sad_proj_gisem.v_turnos t
            JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
        GROUP BY t.id, t.turnouc) tuc ON (t.id = tuc.turnoId))
GROUP BY departamento, nomeuc
ORDER BY 1;

--  2.6
SELECT dia || '/' || mes || '/' || ano AS "DATA"
FROM (SELECT aulas.dia AS dia, aulas.mes AS mes,
                        aulas.ano_civil AS ano,
                        sum(num_presencas) AS presencas
            FROM ei_sad_proj_gisem.v_aulas_semana aulas
            GROUP BY aulas.dia, aulas.mes, aulas.ano_civil)
WHERE 
                    (presencas / (SELECT ROUND(AVG(sum(num_presencas)),2)
                    FROM ei_sad_proj_gisem.v_aulas_semana
                    GROUP BY dia, mes, ano_civil) )> 1.35
                    OR
                    (presencas / (SELECT ROUND(AVG(sum(num_presencas)),2)
                    FROM ei_sad_proj_gisem.v_aulas_semana
                    GROUP BY dia, mes, ano_civil) )<0.65
ORDER BY mes, dia;

WITH mediaPresencasTotal (media) AS
     (SELECT ROUND(AVG(sum(num_presencas)),2)
                    FROM ei_sad_proj_gisem.v_aulas_semana
                    GROUP BY dia, mes, ano_civil)
SELECT dia || '/' || mes || '/' || ano AS "DATA"
FROM (SELECT aulas.dia AS dia, aulas.mes AS mes,
                        aulas.ano_civil AS ano,
                        sum(num_presencas) AS presencas
            FROM ei_sad_proj_gisem.v_aulas_semana aulas
            GROUP BY aulas.dia, aulas.mes, aulas.ano_civil)
WHERE 
                    (presencas / (SELECT media FROM mediaPresencasTotal) )> 1.35
                    OR
                    (presencas / (SELECT media FROM mediaPresencasTotal) )<0.65
ORDER BY mes, dia;