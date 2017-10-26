CREATE TABLE t_lookup_calories(
	min_calories_100g	NUMBER(4),
	max_calories_100g	NUMBER(4),
	type			VARCHAR2(100),
	description		VARCHAR2(100)
);


CREATE TABLE t_lookup_pack_dimensions(
	pack_type	VARCHAR2(20),
	has_dimensions	CHAR
);


CREATE TABLE t_lookup_brands(
  brand_wrong VARCHAR2(30),
  brand_transformed VARCHAR2(30),
  CONSTRAINT pk_lookupBrands PRIMARY KEY (brand_wrong, brand_transformed)
);




