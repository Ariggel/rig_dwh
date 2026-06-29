/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.RAW.RUN_TRAFFIC_ACCIDENTS
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	29.06.2026
Topic:			Traffic accidents
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides a standardized dataset of reported traffic accidents published by
DESTATIS.

The procedure transforms raw accident statistics into a structured staging
table by standardizing temporal and geographical attributes, enriching the
dataset with technical metadata and removing pre-aggregated records that are
not required for analytical reporting.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Only detailed accident records are loaded into the staging layer.
- Pre-aggregated total records ('Insgesamt') are excluded to avoid double
  counting during analytical calculations.
- German federal states are standardized using the central state mapping table.
- Month names are standardized using the central month mapping table.
- Technical metadata is added to every loaded record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Load raw traffic accident data from the RAW layer.
2. Standardize month names using the central month mapping table.
3. Standardize German federal states using the central state mapping table.
4. Convert source attributes into standardized data types.
5. Remove aggregated total records ('Insgesamt').
6. Add technical metadata including source identifier and load timestamp.
7. Load the transformed dataset into DB_DWH.STG.TRAFFIC_ACCIDENTS.

Result
--------------------------------------------------------------------------------------------------------------
One record per reporting period, federal state, accident category and accident
location.

- [ACCIDENT_CATEGORY]  Type of reported traffic accident
- [ACCIDENT_LOCATION]  Location category of the accident
- [STATE_ID]           Standardized federal state identifier
- [STATE_NAME]         Official German federal state name
- [YEAR]               Reporting year
- [MONTH]              Reporting month (1–12)
- [ACCIDENTS]          Number of reported traffic accidents
- [STAMP_SOURCE]       Technical source identifier
- [STAMP_TIME]         Technical load timestamp

Pipelines
--------------------------------------------------------------------------------------------------------------
- Currently no dedicated orchestration pipeline assigned.

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.RAW.DATA_DESTATIS_ACCIDENTS
- DB_DWH.RAW.MAP_DWH_MONTH
- DB_DWH.RAW.MAP_GERMAN_STATES

Target Objects:
- DB_DWH.STG.TRAFFIC_ACCIDENTS

Versioning
--------------------------------------------------------------------------------------------------------------
- 29.06.2026 | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS STG.RUN_TRAFFIC_ACCIDENTS;
GO

CREATE PROCEDURE STG.RUN_TRAFFIC_ACCIDENTS (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN
--Table definition
--------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS DB_DWH.STG.TRAFFIC_ACCIDENTS

CREATE TABLE DB_DWH.STG.TRAFFIC_ACCIDENTS (
	 [ACCIDENT_CATEGORY]    NVARCHAR(100)
    ,[ACCIDENT_LOCATION]    NVARCHAR(100)
    ,[STATE_ID]             INT
    ,[STATE_NAME]           NVARCHAR(100)
    ,[YEAR]                 INT
    ,[MONTH]                INT
    ,[ACCIDENTS]            INT
    ,[STAMP_SOURCE]         NVARCHAR(100)
    ,[STAMP_TIME]           DATE
     
)

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
--Table:	#SRC_MAP_MONTH
--Purpose:	Replacing nvarchar month names of the data source with integer month values.
--Logic:	Lookup table for standardizing month information.
DROP TABLE IF EXISTS #SRC_MAP_MONTH
	SELECT
		 SRC.[MONTH]		-- Integer value for months 1 to 12
		,SRC.[MONTH_NAME]	-- Nvarchar value for months from the raw data
	INTO #SRC_MAP_MONTH
	FROM DB_DWH.RAW.MAP_DWH_MONTH AS SRC
CREATE CLUSTERED INDEX IX_SRC_MAP_MONTH ON #SRC_MAP_MONTH([MONTH])

--Table:	#SRC_MAP_GERMAN_STATES
--Purpose:	Replacing nvarchar german state names of the data source with integer values.
--Logic:	Lookup table for standardizing german state information.
DROP TABLE IF EXISTS #SRC_MAP_GERMAN_STATES
	SELECT
		 SRC.[STATE_ID]		-- Integer value for months 1 to 12
		,SRC.[STATE_NAME]	-- Nvarchar value for months from the raw data
	INTO #SRC_MAP_GERMAN_STATES
	FROM DB_DWH.RAW.MAP_DWH_GERMAN_STATES AS SRC
CREATE CLUSTERED INDEX IX_SRC_MAP_GERMAN_STATES ON #SRC_MAP_GERMAN_STATES([STATE_ID])

--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:	#SRC_DATA_ACCIDENTS
--Purpose:	Loading the main raw data for transforming into staging layer.
--Logic:	Raw extraction without business transformation.
DROP TABLE IF EXISTS #SRC_DATA_ACCIDENTS
    SELECT
         SRC.[time] -- Year
        ,SRC.[1_variable_attribute_code] -- Nvarchar value for months from the raw data
        ,SRC.[2_variable_attribute_label] -- Nvarchar value for the referring state (e.g. Bremen, Bayern)
        ,SRC.[3_variable_attribute_label] -- Identifier for the category of traffic accident (e.g. Unfälle mit Personenschaden)
        ,SRC.[4_variable_attribute_label] -- Location of the traffic accidents (e.g. Außerorts, auf Autobahnen)
        ,SRC.[value] -- Number of traffic accidents happened
    INTO #SRC_DATA_ACCIDENTS
    FROM RAW.DATA_DESTATIS_ACCIDENTS AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:    Resultset
--Purpose:  Transform raw traffic accident data into the standardized staging layer.
--Logic:    - Standardize month names using the month mapping table.
--          - Standardize German federal states.
--          - Convert source attributes into standardized data types.
--          - Preserve reported accident counts.
--          - Remove aggregated total records.
--          - Add technical metadata.
INSERT INTO DB_DWH.STG.TRAFFIC_ACCIDENTS

SELECT
     TRY_CAST(SRC.[3_variable_attribute_label] AS NVARCHAR(100))    AS [ACCIDENT_CATEGORY]
    ,TRY_CAST(SRC.[4_variable_attribute_label] AS NVARCHAR(100))    AS [ACCIDENT_LOCATION]
    ,#SRC_MAP_GERMAN_STATES.[STATE_ID]
    ,#SRC_MAP_GERMAN_STATES.[STATE_NAME]
    ,TRY_CAST(SRC.[time] AS INT)                                    AS [YEAR]
    ,#SRC_MAP_MONTH.[MONTH]
    ,SRC.[value]                                                    AS [ACCIDENTS]
    ,'DESTATIS'                                                     AS [STAMP_SOURCE]
    ,GETDATE()                                                      AS [STAMP_TIME]
FROM #SRC_DATA_ACCIDENTS AS SRC
LEFT JOIN #SRC_MAP_MONTH ON #SRC_MAP_MONTH.[MONTH_NAME] = SRC.[1_variable_attribute_code]
LEFT JOIN #SRC_MAP_GERMAN_STATES ON #SRC_MAP_GERMAN_STATES.[STATE_NAME] = SRC.[2_variable_attribute_label]
WHERE   SRC.[3_variable_attribute_label] <> 'Insgesamt' -- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
AND     SRC.[4_variable_attribute_label] <> 'Insgesamt' -- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
	
END;






