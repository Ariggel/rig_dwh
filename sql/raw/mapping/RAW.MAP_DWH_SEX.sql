/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.RAW.RUN_MAP_SEX
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	03.07.2026
Topic:			Standardized mapping of the sex
Sources:		Static mapping definition

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides a standardized mapping of sex attributes used across the Data Warehouse.

The mapping translates source-specific sex labels published by DESTATIS into
a centralized DWH representation to ensure consistent reporting and simplify
joins across datasets.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Every DESTATIS sex attribute is mapped to exactly one standardized DWH value.
- The mapping is maintained internally and is independent of source systems.
- Existing mapping records are not inserted again.
- Technical metadata is added to every record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Create the mapping table if it does not already exist.
2. Define the static DWH sex mapping.
3. Insert only mappings that do not yet exist.
4. Add technical metadata including source identifier and load timestamp.

Result
--------------------------------------------------------------------------------------------------------------
Static reference table containing standardized sex attributes used throughout
the Data Warehouse.

  [SEX_ID]               INT             -- Numeric sex ID
 ,[SEX_NAME]             NVARCHAR(100)   -- Static DWH sex label (e.g. Unbekannt, Männlich)
 ,[SEX_NAME_DESTATIS]    NVARCHAR(100)   -- DESTATIS sex attribute label (e.g. Ohne Angabe, männlich)
 ,[STAMP_TIME]	         DATETIME		 -- Loading time
 ,[STAMP_SOURCE]         NVARCHAR(100)	 -- Source definition, here: INTERNAL_MAPPING

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_INTERNAL_MAPPING

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- No source objects assigned (static mapping definition).

Target Objects:
- DB_DWH.RAW.MAP_SEX

Versioning
--------------------------------------------------------------------------------------------------------------
- 03.07.2026 | Sascha Klein | v 1.0.0
--- Initial version
*/

/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS RAW.RUN_MAP_DWH_SEX;
GO

CREATE PROCEDURE RAW.RUN_MAP_DWH_SEX (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.RAW.MAP_DWH_SEX') IS NULL
BEGIN
CREATE TABLE DB_DWH.RAW.MAP_DWH_SEX (
	 [SEX_ID]               INT             -- Numeric sex ID
    ,[SEX_NAME]             NVARCHAR(100)   -- Static DWH sex label (e.g. Unbekannt, Männlich)
    ,[SEX_NAME_DESTATIS]    NVARCHAR(100)   -- DESTATIS sex attribute label (e.g. Ohne Angabe, männlich)
	,[STAMP_TIME]	        DATETIME		-- Loading time
	,[STAMP_SOURCE]         NVARCHAR(100)	-- Source definition, here: INTERNAL_MAPPING
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
--Table:    Resultset
--Purpose:  Load static sex mapping reference table for DWH standardization.
--Logic:    - <STEP 1>
--          - <STEP 2>
INSERT INTO DB_DWH.RAW.MAP_DWH_SEX (
	 [SEX_ID]
    ,[SEX_NAME]
    ,[SEX_NAME_DESTATIS]
    ,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 TEMP.[SEX_ID]
	,TEMP.[SEX_NAME]
    ,TEMP.[SEX_NAME_DESTATIS]
	,'INTERNAL_MAPPING'	AS [STAMP_SOURCE]
    ,GETDATE()			AS [STAMP_TIME]
FROM (
VALUES 
	 (1,'Männlich','männlich')
    ,(2,'Weiblich','weiblich')
    ,(3,'Unbekannt','Ohne Angabe')
) TEMP([SEX_ID],[SEX_NAME],[SEX_NAME_DESTATIS])

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.RAW.MAP_DWH_SEX AS SRC
    WHERE SRC.[SEX_ID] = TEMP.[SEX_ID]
)

END;
