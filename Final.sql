
--Q1.1 : Nº Turnos por Tipo na UC SAD 
SELECT u.nomeuc AS UC, t.tipoturno AS "Tipo de Turno", count(*) AS "Numero de Turnos"
FROM ei_sad_proj_gisem.v_turnos t
    JOIN ei_sad_proj_gisem.v_ucs u ON (t.uc_id = u.id)
WHERE UPPER(u.nomeuc) like 'SISTEMAS DE % DECIS%O'
GROUP BY u.nomeuc, t.tipoturno;

    OU
    
SELECT nomeuc, tipoturno, count(*)
FROM ei_sad_proj_gisem.v_turnos 
WHERE UPPER(nomeuc) like 'SISTEMAS DE % DECIS%O'
GROUP BY nomeuc, tipoturno;

*Output*
UC                                                 Tipo  Numero de Turnos
-------------------------------------------------- ----- ----------------
Sistemas de Apoio à Decisão                        PL                   4
Sistemas de Apoio à Decisão                        T                    1


-- Q1.2: Nº Estudantes em cada Turno
SELECT t.nomeuc AS UC, t.turnouc AS Turno ,count(*) AS "Numero de Estudantes"
FROM ei_sad_proj_gisem.v_turnos t
    JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
WHERE UPPER(t.nomeuc) like 'SISTEMAS DE % DECIS%O'
GROUP BY t.nomeuc, t.turnouc;

*Output*
UC                                                 TURNO Numero de Estudantes
-------------------------------------------------- ----- --------------------
Sistemas de Apoio à Decisão                        PL                      18
Sistemas de Apoio à Decisão                        PL3                     17
Sistemas de Apoio à Decisão                        PL2                     17
Sistemas de Apoio à Decisão                        T                       71
Sistemas de Apoio à Decisão                        PL1                     19

--Q1.3: Nº Minimo e Máximo de Estudantes Inscritos nos Turnos por TipoTurno , Ano e Curso

SELECT anoUc AS "Ano da UC", tipoTurno AS "Tipo de Turno", MIN(numEstudantes) AS "Minimo de Estudantes", MAX(numEstudantes) AS "Maximo de Estudantes"
FROM (SELECT t.anouc AS anoUc, t.tipoturno AS tipoTurno , t.turnouc AS turnoUc, count(*) AS numEstudantes
        FROM ei_sad_proj_gisem.v_turnos t
            JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
        GROUP BY t.anouc, t.turnouc, t.tipoturno)
GROUP BY anoUc, tipoTurno
ORDER BY 1;

*Output*
 Ano da UC Tipo  Minimo de Estudantes Maximo de Estudantes
---------- ----- -------------------- --------------------
         1 PL                      19                  158
         1 TP                      48                  494
         2 PL                      29                  242
         2 TP                     335                  434
         3 PL                      32                  180
         3 T                      619                  619
         
         
         OU
         
SELECT anoUc AS "Ano da UC", tipoTurno AS "Tipo de Turno", MIN(numEstudantes) AS "Minimo de Estudantes", MAX(numEstudantes) AS "Maximo de Estudantes"
FROM (SELECT t.anouc as anoUc, t.turnouc as turnouc, t.tipoturno as tipoturno, t.nomeuc ,count(*) AS numEstudantes
        FROM ei_sad_proj_gisem.v_turnos t
            JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
        GROUP BY t.anouc, t.turnouc, t.nomeuc, t.tipoturno)
GROUP BY anoUc, tipoTurno
ORDER BY 1;

 Ano da UC Tipo  Minimo de Estudantes Maximo de Estudantes
---------- ----- -------------------- --------------------
         1 PL                      16                   57
         1 TP                      33                  148
         2 PL                      20                   55
         2 TP                      46                  121
         3 PL                      11                   49
         3 T                       39                  148


--Q1.4: Total de turnos, por tipo, nas unidades curriculares de cada área científica
SELECT ce.uc AS UC, ce.area_cientifica AS "Area Cientifica", t.tipoturno AS "Tipo de Turno", count(*) AS "Total de Turnos"
FROM ei_sad_proj_gisem.v_turnos t
    JOIN t_ext_curso_ei ce ON (ce.uc LIKE t.nomeuc || '%')
GROUP BY ce.uc, t.tipoturno,ce.area_cientifica;

*Output*

