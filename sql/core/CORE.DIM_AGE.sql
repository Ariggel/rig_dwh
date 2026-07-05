/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_DIM_AGE
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	05.07.2026
Topic:			Dimension table of Age Dimension
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides the central age dimension used throughout the data warehouse.

The procedure extracts all distinct age categories from the available staging
tables, removes duplicates and inserts previously unknown age groups into the
shared dimension table.

The resulting dimension is used by multiple fact tables to provide a
standardized age reference across the entire data warehouse.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Age categories are extracted from all relevant staging tables.
- Duplicate age categories are removed.
- Existing dimension members are preserved.
- New age categories are appended only.
- Technical metadata is added to every inserted record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Extract distinct age categories from all relevant staging tables.
2. Combine all extracted age categories into one unified dataset.
3. Remove duplicate values.
4. Compare the resulting dataset with the existing dimension table.
5. Insert only previously unknown age categories.
6. Add technical metadata.

Result
--------------------------------------------------------------------------------------------------------------
Dimension table containing the age spans from DESTATIS including the primary key for age spans in the DWH.

 [AGE_ID]       INT             -- Primary key for age spans
,[AGE_NAME]		NVARCHAR(100)	-- Static DWH age label (e.g. Unter 15 Jahren)
,[STAMP_TIME]	DATETIME		-- Loading time
,[STAMP_SOURCE] NVARCHAR(100)	-- Source definition, here: STAGING

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_UPDATE_DIMENSIONS

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.STG.ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
- DB_DWH.STG.ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF

Target Objects:
- DB_DWH.CORE.DIM_AGE

Versioning
--------------------------------------------------------------------------------------------------------------
- 05.07.2026 | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS CORE.RUN_DIM_AGE;
GO

CREATE PROCEDURE CORE.RUN_DIM_AGE (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.CORE.DIM_AGE') IS NULL
BEGIN
CREATE TABLE DB_DWH.CORE.DIM_AGE (
	 [AGE_ID]        		INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,[AGE_NAME]             NVARCHAR(100)   -- Static DWH age label (e.g. Unter 15 Jahren)
	,[STAMP_TIME]	        DATETIME		-- Loading time
	,[STAMP_SOURCE]         NVARCHAR(100)	-- Source definition, here: STAGING
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
--Table:	#SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
--Purpose: 	Extract distinct age categories from the staging table.
--Logic:   	Read all available age categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	SELECT DISTINCT
		SRC.[AGE_CATEGORY]         AS [AGE_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS AS SRC

--Table:	#SRC_DAT_ACC_PART_CAT_LOC_POF
--Purpose: 	Extract distinct age categories from the staging table.
--Logic:   	Read all available age categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC_PART_CAT_LOC_POF
	SELECT DISTINCT
		SRC.[AGE_CATEGORY]         AS [AGE_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_POF
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF AS SRC
/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	#DIMENSIONS_UNION
--Purpose:  Build a unified set of age categories from all available staging tables.
--Logic:    - Combine all extracted age categories.
--          - Remove duplicate values.
DROP TABLE IF EXISTS #DIMENSIONS_UNION
	SELECT DISTINCT
		SRC.[AGE_CATEGORY_DESTATIS]
	INTO #DIMENSIONS_UNION
	FROM (
		SELECT [AGE_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS

		UNION

		SELECT [AGE_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_POF
	) SRC



--Table:    Resultset
--Purpose:  Load newly discovered age categories into the shared age dimension.
--Logic:    - Insert only age categories that do not already exist.
--          - Add technical metadata.
INSERT INTO DB_DWH.CORE.DIM_AGE (
     [AGE_NAME]        
    ,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 #DIMENSIONS_UNION.[AGE_CATEGORY_DESTATIS]      AS [AGE_NAME]
	,'STAGING'      	                            AS [STAMP_SOURCE]
    ,GETDATE()			                            AS [STAMP_TIME]
FROM #DIMENSIONS_UNION

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.CORE.DIM_AGE AS SRC
	WHERE SRC.[AGE_NAME] = #DIMENSIONS_UNION.[AGE_CATEGORY_DESTATIS]
)

END;




