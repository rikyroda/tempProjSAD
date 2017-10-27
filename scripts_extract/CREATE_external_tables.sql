CREATE TABLE t_ext_area_cientifica(
    name        VARCHAR2(50),
    sigla       VARCHAR2(10)
)
ORGANIZATION EXTERNAL
(
    TYPE oracle_loader
    DEFAULT DIRECTORY EI_SAD_PROJ63
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY newline
        BADFILE 'area_cientifica_proj63.bad'
        DISCARDFILE 'area_cientifica_proj63.dis'
        LOGFILE 'area_cientifica_proj63.log'
        SKIP 1
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        (
            name        CHAR(50),
            sigla       CHAR(10)
        )
    )
    LOCATION ('Areas_Cientificas.csv')
)
REJECT LIMIT UNLIMITED;
 
 
CREATE TABLE t_ext_departamentos(
    name        VARCHAR2(50),
    sigla       VARCHAR2(10)
)
ORGANIZATION EXTERNAL
(
    TYPE oracle_loader
    DEFAULT DIRECTORY EI_SAD_PROJ63
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY newline
        BADFILE 'departamentos_proj63.bad'
        DISCARDFILE 'departamentos_proj63.dis'
        LOGFILE 'departamentos_proj63.log'
        SKIP 1
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' MISSING FIELD VALUES ARE NULL
        (
            name        CHAR(50),
            sigla       CHAR(10)
        )
    )
    LOCATION ('Departamentos.csv')
)
REJECT LIMIT UNLIMITED;
 
CREATE TABLE t_ext_curso_ei(
    uc          VARCHAR2(100),
    area_cientifica     VARCHAR2(10),
    departamento        VARCHAR2(10)
)
ORGANIZATION EXTERNAL
(
    TYPE oracle_loader
    DEFAULT DIRECTORY EI_SAD_PROJ63
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY newline
        BADFILE 'curso_ei_proj63.bad'
        DISCARDFILE 'curso_ei_proj63.dis'
        LOGFILE 'curso_ei_proj63.log'
        SKIP 3
        FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"'
        REJECT ROWS WITH ALL NULL FIELDS
        (
            uc          CHAR(100),
            area_cientifica     CHAR(10),
            departamento        CHAR(10)
        )
    )
    LOCATION ('Curso_EI.csv')
)
REJECT LIMIT UNLIMITED;