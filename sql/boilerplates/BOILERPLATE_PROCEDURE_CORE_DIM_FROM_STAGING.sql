/*
/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_DIM_<TABLE>
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	<DATE>
Topic:			Dimension table of <TOPIC>
Sources:		DESTATIS

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
- PIPELINE_UPDATE_DIMENSIONS

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.CORE.<SOURCE_TABLE>

Target Objects:
- DB_DWH.CORE.DIM_<TABLE>

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

DROP PROCEDURE IF EXISTS CORE.RUN_DIM_<TABLE>;
GO

CREATE PROCEDURE CORE.RUN_DIM_<TABLE> (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.CORE.DIM_<TABLE>') IS NULL
BEGIN
CREATE TABLE DB_DWH.CORE.DIM_<TABLE> (
	 [_ID]        INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,[_NAME]                NVARCHAR(100)   -- Static DWH sex label (e.g. Unbekannt, Männlich)
    ,[_NAME_DESTATIS]       NVARCHAR(100)   -- DESTATIS sex attribute label (e.g. Ohne Angabe, männlich)
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
-- Dimension table. No external mapping sources required.

--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:	#TABLE
--Purpose:	
--Logic:	
/*DROP TABLE IF EXISTS #<TABLE>
	SELECT DISTINCT
		SRC.[<COLUMN>]          AS [DIM_NAME]
	INTO #<TABLE>
	FROM CORE.<SOURCE_TABLE> AS SRC*/

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:    Resultset
--Purpose:  <PURPOSE>
--Logic:    - <STEP 1>
--          - <STEP 2>
INSERT INTO DB_DWH.CORE.DIM_<TABLE> (
     [_NAME]        
    ,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 SRC.[DIM_NAME]                                 AS [_NAME]
	,'STAGING'      	                            AS [STAMP_SOURCE]
    ,GETDATE()			                            AS [STAMP_TIME]
FROM #<TABLE>

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.CORE.DIM_<TABLE> AS SRC
	WHERE SRC.[_NAME] = #<TABLE>.[_NAME]
)

END;
*/




