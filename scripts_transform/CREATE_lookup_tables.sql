-- CREATE TABLE t_lookup_calories(
-- 	min_calories_100g	NUMBER(4),
-- 	max_calories_100g	NUMBER(4),
-- 	type			VARCHAR2(100),
-- 	description		VARCHAR2(100)
-- );


-- CREATE TABLE t_lookup_pack_dimensions(
-- 	pack_type	VARCHAR2(20),
-- 	has_dimensions	CHAR
-- );


-- CREATE TABLE t_lookup_brands(
--   brand_wrong VARCHAR2(30),
--   brand_transformed VARCHAR2(30),
--   CONSTRAINT pk_lookupBrands PRIMARY KEY (brand_wrong, brand_transformed)
-- );


CREATE TABLE t_lookup_nomeucs(
  nomeuc_incorreto VARCHAR2(50),
  nomeuc_correto VARCHAR2(50),
  CONSTRAINT pk_lookupNomeUcs PRIMARY KEY (nomeuc_incorreto, nomeuc_correto)
);

CREATE TABLE t_lookup_area_cientifica(
	nomeuc_acincorreto VARCHAR2(50),
	nomeuc_accorreto VARCHAR2(50),
	CONSTRAINT pk_lookupAreaCientifica PRIMARY KEY (nomeuc_acincorreto, nomeuc_accorreto)
);




