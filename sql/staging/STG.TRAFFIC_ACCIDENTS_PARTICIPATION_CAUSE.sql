/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.STG.RUN_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	30.06.2026
Topic:			Traffic accidents
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides a standardized dataset of traffic accident participants classified by
type of road user and primary accident cause as published by DESTATIS.

The procedure transforms raw traffic accident participant statistics into a
structured staging table by standardizing temporal attributes, preserving the
reported participation and accident cause classifications and enriching the
dataset with technical metadata.

Business Rules
--------------------------------------------------------------------------------------------------------------
- All published participant records are loaded into the staging layer.
- Month names are standardized using the central month mapping table.
- Country names are retained as provided by DESTATIS.
- Technical metadata is added to every loaded record.
- No business aggregations or calculations are performed.

Logic
--------------------------------------------------------------------------------------------------------------
1. Load raw traffic accident participation data from the RAW layer.
2. Standardize month names using the central month mapping table.
3. Convert reporting year into integer format.
4. Preserve accident participation and accident cause classifications.
5. Add technical metadata including source identifier and load timestamp.
6. Load the transformed dataset into DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE.

Result
--------------------------------------------------------------------------------------------------------------
One record per reporting period, country, participant category and accident
cause.

- [ACCIDENT_PARTICIPATION_OPERATOR]  Type of road user involved in the accident
- [ACCIDENT_CAUSE]                   Reported primary cause of the accident
- [COUNTRY_NAME]                     Reporting country
- [YEAR]                             Reporting year
- [MONTH]                            Reporting month (1–12)
- [PARTICIPANTS]                     Number of reported accident participants
- [STAMP_SOURCE]                     Technical source identifier
- [STAMP_TIME]                       Technical load timestamp

Pipelines
--------------------------------------------------------------------------------------------------------------
- Currently no dedicated orchestration pipeline assigned.

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.RAW.DATA_DESTATIS_ACCIDENTS_PARTICIPATION_CAUSE
- DB_DWH.RAW.MAP_DWH_MONTH

Target Objects:
- DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE

Versioning
--------------------------------------------------------------------------------------------------------------
- 30.06.2026 | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS STG.RUN_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE;
GO

CREATE PROCEDURE STG.RUN_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN
--Table definition
--------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE

CREATE TABLE DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE (
	 [ACCIDENT_PARTICIPATION_OPERATOR]    	NVARCHAR(100)
    ,[ACCIDENT_CAUSE]	    				NVARCHAR(100)
    ,[COUNTRY_NAME]         				NVARCHAR(100)
    ,[YEAR]                 				INT
    ,[MONTH]                				INT
    ,[PARTICIPANTS]            				INT
    ,[STAMP_SOURCE]         				NVARCHAR(100)
    ,[STAMP_TIME]           				DATE
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

--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:	#SRC_DATA_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE
--Purpose:	Loading the main raw data for transforming into staging layer.
--Logic:	Raw extraction without business transformation.
DROP TABLE IF EXISTS #SRC_DATA_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE
	SELECT
         SRC.[time] -- Year
        ,SRC.[1_variable_attribute_code] -- Nvarchar value for months from the raw data
        ,SRC.[2_variable_attribute_label] -- Nvarchar value for the referring country. Here only germany since its a destatis data set about german traffic accidents
        ,SRC.[3_variable_attribute_label] -- Identifier for the participation of the party of fault in an accident (e.g. Kraftrat mit amtlichem Kennzeichen)
        ,SRC.[4_variable_attribute_label] -- Cause of the traffic accidents (e.g. Alkoholeinfluss, Abstandsfehler)
        ,SRC.[value] -- Number of vehicle operators involved in traffic accidents
	INTO #SRC_DATA_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE
	FROM RAW.DATA_DESTATIS_ACCIDENTS_PARTICIPATION_CAUSE AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	Resultset
--Purpose:	Transform raw traffic accident data about kinds of participation and cause into the standardized staging layer.
--Logic:    - Standardize month names using the month mapping table.
--          - Convert reporting year into integer format.
--          - Preserve participant and accident cause classifications.
--          - Add technical metadata. 
INSERT INTO DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE

SELECT
     TRY_CAST(SRC.[3_variable_attribute_label] AS NVARCHAR(100))    AS [ACCIDENT_PARTICIPATION_OPERATOR]
    ,TRY_CAST(SRC.[4_variable_attribute_label] AS NVARCHAR(100))    AS [ACCIDENT_CAUSE]
	,TRY_CAST(SRC.[2_variable_attribute_label] AS NVARCHAR(100))    AS [COUNTRY_NAME]
    ,TRY_CAST(SRC.[time] AS INT)                                    AS [YEAR]
    ,#SRC_MAP_MONTH.[MONTH]
    ,SRC.[value]                                                    AS [PARTICIPANTS]
    ,'DESTATIS'                                                     AS [STAMP_SOURCE]
    ,GETDATE()                                                      AS [STAMP_TIME]
FROM #SRC_DATA_TRAFFIC_ACCIDENTS_PARTICIPATION_CAUSE AS SRC
LEFT JOIN #SRC_MAP_MONTH ON #SRC_MAP_MONTH.[MONTH_NAME] = SRC.[1_variable_attribute_code]

END;