UC                                                                                                   Area Cient Tipo  Total de Turnos
---------------------------------------------------------------------------------------------------- ---------- ----- ---------------
Bases de Dados                                                                                       CE         TP                  3
Segurança de Sistemas                                                                                EI-TIC     T                   1
Sistemas Computacionais                                                                              CE         TP                  4
Redes de Computadores                                                                                CE         TP                  3
Integração de Sistemas                                                                               EI-SI      PL                 16
Desenvolvimento de Aplicações Empresariais                                                           EI-SI      T                   1
Centros de Processamento de Dados                                                                    EI-TIC     PL                  3
Algoritmos e Estruturas de Dados I                                                                   EI-SI      TP                  3
Programação Avançada                                                                                 EI-SI      TP                  3
Desenvolvimento de Aplicações Empresariais                                                           EI-SI      PL                  4
Centros de Processamento de Dados                                                                    EI-TIC     T                   1

UC                                                                                                   Area Cient Tipo  Total de Turnos
---------------------------------------------------------------------------------------------------- ---------- ----- ---------------
Física Aplicada                                                                                      CB         PL                 15
Algoritmos e Estruturas de Dados I                                                                   EI-SI      PL                 12
Programação Avançada                                                                                 EI-SI      PL                 10
Tópicos Avançados de Engenharia de Software                                                          EI-SI      T                   1
Segurança de Sistemas                                                                                EI-TIC     PL                  3
Álgebra Linear                                                                                       CB         TP                  7
Bases de Dados                                                                                       CE         PL                 10
Tópicos Avançados de Redes                                                                           EI-TIC     T                   1
Programação I                                                                                        CE         TP                  4
Programação II                                                                                       CE         TP                  4
Análise Matemática                                                                                   CB         TP                  5

UC                                                                                                   Area Cient Tipo  Total de Turnos
---------------------------------------------------------------------------------------------------- ---------- ----- ---------------
Redes de Computadores                                                                                CE         PL                  9
Desenvolvimento de Aplicações Distribuídas                                                           EI-TIC     PL                 16
Tópicos Avançados de Engenharia de Software                                                          EI-SI      PL                  4
Sistemas de Apoio à Decisão                                                                          EI-SI      PL                  4
Sistemas de Apoio à Decisão                                                                          EI-SI      T                   1
Tópicos Avançados de Redes                                                                           EI-TIC     PL                  3
Programação II                                                                                       CE         PL                 13
Sistemas Gráficos e Interação                                                                        EI-TIC     PL                  9
Desenvolvimento de Aplicações Distribuídas                                                           EI-TIC     T                   4
Sistemas Computacionais                                                                              CE         PL                 12
Sistemas Gráficos e Interação                                                                        EI-TIC     TP                  3

UC                                                                                                   Area Cient Tipo  Total de Turnos
---------------------------------------------------------------------------------------------------- ---------- ----- ---------------
Integração de Sistemas                                                                               EI-SI      T                   4
Física Aplicada                                                                                      CB         TP                  6
Programação I                                                                                        CE         PL                 13

--Q.2.1: Nº de Estudantes Inscritos presentes nas Aulas por Turno , em SAD
SELECT t.turnouc AS Turno, aulas.num_presencas AS Presencas, aulas.semana AS Semana,aulas.dia || '/' || aulas.mes || '/' || aulas.ano_civil AS "DATA"
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE t.uc_id = 229
ORDER BY aulas.ano_civil, aulas.mes, aulas.dia
;

OU

SELECT t.turnouc AS Turno, aulas.num_presencas AS Presencas, aulas.semana AS Semana,aulas.dia || '/' || aulas.mes || '/' || aulas.ano_civil AS "DATA"
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE UPPER(nomeuc) like 'SISTEMAS DE % DECIS%O'
ORDER BY aulas.ano_civil, aulas.mes, aulas.dia;

*Output*

TURNO  PRESENCAS SEMANA DATA                                                                                                                      
----- ---------- ---- -----------------
T             59 38   23/9/2016                                                                                                                 
PL3           17 38   21/9/2016                                                                                                                 
PL2           15 38   23/9/2016                                                                                                                 
PL            14 38   23/9/2016                                                                                                                 
PL1           18 38   23/9/2016                                                                                                                 
PL1           17 39   30/9/2016                                                                                                                 
PL3           15 39   28/9/2016                                                                                                                 
PL            14 39   30/9/2016                                                                                                                 
T             55 39   30/9/2016                                                                                                                 
PL2           15 39   30/9/2016                                                                                                                 
PL3            0 40   5/10/2016                                                                                                                 

