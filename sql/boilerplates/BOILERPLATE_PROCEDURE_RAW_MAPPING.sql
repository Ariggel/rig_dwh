/*
/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.RAW.RUN_MAP_<TABLE>
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	<DATE>
Topic:			Standardized mapping of <TOPIC>
Sources:		Static mapping definition

Business Definition
--------------------------------------------------------------------------------------------------------------
<DEFINITION>

Business Rules
--------------------------------------------------------------------------------------------------------------
- <RULE 1>

Logic
--------------------------------------------------------------------------------------------------------------
1. <STEP 1>

Result
--------------------------------------------------------------------------------------------------------------
Static reference table containing <CONTENT>

 [COLUMN]      <DATA_TYPE>             -- <DESCRIPTION>

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_INTERNAL_MAPPING

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- No source objects assigned (static mapping definition).

Target Objects:
- DB_DWH.RAW.MAP_<TABLE>

Versioning
--------------------------------------------------------------------------------------------------------------
- <DATE> | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS RAW.RUN_MAP_DWH_<TABLE>;
GO

CREATE PROCEDURE RAW.RUN_MAP_DWH_<TABLE> (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.RAW.MAP_DWH_<TABLE>') IS NULL
BEGIN
CREATE TABLE DB_DWH.RAW.MAP_DWH_<TABLE> (
	 <[COLUMN]>		<DATA_TYPE>				-- <DESCRIPTION>
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
--Purpose:  <PURPOSE>
--Logic:    - <STEP 1>
--          - <STEP 2>
INSERT INTO DB_DWH.RAW.MAP_DWH_<TABLE> (
	 <[COLUMN]>
)

SELECT
	 TEMP.[_ID]
	,TEMP.[_NAME]
	,'INTERNAL_MAPPING'	AS [STAMP_SOURCE]
    ,GETDATE()			AS [STAMP_TIME]
FROM (
VALUES 
	 (1,'')
) TEMP([_ID],[_NAME])

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.RAW.MAP_DWH_<TABLE> AS SRC
	WHERE SRC.[_NAME] = TEMP.[_NAME]
)

END;
*/




