/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_TABLE
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	<DATE>
Topic:			<TOPIC>
Sources:		<SOURCE>

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
Result description.
 [FACT_ID]				INT				IDENTITY(1,1) NOT NULL PRIMARY KEY
,[DIM_ID]				INT				-- 
,[VALUE]				<DATA_TYPE>		--
,[STAMP_SOURCE]			NVARCHAR(100)	-- Source definition, here: STAGING
,[STAMP_SOURCE_STG]		NVARCHAR(100)	-- Source definition of staged data, here: 
,[STAMP_TIME]			DATETIME		-- Loading time
,[STAMP_TIME_STG]		DATETIME		-- Loading time of the staged data

Pipelines
--------------------------------------------------------------------------------------------------------------
- Currently no dedicated orchestration pipeline assigned.

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- 

Target Objects:
- DB_DWH.CORE.TABLE

Versioning
--------------------------------------------------------------------------------------------------------------
-  | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

/*DROP PROCEDURE IF EXISTS CORE.RUN_TABLE;
GO

CREATE PROCEDURE CORE.RUN_TABLE (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN*/
--Table definition
--------------------------------------------------------------------------------------------------------------
/*DROP TABLE IF EXISTS DB_DWH.CORE.TABLE

CREATE TABLE DB_DWH.CORE.TABLE (
	 [FACT_ID]				INT				IDENTITY(1,1) NOT NULL PRIMARY KEY
	,[DIM_ID]				INT				-- 
	,[DIM_ID_2]				INT				--
	,[VALUE]				<DATA_TYPE>		--
	,[STAMP_SOURCE]			NVARCHAR(100)	-- Source definition, here: STAGING
	,[STAMP_SOURCE_STG]		NVARCHAR(100)	-- Source definition of staged data, here: 
	,[STAMP_TIME]			DATETIME		-- Loading time
	,[STAMP_TIME_STG]		DATETIME		-- Loading time of the staged data
)

UNIQUE
(
     [DIM_ID]
	,[DIM_ID_2]
)
*/

--Parameter definition
--------------------------------------------------------------------------------------------------------------
-- @DEFAULT
-- Technical placeholder parameter according to DWH framework standard.
-- Currently not used.

/*===========================================================================================================
			SOURCES
=============================================================================================================*/
--Dimension sources
--------------------------------------------------------------------------------------------------------------
--Table:	#TABLE
--Purpose:	
--Logic:	
/*DROP TABLE IF EXISTS #TABLE
	SELECT
		
	INTO #TABLE
	FROM
CREATE CLUSTERED INDEX IX_TABLE ON #TABLE([COLUMN])*/

--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:	#TABLE
--Purpose:	
--Logic:	
/*DROP TABLE IF EXISTS #TABLE
	SELECT
		
	INTO #TABLE
	FROM*/

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	
--Purpose:	
--Logic:   	- 
--         	- 

	
/*INSERT INTO DB_DWH.CORE.TABLE*/

/*SELECT

FROM*/

--END;