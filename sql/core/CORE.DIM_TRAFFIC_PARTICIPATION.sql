/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_DIM_TRAFFIC_PARTICIPATION
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	05.07.2026
Topic:			Traffic Participation Dimension
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides the central traffic participation dimension used throughout the data warehouse.

The procedure extracts all distinct traffic participation categories from the available staging
tables, removes duplicates and inserts previously unknown traffic participation groups into the
shared dimension table.

The resulting dimension is used by multiple fact tables to provide a
standardized traffic participation reference across the entire data warehouse.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Traffic participation categories are extracted from all relevant staging tables.
- Duplicate traffic participation categories are removed.
- Existing dimension members are preserved.
- New traffic participation categories are appended only.
- Technical metadata is added to every inserted record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Extract distinct traffic participation categories from all relevant staging tables.
2. Combine all extracted traffic participation categories into one unified dataset.
3. Remove duplicate values.
4. Compare the resulting dataset with the existing dimension table.
5. Insert only previously unknown traffic participation categories.
6. Add technical metadata.

Result
--------------------------------------------------------------------------------------------------------------
Dimension table containing the traffic participation spans from DESTATIS including the primary key for traffic participation kinds in the DWH.

 [TRAFFIC_PARTICIPATION_ID]         INT             -- Primary key for traffic participation kinds
,[TRAFFIC_PARTICIPATION_NAME]		NVARCHAR(100)	-- Static DWH traffic participation label (e.g. Kraftrad mit amtlichen Kennzeichen)
,[STAMP_TIME]	DATETIME		                    -- Loading time
,[STAMP_SOURCE] NVARCHAR(100)	                    -- Source definition, here: STAGING

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_UPDATE_DIMENSIONS

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.STG.ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
- DB_DWH.STG.ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF

Target Objects:
- DB_DWH.CORE.DIM_TRAFFIC_PARTICIPATION

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

DROP PROCEDURE IF EXISTS CORE.RUN_DIM_TRAFFIC_PARTICIPATION;
GO

CREATE PROCEDURE CORE.RUN_DIM_TRAFFIC_PARTICIPATION (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.CORE.DIM_TRAFFIC_PARTICIPATION') IS NULL
BEGIN
CREATE TABLE DB_DWH.CORE.DIM_TRAFFIC_PARTICIPATION (
	 [TRAFFIC_PARTICIPATION_ID]     INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,[TRAFFIC_PARTICIPATION_NAME]   NVARCHAR(100)       -- Static DWH traffic participation label (e.g. Kraftrad mit amtlichem Kennzeichen)
	,[STAMP_TIME]	                DATETIME		    -- Loading time
	,[STAMP_SOURCE]                 NVARCHAR(100)	    -- Source definition, here: STAGING
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
--Purpose: 	Extract distinct traffic participation categories from the staging table.
--Logic:   	Read all available traffic participation categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	SELECT DISTINCT
		SRC.[ACCIDENT_PARTICIPATION_OPERATOR]         AS [TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS AS SRC

--Table:	#SRC_DAT_ACC_PART_CAT_LOC_POF
--Purpose: 	Extract distinct traffic participation categories from the staging table.
--Logic:   	Read all available traffic participation categories without business transformation.
DROP TABLE IF EXISTS #SRC_DAT_ACC_PART_CAT_LOC_POF
	SELECT DISTINCT
		SRC.[ACCIDENT_PARTICIPATION_OPERATOR]         AS [TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]
	INTO #SRC_DAT_ACC_PART_CAT_LOC_POF
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF AS SRC
/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	#DIMENSIONS_UNION
--Purpose:  Build a unified set of traffic participation categories from all available staging tables.
--Logic:    - Combine all extracted traffic participation categories.
--          - Remove duplicate values.
DROP TABLE IF EXISTS #DIMENSIONS_UNION
	SELECT DISTINCT
		SRC.[TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]
	INTO #DIMENSIONS_UNION
	FROM (
		SELECT [TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_PARTICIPANTS

		UNION

		SELECT [TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]
		FROM #SRC_DAT_ACC_PART_CAT_LOC_POF
	) SRC



--Table:    Resultset
--Purpose:  Load newly discovered traffic participation categories into the shared traffic participation dimension.
--Logic:    - Insert only traffic participation categories that do not already exist.
--          - Add technical metadata.
INSERT INTO DB_DWH.CORE.DIM_TRAFFIC_PARTICIPATION (
     [TRAFFIC_PARTICIPATION_NAME]        
    ,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 #DIMENSIONS_UNION.[TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]    AS [TRAFFIC_PARTICIPATION_NAME]
	,'STAGING'      	                                            AS [STAMP_SOURCE]
    ,GETDATE()			                                            AS [STAMP_TIME]
FROM #DIMENSIONS_UNION

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.CORE.DIM_TRAFFIC_PARTICIPATION AS SRC
	WHERE SRC.[TRAFFIC_PARTICIPATION_NAME] = #DIMENSIONS_UNION.[TRAFFIC_PARTICIPATION_CATEGORY_DESTATIS]
)

END;




