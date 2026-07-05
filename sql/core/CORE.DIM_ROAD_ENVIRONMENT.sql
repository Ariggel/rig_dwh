/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_DIM_ROAD_ENVIRONMENT
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	05.07.2026
Topic:			Dimension table of road environments.
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides the central road environment dimension used throughout the data warehouse.

The procedure extracts all distinct road environment categories from the available staging
tables, removes duplicates and inserts previously unknown road environment groups into the
shared dimension table.

The resulting dimension is used by multiple fact tables to provide a
standardized road environment reference across the entire data warehouse.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Road environment categories are extracted from all relevant staging tables.
- Duplicate road environment categories are removed.
- Existing dimension members are preserved.
- New road environment categories are appended only.
- Technical metadata is added to every inserted record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Extract distinct road environment categories from all relevant staging tables.
2. Combine all extracted road environment categories into one unified dataset.
3. Remove duplicate values.
4. Compare the resulting dataset with the existing dimension table.
5. Insert only previously unknown road environment categories.
6. Add technical metadata.

Result
--------------------------------------------------------------------------------------------------------------
Dimension table containing the road environment categories from DESTATIS including the primary key for road environment categories in the DWH.

 [ROAD_ENVIRONMENT_ID]      INT             -- Primary key for road environment categories
,[ROAD_ENVIRONMENT_NAME]	NVARCHAR(100)	-- Static DWH road environment label (e.g. innerorts, auf Autobahnen)
,[STAMP_TIME]				DATETIME		-- Loading time
,[STAMP_SOURCE] 			NVARCHAR(100)	-- Source definition, here: STAGING

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_UPDATE_DIMENSIONS

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
- DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
- DB_DWH.STG.TRAFFIC_ACCIDENTS

Target Objects:
- DB_DWH.CORE.DIM_ROAD_ENVIRONMENT

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

DROP PROCEDURE IF EXISTS CORE.RUN_DIM_ROAD_ENVIRONMENT;
GO

CREATE PROCEDURE CORE.RUN_DIM_ROAD_ENVIRONMENT (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.CORE.DIM_ROAD_ENVIRONMENT') IS NULL
BEGIN
CREATE TABLE DB_DWH.CORE.DIM_ROAD_ENVIRONMENT (
	 [ROAD_ENVIRONMENT_ID]      INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,[ROAD_ENVIRONMENT_NAME]    NVARCHAR(100)   -- Static DWH road environment label (e.g. innerorts, auf Autobahnen)
	,[STAMP_TIME]	        	DATETIME		-- Loading time
	,[STAMP_SOURCE]         	NVARCHAR(100)	-- Source definition, here: STAGING
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
--Purpose: 	Extract distinct road environment categories from the staging table.
--Logic:   	Read all available road environment categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	SELECT DISTINCT
		SRC.[ACCIDENT_LOCATION]         AS [ROAD_ENVIRONMENT_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS AS SRC

--Table:	#SRC_DAT_ACC_PART_CAT_LOC_POF
--Purpose: 	Extract distinct road environment categories from the staging table.
--Logic:   	Read all available road environment categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
	SELECT DISTINCT
		SRC.[ACCIDENT_LOCATION]         AS [ROAD_ENVIRONMENT_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_POF
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF AS SRC

--Table:	#SRC_DAT_ACC
--Purpose: 	Extract distinct road environment categories from the staging table.
--Logic:   	Read all available road environment categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC
	SELECT DISTINCT
		SRC.[ACCIDENT_LOCATION]         AS [ROAD_ENVIRONMENT_DESTATIS]
	INTO #SRC_DAT_ACC
	FROM STG.TRAFFIC_ACCIDENTS AS SRC
/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	#DIMENSIONS_UNION
--Purpose:  Build a unified set of road environment categories from all available staging tables.
--Logic:    - Combine all extracted road environment categories.
--          - Remove duplicate values.
DROP TABLE IF EXISTS #DIMENSIONS_UNION
	SELECT DISTINCT
		SRC.[ROAD_ENVIRONMENT_DESTATIS]
	INTO #DIMENSIONS_UNION
	FROM (
		SELECT [ROAD_ENVIRONMENT_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS

		UNION

		SELECT [ROAD_ENVIRONMENT_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_POF

		UNION
		SELECT [ROAD_ENVIRONMENT_DESTATIS]
		FROM #SRC_DAT_ACC
	) SRC



--Table:    Resultset
--Purpose:  Load newly discovered road environment categories into the shared road environment dimension.
--Logic:    - Insert only road environment categories that do not already exist.
--          - Add technical metadata.
INSERT INTO DB_DWH.CORE.DIM_ROAD_ENVIRONMENT (
     [ROAD_ENVIRONMENT_NAME]        
    ,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 #DIMENSIONS_UNION.[ROAD_ENVIRONMENT_DESTATIS]  AS [ROAD_ENVIRONMENT_NAME]
	,'STAGING'      	                            AS [STAMP_SOURCE]
    ,GETDATE()			                            AS [STAMP_TIME]
FROM #DIMENSIONS_UNION

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.CORE.DIM_ROAD_ENVIRONMENT AS SRC
	WHERE SRC.[ROAD_ENVIRONMENT_NAME] = #DIMENSIONS_UNION.[ROAD_ENVIRONMENT_DESTATIS]
)

END;




