/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	03.07.2026
Topic:			Traffic Accidents
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides a standardized dataset of traffic accident participants who were
identified as the party of fault in reported traffic accidents published by
DESTATIS.

The procedure transforms raw participant statistics into a structured staging
table by standardizing temporal and demographic attributes, mapping sex values
to the central DWH reference table and enriching the dataset with technical
metadata.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Only participants identified as the party of fault are loaded.
- Aggregated total records ('Insgesamt') are excluded.
- Month names are standardized using the central month mapping table.
- Sex values are standardized using the central DWH sex mapping.
- Country names are retained as published by DESTATIS.
- No business aggregations are performed.
- Technical metadata is added to every loaded record.

Logic
--------------------------------------------------------------------------------------------------------------
1. Load raw traffic accident participation data from the RAW layer.
2. Standardize reporting months using the month mapping table.
3. Standardize sex attributes using the central sex mapping table.
4. Convert reporting year into integer format.
5. Filter participants to include only parties of fault.
6. Remove aggregated total records.
7. Add technical metadata.
8. Load the transformed dataset into
   DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF.

Result
--------------------------------------------------------------------------------------------------------------
One record per reporting period, participant category, accident category,
location, age group and sex for participants identified as the party of fault.

 [YEAR]								INT				Reporting year
,[MONTH]							INT				Reporting month (1–12)
,[COUNTRY_NAME]						NVARCHAR(100)	Reporting country
,[SEX_ID]							INT				Standardized sex identifier
,[SEX_NAME]							NVARCHAR(100)	Standardized sex label
,[AGE_CATEGORY]						NVARCHAR(100)	Age group
,[ACCIDENT_PARTICIPATION_OPERATOR]	NVARCHAR(100)	Type of participant
,[ACCIDENT_CATEGORY]				NVARCHAR(100)	Accident category
,[ACCIDENT_LOCATION]				NVARCHAR(100)	Accident location
,[PARTICIPANTS]						INT				Number of participants
,[STAMP_SOURCE]						NVARCHAR(100)	Technical source identifier
,[STAMP_TIME]						DATETIME		Technical load timestamp



Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_ACCIDENTS

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.RAW.DATA_DESTATIS_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION
- DB_DWH.RAW.MAP_DWH_MONTH
- DB_DWH.RAW.MAP_DWH_SEX

Target Objects:
- DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF

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

DROP PROCEDURE IF EXISTS STG.RUN_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF;
GO

CREATE PROCEDURE STG.RUN_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN
--Table definition
--------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF

