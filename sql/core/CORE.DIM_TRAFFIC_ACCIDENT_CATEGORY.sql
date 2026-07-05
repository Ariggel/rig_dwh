/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_DIM_TRAFFIC_ACCIDENT_CATEGORY
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	05.07.2026
Topic:			Dimension table of traffic accident categories.
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides the central traffic accident categories dimension used throughout the data warehouse.

The procedure extracts all distinct traffic accident categories from the available staging
tables, removes duplicates and inserts previously unknown traffic accident categories groups into the
shared dimension table.

The resulting dimension is used by multiple fact tables to provide a
standardized traffic accident categories reference across the entire data warehouse.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Traffic accident categories are extracted from all relevant staging tables.
- Duplicate traffic accident categories are removed.
- Existing dimension members are preserved.
- New traffic accident categories are appended only.
- Technical metadata is added to every inserted record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Extract distinct traffic accident categories from all relevant staging tables.
2. Combine all extracted traffic accident categories into one unified dataset.
3. Remove duplicate values.
4. Compare the resulting dataset with the existing dimension table.
5. Insert only previously unknown traffic accident categories.
6. Add technical metadata.

Result
--------------------------------------------------------------------------------------------------------------
Dimension table containing the traffic accident categories from DESTATIS including the primary key for traffic accident categories in the DWH.

 [TRAFFIC_ACCIDENT_CATEGORY_ID]     INT             -- Primary key for traffic accident categories
,[TRAFFIC_ACCIDENT_CATEGORY_NAME]	NVARCHAR(100)	-- Static DWH traffic accident categories label (e.g. Unfälle mit Personenschaden)
,[STAMP_TIME]						DATETIME		-- Loading time
,[STAMP_SOURCE] 					NVARCHAR(100)	-- Source definition, here: STAGING

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_UPDATE_DIMENSIONS

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.STG.ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
- DB_DWH.STG.ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
- DB_DWH.STG.TRAFFIC_ACCIDENTS

Target Objects:
- DB_DWH.CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY

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

DROP PROCEDURE IF EXISTS CORE.RUN_DIM_TRAFFIC_ACCIDENT_CATEGORY;
GO

CREATE PROCEDURE CORE.RUN_DIM_TRAFFIC_ACCIDENT_CATEGORY (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY') IS NULL
BEGIN
CREATE TABLE DB_DWH.CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY (
	 [TRAFFIC_ACCIDENT_CATEGORY_ID]     INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,[TRAFFIC_ACCIDENT_CATEGORY_NAME]   NVARCHAR(100)   -- Static DWH traffic accident categories label (e.g. Unfälle mit Personenschaden)
	,[STAMP_TIME]	        			DATETIME		-- Loading time
	,[STAMP_SOURCE]         			NVARCHAR(100)	-- Source definition, here: STAGING
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
--Purpose: 	Extract distinct traffic accident categories from the staging table.
--Logic:   	Read all available traffic accident categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	SELECT DISTINCT
		SRC.[ACCIDENT_CATEGORY]         AS [TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS AS SRC

--Table:	#SRC_DAT_ACC_PART_CAT_LOC_POF
--Purpose: 	Extract distinct traffic accident categories from the staging table.
--Logic:   	Read all available traffic accident categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
	SELECT DISTINCT
		SRC.[ACCIDENT_CATEGORY]         AS [TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_POF
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF AS SRC

--Table:	#SRC_DAT_ACC
--Purpose: 	Extract distinct traffic accident categories from the staging table.
--Logic:   	Read all available traffic accident categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC
	SELECT DISTINCT
		SRC.[ACCIDENT_CATEGORY]         AS [TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC
	FROM STG.TRAFFIC_ACCIDENTS AS SRC
/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	#DIMENSIONS_UNION
--Purpose:  Build a unified set of traffic accident categories from all available staging tables.
--Logic:    - Combine all extracted traffic accident categories.
--          - Remove duplicate values.
DROP TABLE IF EXISTS #DIMENSIONS_UNION
	SELECT DISTINCT
		SRC.[TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
	INTO #DIMENSIONS_UNION
	FROM (
		SELECT [TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS

		UNION

		SELECT [TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_POF

		UNION
		SELECT [TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC
	) SRC



--Table:    Resultset
--Purpose:  Load newly discovered traffic accident categories into the shared traffic accident categories dimension.
--Logic:    - Insert only traffic accident categories that do not already exist.
--          - Add technical metadata.
INSERT INTO DB_DWH.CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY (
     [TRAFFIC_ACCIDENT_CATEGORY_NAME]        
    ,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 #DIMENSIONS_UNION.[TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]  AS [TRAFFIC_ACCIDENT_CATEGORY_NAME]
	,'STAGING'      	                            AS [STAMP_SOURCE]
    ,GETDATE()			                            AS [STAMP_TIME]
FROM #DIMENSIONS_UNION

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY AS SRC
	WHERE SRC.[TRAFFIC_ACCIDENT_CATEGORY_NAME] = #DIMENSIONS_UNION.[TRAFFIC_ACCIDENT_CATEGORY_DESTATIS]
)

END;