TURNO  PRESENCAS SEMANA DATA                                                                                                                      
----- ---------- ---- ----------------
PL            15 40   7/10/2016                                                                                                                 
PL1           17 40   7/10/2016                                                                                                                 
T             53 40   7/10/2016                                                                                                                 
PL2           16 40   7/10/2016                                                                                                                 
PL3           17 41   12/10/2016                                                                                                                
PL2           14 41   14/10/2016                                                                                                                
T             48 41   14/10/2016                                                                                                                
PL            15 41   14/10/2016                                                                                                                
PL1           16 41   14/10/2016                                                                                                                
T             48 42   21/10/2016                                                                                                                
PL1           16 42   21/10/2016                                                                                                                

TURNO  PRESENCAS SEMANA DATA                                                                                                                      
----- ---------- ---- ----------------
PL            12 42   21/10/2016                                                                                                                
PL2           15 42   21/10/2016                                                                                                                
PL3           16 42   19/10/2016                                                                                                                
PL2           12 43   28/10/2016                                                                                                                
PL3            0 43   26/10/2016                                                                                                                
PL1           16 43   28/10/2016                                                                                                                
PL            12 43   28/10/2016                                                                                                                
T             39 43   28/10/2016                                                                                                                
PL1           17 44   4/11/2016                                                                                                                 
PL            13 44   4/11/2016                                                                                                                 
T             51 44   4/11/2016                                                                                                                 

TURNO  PRESENCAS SEMANA DATA                                                                                                                      
----- ---------- ---- -----------------
PL2           14 44   4/11/2016                                                                                                                 
PL3           16 44   2/11/2016                                                                                                                 
PL1           17 45   11/11/2016                                                                                                                
T             45 45   11/11/2016                                                                                                                
PL            14 45   11/11/2016                                                                                                                
PL3           16 45   9/11/2016                                                                                                                 
PL2           13 45   11/11/2016                                                                                                                
T             34 46   18/11/2016                                                                                                                
PL            10 46   18/11/2016                                                                                                                
PL2           13 46   18/11/2016                                                                                                                
PL1           14 46   18/11/2016                                                                                                                

TURNO  PRESENCAS SEMANA DATA                                                                                                                      
----- ---------- ---- ----------------
PL3           16 46   16/11/2016                                                                                                                
PL3           16 47   23/11/2016                                                                                                                
PL2           13 47   25/11/2016                                                                                                                
PL1           17 47   25/11/2016                                                                                                                
PL            13 47   25/11/2016                                                                                                                
T             41 47   25/11/2016                                                                                                                
PL3           14 48   30/11/2016                                                                                                                
PL2           12 48   2/12/2016                                                                                                                 
PL1           17 48   2/12/2016                                                                                                                 
PL            13 48   2/12/2016                                                                                                                 
T             46 48   2/12/2016                                                                                                                 

TURNO  PRESENCAS SEMANA DATA                                                                                                                      
----- ---------- ---- ----------------
PL            12 49   9/12/2016                                                                                                                 
T             40 49   9/12/2016                                                                                                                 
PL2           12 49   9/12/2016                                                                                                                 
PL3           15 49   7/12/2016                                                                                                                 
PL1           17 49   9/12/2016                                                                                                                 
PL            12 50   16/12/2016                                                                                                                
PL2           13 50   16/12/2016                                                                                                                
PL3           16 50   14/12/2016                                                                                                                
PL1           17 50   16/12/2016                                                                                                                
T             45 50   16/12/2016 


--Q2.2: Número mínimo/máximo de estudantes presentes, por turno, na unidade curricular de Sistemas de Apoio à Decisão
SELECT turnoUc AS UC, MIN(numPresencas) AS "Minimo de Estudantes Presentes", MAX(numPresencas) AS "Máximo de Estudantes Presentes"
FROM (SELECT t.turnouc AS turnoUc, aulas.num_presencas AS numPresencas
        FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
        WHERE t.uc_id = 229)
GROUP BY turnoUc
ORDER BY 1
;

    OU
    
