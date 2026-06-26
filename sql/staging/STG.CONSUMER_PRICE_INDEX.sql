/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.STG.RUN_CONSUMER_PRICE_INDEX
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	24.06.2026
Topic:			Consumer price index / inflation
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
The Consumer Price Index (CPI) measures the average price development of goods and
services purchased by private households in Germany.

The dataset provides the official monthly Consumer Price Index published by DESTATIS
and serves as the central inflation indicator within the DWH.

Typical use cases include:
- Inflation analysis
- Purchasing power analysis
- Economic trend monitoring
- Deflation and inflation reporting
- Reference value for economic forecasting models
- KPI calculations and dashboard reporting

The index is stored at monthly granularity and contains one record per reporting month.

Logic
--------------------------------------------------------------------------------------------------------------
1. Load raw consumer price index data from DESTATIS source table.
2. Filter records to the official consumer price index
   ('Verbraucherpreisindex').
3. Convert textual month attributes from the source into integer month values
   using the central month mapping table.
4. Convert year and value fields into numeric data types.
5. Divide source values by 10 according to DESTATIS delivery specification.
6. Add technical metadata fields for source, statistic identifier and load
   timestamp.
7. Load the transformed dataset into the staging table
   DB_DWH.STG.CONSUMER_PRICE_INDEX.

Result
--------------------------------------------------------------------------------------------------------------
One record per reporting month containing the official German Consumer Price Index (CPI) published by DESTATIS.
- [YEAR]             Reporting year
- [MONTH]            Reporting month (1-12)
- [VALUE]            Official consumer price index value
- [STAMP_STATISTIC]  DESTATIS official statistic code
- [STAMP_SOURCE]     Source system identifier
- [STAMP_TIME]       Technical load timestamp

Pipelines
--------------------------------------------------------------------------------------------------------------
- Currently no dedicated orchestration pipeline assigned.

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.RAW.DATA_DESTATIS_CONSUMER_PRICE_INDEX
- DB_DWH.RAW.MAP_DWH_MONTH

Target Objects:
- DB_DWH.STG.CONSUMER_PRICE_INDEX

Versioning
--------------------------------------------------------------------------------------------------------------
- 24.06.2026 | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS STG.RUN_CONSUMER_PRICE_INDEX;
GO

CREATE PROCEDURE STG.RUN_CONSUMER_PRICE_INDEX (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN
--Table definition
--------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS DB_DWH.STG.CONSUMER_PRICE_INDEX

CREATE TABLE DB_DWH.STG.CONSUMER_PRICE_INDEX (
	 [YEAR] 			INT
	,[MONTH]			INT
	,[VALUE]			DECIMAL(18,4)
	,[STAMP_STATISTIC]	NVARCHAR(100)
	,[STAMP_SOURCE]		NVARCHAR(100)
	,[STAMP_TIME]		DATETIME
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
--Table:	#SRC_DATA_CPI
--Purpose:	Loading the main raw data for transforming into staging layer.
--Logic:	Raw extraction without business transformation.
DROP TABLE IF EXISTS #SRC_DATA_CPI
	SELECT
		 SRC.[time]		-- Year
		,SRC.[value]	-- Consumer price index value for specific month and year
		,SRC.[statistics_code]		-- Official identifier code for this specific destatis statistic
		,SRC.[value_variable_label]	-- Filter element for identification of the actual consumer price index
		,SRC.[_1_variable_attribute_code]	-- Nvarchar value for months from the raw data
	INTO #SRC_DATA_CPI
	FROM DB_DWH.RAW.DATA_DESTATIS_CONSUMER_PRICE_INDEX AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	Resultset
--Purpose:	Final transformation for transforming the raw data into staging layer.
--Logic:   	- Convert year to integer.
--  		- Map month name to month number.
--  		- Convert CPI value to decimal and divide by 10.
--  		- Filter to official consumer price index records.
--  		- Exclude non-numeric values.
--  		- Add technical metadata fields.	
INSERT INTO DB_DWH.STG.CONSUMER_PRICE_INDEX

SELECT
	 TRY_CAST(SRC.[time] as INT) 				AS [YEAR]
	,#SRC_MAP_MONTH.[MONTH]
	,TRY_CAST(SRC.[value] AS DECIMAL(18,4))/10 	AS [VALUE] -- DESTATIS delivers CPI values without decimal separator (e.g. 1234 instead of 123.4). Division by 10 restores the original scale
	,TRY_CAST(SRC.[statistics_code] AS NVARCHAR(100)) AS [STAMP_STATISTIC]
	,'DESTATIS' 								AS [STAMP_SOURCE]
	,GETDATE() 									AS [STAMP_TIME]
FROM #SRC_DATA_CPI AS SRC
LEFT JOIN #SRC_MAP_MONTH ON #SRC_MAP_MONTH.[MONTH_NAME] = SRC.[_1_variable_attribute_code]
WHERE	SRC.[value_variable_label] = 'Verbraucherpreisindex' -- Source dataset contains multiple indicator types.  Restrict loading to the official consumer price index
AND		TRY_CAST(SRC.[value] AS DECIMAL(18,4)) IS NOT NULL -- Exclude non-populated periods and placeholder records

END;