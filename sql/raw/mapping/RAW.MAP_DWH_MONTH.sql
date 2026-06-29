/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.RAW.RUN_MAP_DWH_MONTH
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	24.06.2026
Topic:			Standardized mapping of DESTATIS month attributes to numeric month values
Sources:		Static mapping definition

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides a standardized reference mapping between DESTATIS month codes
(e.g. MONAT01–MONAT12) and their corresponding integer representations (1–12).
This mapping ensures consistent month handling across all STG and CORE layers.

Logic
--------------------------------------------------------------------------------------------------------------
1. Drop and recreate the mapping table DB_DWH.RAW.MAP_DWH_MONTH.
2. Populate the table with a fixed, static month mapping definition.
3. Ensure deterministic month conversion logic for downstream ETL processes.

Result
--------------------------------------------------------------------------------------------------------------
A static reference mapping table used across all DWH layers for month standardization.
- [MONTH_NAME]       DESTATIS month attribute code (e.g. MONAT01)
- [MONTH]            Numeric month representation (1–12)

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_INTERNAL_MAPPING

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- No source objects assigned (static mapping definition).

Target Objects:
- DB_DWH.RAW.MAP_DWH_MONTH

Versioning
--------------------------------------------------------------------------------------------------------------
- 24.06.2026 | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS RAW.RUN_MAP_DWH_MONTH;
GO

CREATE PROCEDURE RAW.RUN_MAP_DWH_MONTH (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.RAW.MAP_DWH_MONTH') IS NULL
BEGIN
CREATE TABLE DB_DWH.RAW.MAP_DWH_MONTH (
	 [MONTH] 		INT				-- Numeric month representation (1–12)
	,[MONTH_NAME] 	NVARCHAR(100) 	-- DESTATIS month attribute code (e.g. MONAT01)
	,[STAMP_TIME]	DATETIME		-- Loading time
	,[STAMP_SOURCE] NVARCHAR(100)	-- Source definition, here: INTERNAL_MAPPING
)
END;

--Parameter definition
--------------------------------------------------------------------------------------------------------------
-- @DEFAULT
-- Technical placeholder parameter according to DWH framework standard.
-- Currently not used.

/*===========================================================================================================
			SOURCES
=============================================================================================================*/
--Mapping sources
--------------------------------------------------------------------------------------------------------------
-- Static mapping table. No external data sources required.

--Data sources
--------------------------------------------------------------------------------------------------------------
-- Static mapping table. No external data sources required.

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	Result
--Purpose:	Load static month mapping reference table for DWH standardization.
--Logic:   	- Provide deterministic mapping between DESTATIS month codes and numeric month values.
--			- Ensure consistency across STG and CORE transformations.
INSERT INTO DB_DWH.RAW.MAP_DWH_MONTH (
	 [MONTH]
	,[MONTH_NAME]
	,[STAMP_TIME]
	,[STAMP_SOURCE]
)


SELECT
	 TEMP.[MONTH]
	,TEMP.[MONTH_NAME]
	,GETDATE()			AS [STAMP_TIME]
	,'INTERNAL_MAPPING'	AS [STAMP_SOURCE]
FROM (
VALUES 
	 ('MONAT01',1)
	,('MONAT02',2)
	,('MONAT03',3)
	,('MONAT04',4)
	,('MONAT05',5)
	,('MONAT06',6)
	,('MONAT07',7)
	,('MONAT08',8)
	,('MONAT09',9)
	,('MONAT10',10)
	,('MONAT11',11)
	,('MONAT12',12)
) TEMP([MONTH_NAME],[MONTH])

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.RAW.MAP_DWH_MONTH AS SRC
	WHERE SRC.[MONTH] = TEMP.[MONTH]
)

END;