SELECT turnoUc AS UC, MIN(numPresencas) AS "Minimo de Estudantes Presentes", MAX(numPresencas) AS "Máximo de Estudantes Presentes"
FROM (SELECT t.turnouc AS turnoUc, aulas.num_presencas AS numPresencas
        FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
        WHERE UPPER(nomeuc) like 'SISTEMAS DE % DECIS%O')
GROUP BY turnoUc
ORDER BY 1
;

*Output*

UC    Minimo de Estudantes Presentes Máximo de Estudantes Presentes
----- ------------------------------ ------------------------------
PL                                10                             15
PL1                               14                             18
PL2                               12                             16
PL3                                0                             17
T                                 34                             59

--Q2.3: Percentagem de presenças em cada aula, por turno , em SAD

SELECT aulas.dia || '/' || aulas.mes || '/' || aulas.ano_civil AS "DATA",
            aulas.semana AS Semana, 
            t.turnouc AS Turno,
            ROUND((aulas.num_presencas/tuc.cont)*100, 2) AS Percentagem
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
    JOIN (SELECT t.id AS turnoId, t.turnouc , count(*) AS cont
        FROM ei_sad_proj_gisem.v_turnos t
            JOIN ei_sad_proj_gisem.v_turno_user tu ON (t.id = tu.turno_id)
        WHERE t.uc_id = 229
        GROUP BY t.id, t.turnouc) tuc ON (t.id = tuc.turnoId)
WHERE t.uc_id = 229;

    OU
    
WHERE UPPER(nomeuc) like 'SISTEMAS DE % DECIS%O';

*Output*


DATA          SEMANA TURNO PERCENTAGEM
------------- ---- ----- -----------
14/12/2016    50   PL3   94,12      
25/11/2016    47   PL1   89,47      
28/10/2016    43   PL1   84,21      
7/10/2016     40   PL    83,33      
30/11/2016    48   PL3   82,35      
12/10/2016    41   PL3   100
2/11/2016     44   PL3   94,12      
28/9/2016     39   PL3   88,24      
18/11/2016    46   PL1   73,68      
21/10/2016    42   PL1   84,21      
25/11/2016    47   T     57,75      

DATA           SEMANA TURNO PERCENTAGEM
-------------- ---- ----- -----------
28/10/2016    43   T     54,93      
30/9/2016     39   T     77,46      
7/10/2016     40   T     74,65      
11/11/2016    45   PL2   76,47      
14/10/2016    41   PL    83,33      
30/9/2016     39   PL    77,78      
16/11/2016    46   PL3   94,12      
9/11/2016     45   PL3   94,12      
5/10/2016     40   PL3   0
23/9/2016     38   PL1   94,74      
14/10/2016    41   T     67,61      

DATA           SEMANA TURNO PERCENTAGEM
-------------- ---- ----- -----------
23/9/2016      38   PL2   88,24      
16/12/2016     50   PL    66,67      
18/11/2016     46   PL    55,56      
7/12/2016      49   PL3   88,24      
23/11/2016     47   PL3   94,12      
16/12/2016     50   PL1   89,47      
30/9/2016      39   PL2   88,24      
7/10/2016      40   PL2   94,12      
11/11/2016     45   PL    77,78      
4/11/2016      44   PL1   89,47      
7/10/2016      40   PL1   89,47      

DATA           SEMANA TURNO PERCENTAGEM
-------------- ---- ----- -----------
18/11/2016     46   T     47,89      
9/12/2016      49   T     56,34      
21/10/2016     42   PL2   88,24      
14/10/2016     41   PL2   82,35      
28/10/2016     43   PL    66,67      
21/9/2016      38   PL3    100
9/12/2016      49   PL1   89,47      
2/12/2016      48   PL1   89,47      
11/11/2016     45   PL1   89,47      
16/12/2016     50   T     63,38      
2/12/2016      48   T     64,79      

DATA          SEMANA TURNO PERCENTAGEM
------------  ---- ----- -----------
16/12/2016    50   PL2   76,47      
9/12/2016     49   PL2   70,59      
2/12/2016     48   PL2   70,59      
21/10/2016    42   PL    66,67      
14/10/2016    41   PL1   84,21      
30/9/2016     39   PL1   89,47      
11/11/2016    45   T     63,38      
4/11/2016     44   T     71,83      
21/10/2016    42   T     67,61      
25/11/2016    47   PL    72,22      
2/12/2016     48   PL    72,22      