CREATE TABLE DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF (
	 [YEAR]								INT				-- Reporting year
	,[MONTH]							INT				-- Reporting month (1–12)
	,[COUNTRY_NAME]						NVARCHAR(100)	-- Reporting country
	,[SEX_ID]							INT				-- Standardized sex identifier
	,[SEX_NAME]							NVARCHAR(100)	-- Standardized sex label
	,[AGE_CATEGORY]						NVARCHAR(100)	-- Age group
	,[ACCIDENT_PARTICIPATION_OPERATOR]	NVARCHAR(100)	-- Type of participant
	,[ACCIDENT_CATEGORY]				NVARCHAR(100)	-- Accident category
	,[ACCIDENT_LOCATION]				NVARCHAR(100)	-- Accident location
	,[PARTICIPANTS]						INT				-- Number of participants
	,[STAMP_SOURCE]						NVARCHAR(100)	-- Technical source identifier
	,[STAMP_TIME]						DATETIME		-- Technical load timestamp
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

--Table:	#SRC_MAP_SEX
--Purpose:	Replacing nvarchar sex labels of the data source with integer values and static sex labels from the internal dwh mapping.
--Logic:	Lookup table for standardizing sex information.
DROP TABLE IF EXISTS #SRC_MAP_SEX
	SELECT
		 SRC.[SEX_ID]				-- Integer value for the sex ID
		,SRC.[SEX_NAME]				-- Nvarchar value for sex from the internal dwh mapping
		,SRC.[SEX_NAME_DESTATIS]	-- Nvarchar value for sex from the raw data
	INTO #SRC_MAP_SEX
	FROM DB_DWH.RAW.MAP_DWH_SEX AS SRC
CREATE CLUSTERED INDEX IX_SRC_MAP_SEX ON #SRC_MAP_SEX([SEX_ID])

--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:	#SRC_DATA_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
--Purpose:	Loading the main raw data for transforming into staging layer.
--Logic:	Raw extraction without business transformation.
DROP TABLE IF EXISTS #SRC_DATA_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
	SELECT
         SRC.[time] -- Year
        ,SRC.[_1_variable_attribute_code] -- Nvarchar value for months from the raw data
        ,SRC.[_2_variable_attribute_label] -- Nvarchar value for the referring country. Here only germany since its a destatis data set about german traffic accidents
        ,SRC.[_3_variable_attribute_label] -- Sex of of injured/damaged vehicle operators and injured pedestrians involved in the traffic accident (e.g. männlich)
        ,SRC.[_4_variable_attribute_label] -- Age of injured/damaged vehicle operators and injured pedestrians involved in the traffic accident (e.g. 21 bis unter 25 Jahre)
		,SRC.[_5_variable_attribute_label] -- Identifier for the participation in an accident (e.g. Kraftrat mit amtlichem Kennzeichen) 
		,SRC.[_6_variable_attribute_label] -- Category of the traffic accident (e.g. Unfälle mit Personenschaden, Übrige Sachschadensunfälle, Sonst. Unfälle unter dem Einflauss berausch. Mittel)
		,SRC.[_7_variable_attribute_label] -- Location of the traffic accidents (e.g. Außerorts, auf Autobahnen)
		,SRC.[value_variable_label] -- Distinguishes between all participants and participants identified as the party of fault.
        ,SRC.[value] -- Number of injured/damaged vehicle operators and injured pedestrians involved in traffic accidents and number of party of fault in an accident - Will get divided in the transformation later on.
	INTO #SRC_DATA_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF
	FROM RAW.DATA_DESTATIS_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	Resultset
--Purpose:	Transform raw traffic accident data about participants being party of fault kinds of sex, age, participation and category into the standardized staging layer.
--Logic:   	- Standardize month names via DWH month mapping.
--			- Standardize sex values via DWH sex mapping.
--			- Convert reporting year.
--			- Filter records to participants identified as the party of fault.
--			- Remove aggregated total rows.
--			- Add technical metadata.

INSERT INTO DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF

SELECT
	 TRY_CAST(SRC.[time] AS INT) 									AS [YEAR]
	,#SRC_MAP_MONTH.[MONTH]
	,TRY_CAST(SRC.[_2_variable_attribute_label] AS NVARCHAR(100)) 	AS [COUNTRY_NAME]
	,#SRC_MAP_SEX.[SEX_ID]
	,#SRC_MAP_SEX.[SEX_NAME]
	,TRY_CAST(SRC.[_4_variable_attribute_label] AS NVARCHAR(100)) 	AS [AGE_CATEGORY]
	,TRY_CAST(SRC.[_5_variable_attribute_label] AS NVARCHAR(100)) 	AS [ACCIDENT_PARTICIPATION_OPERATOR]
	,TRY_CAST(SRC.[_6_variable_attribute_label] AS NVARCHAR(100)) 	AS [ACCIDENT_CATEGORY]
	,TRY_CAST(SRC.[_7_variable_attribute_label] AS NVARCHAR(100)) 	AS [ACCIDENT_LOCATION]
	,ISNULL(TRY_CAST(SRC.[value] AS INT),0)							AS [PARTICIPANTS]	
	,'DESTATIS'														AS [STAMP_SOURCE]
	,GETDATE()														AS [STAMP_TIME]
FROM #SRC_DATA_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_POF AS SRC
LEFT JOIN #SRC_MAP_MONTH ON #SRC_MAP_MONTH.[MONTH_NAME] = SRC.[_1_variable_attribute_code]
LEFT JOIN #SRC_MAP_SEX ON #SRC_MAP_SEX.[SEX_NAME_DESTATIS] = SRC.[_3_variable_attribute_label]

WHERE 	SRC.[_3_variable_attribute_label] <> 'Insgesamt'	-- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
AND		SRC.[_4_variable_attribute_label] <> 'Insgesamt'	-- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
AND		SRC.[_5_variable_attribute_label] <> 'Insgesamt'	-- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
AND		SRC.[_6_variable_attribute_label] <> 'Insgesamt'	-- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
AND		SRC.[_7_variable_attribute_label] <> 'Insgesamt'	-- Source dataset contains sum rows that need to be deleted since measures will be calculated in DAX later on
AND 	SRC.[value_variable_label] = 'Hauptverursacher des Unfalls' -- Extracting only values for participants being the party of fault
AND		ISNULL(TRY_CAST(SRC.[value] AS INT),0) <> 0 -- Eliminating non-populated records
END;