DATA          SEMANA TURNO PERCENTAGEM
------------  ---- ----- -----------
4/11/2016     44   PL    72,22      
23/9/2016     38   PL    77,78      
19/10/2016    42   PL3   94,12      
26/10/2016    43   PL3   0
23/9/2016     38   T     83,1       
18/11/2016    46   PL2   76,47      
25/11/2016    47   PL2   76,47      
4/11/2016     44   PL2   82,35      
28/10/2016    43   PL2   70,59      
9/12/2016     49   PL    66,67      



--Q2.4: Média de presenças nas aulas de cada turno na unidade curricular de Sistemas de Apoio à Decisão 
SELECT t.turnouc AS Turno, ROUND(AVG(aulas.num_presencas), 0) AS "Media de Presencas"
FROM ei_sad_proj_gisem.v_turnos t JOIN ei_sad_proj_gisem.v_aulas_semana aulas ON (t.id = aulas.turno_id)
WHERE t.uc_id = 229
GROUP BY t.turnouc
;

    OU
    
WHERE UPPER(nomeuc) like 'SISTEMAS DE % DECIS%O';

*Output*

TURNO Media de Presencas
----- ------------------
PL1                   17
PL2                   14
PL3                   13
T                     46
PL                    13

--Q2.5: Percentagem de presenças nas aulas das unidades curriculares afetas a cada departamento
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

*Output*

Departamento                                       Nome Uc                                        Percentagem de Presencas
-------------------------------------------------- ---------------------------------------------- ------------------------
Engenharia Eletrotécnica                           Física Aplicada                                  72,48                   
Engenharia Informática                             Bases de Dados                                   54,5                    
Engenharia Informática                             Centros de Processamento de Dados                62,21                   
Engenharia Informática                             Desenvolvimento de Aplicações Distribuídas       70,91                   
Engenharia Informática                             Desenvolvimento de Aplicações Empresariais       66,07                   
Engenharia Informática                             Integração de Sistemas                           68,48                   
Engenharia Informática                             Programação Avançada                             65,91                   
Engenharia Informática                             Programação I                                    67,88                   
Engenharia Informática                             Redes de Computadores                            63,4                    
Engenharia Informática                             Segurança de Sistemas                            70,56                   
Engenharia Informática                             Sistemas Computacionais                          67,83                   

Departamento                                       Nome Uc                                        Percentagem de Presencas
-------------------------------------------------- ---------------------------------------------- ------------------------
Engenharia Informática                             Sistemas Gráficos e Interação                    72,12                   
Engenharia Informática                             Sistemas de Apoio à Decisão                      76,79                   
Engenharia Informática                             Tópicos Avançados de Engenharia de Software      67,02                   
Engenharia Informática                             Tópicos Avançados de Redes                       63,26                   
Matemática                                         Análise Matemática                               38,05                   
Matemática                                         Álgebra Linear                                   13,77                   


--Q2.6: Momentos do semestre letivo em que existem picos de presenças (máximos/mínimos) nas aulas

WITH mediaPresencasTotal (media) AS -- Media total das presenças
         (SELECT ROUND(AVG(sum(num_presencas)),2)
                        FROM ei_sad_proj_gisem.v_aulas_semana
                        GROUP BY dia, mes, ano_civil),
    somaPresencasDia (dia,mes,ano,presencas) AS --Soma das presenças por dia
        (SELECT aulas.dia AS dia, aulas.mes AS mes,
            aulas.ano_civil AS ano,
            sum(num_presencas) AS presencas
        FROM ei_sad_proj_gisem.v_aulas_semana aulas
        GROUP BY aulas.dia, aulas.mes, aulas.ano_civil)
SELECT dia || '/' || mes || '/' || ano AS "DATA", presencas
FROM somaPresencasDia
WHERE 
    (presencas / (SELECT media FROM mediaPresencasTotal) )> 1.35
    OR
    (presencas / (SELECT media FROM mediaPresencasTotal) )<0.65
    ORDER BY ano,mes,dia;


*Output*

DATA                                                                                                                        PRESENCAS
-------------------------------------------------------------------------------------------------------------------------- ----------
19/9/2016                                                                                                                         111
3/10/2016                                                                                                                        1020
5/10/2016                                                                                                                          32
26/10/2016                                                                                                                         82
1/11/2016                                                                                                                          19
1/12/2016                                                                                                                          86
8/12/2016                                                                                                                          27

