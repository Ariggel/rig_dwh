/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.STG.RUN_NRW_MUNICIPALITIES_FINANCE
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	28.10.2026
Topic:			Financial data of municipalities in NRW
Sources:		LDBNRW

Business Definition
--------------------------------------------------------------------------------------------------------------
Data of the financial situation of municipalities in NRW, including expenditures and income for given years.

Business Rules
--------------------------------------------------------------------------------------------------------------
- The data is sourced from the LDBNRW database and includes both expenditures and income for municipalities in NRW.
- The data is transformed to fit the staging table structure and data types.

Logic
--------------------------------------------------------------------------------------------------------------
1. Truncate the staging table DB_DWH.STG.NRW_MUNICIPALITIES_FINANCE to remove any existing data.
2. Create temporary tables #SRC_DAT_EXP and #SRC_DAT_INC to hold the transformed data
   from the source tables DB_DWH.RAW.DATA_LDBNRW_MUNICIPALITIES_FINANCE_EXPENDITURES and DB_DWH.RAW.DATA_LDBNRW_MUNICIPALITIES_FINANCE_INCOME respectively.
3. Transform the source data to match the staging table structure and data types.
4. Union the transformed expenditures and income data into a single temporary table #FINANCE_TABLE_UNION.
5. Insert the data from #FINANCE_TABLE_UNION into the staging table DB_DWH.STG.NRW_MANUCIPALITIES_FINANCE.

Result
--------------------------------------------------------------------------------------------------------------
[YEAR]                 INT 				Year of the financial data
[MANUCIPALITY_KEY]     INT 				Key of the municipality
[MANUCIPALITY]         NVARCHAR(MAX) 	Name of the municipality
[ACCOUNT_KEY]          NVARCHAR(MAX) 	Key of the account
[ACCOUNT]              NVARCHAR(MAX) 	Name of the account
[PRODUCT_GROUP_KEY]    NVARCHAR(MAX) 	Key of the product group
[PRODUCT_GROUP]        NVARCHAR(MAX) 	Name of the product group
[VALUE]                MONEY 			Value of the financial data (expenditures or income)

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_CREATE_TABLE_MANUCIPALITIES
- PIPELINE_NRW_MUNICIPALITES

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.RAW.DATA_LDBNRW_MUNICIPALITIES_FINANCE

Target Objects:
- DB_DWH.STG.NRW_MUNICIPALITIES_FINANCE

Versioning
--------------------------------------------------------------------------------------------------------------
- 26.10.2026 | Sascha Klein | v 1.0.0
--- Initial version

*/
/*===========================================================================================================
			DEFINITIONS
=============================================================================================================*/
--Procedure definition
--------------------------------------------------------------------------------------------------------------
USE DB_DWH;

DROP PROCEDURE IF EXISTS STG.RUN_NRW_MUNICIPALITIES_FINANCE;
GO

CREATE PROCEDURE STG.RUN_NRW_MUNICIPALITIES_FINANCE (
	@DEFAULT NVARCHAR(100) = NULL
)
AS
BEGIN
--Table definition
--------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE DB_DWH.STG.NRW_MUNICIPALITIES_FINANCE

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
-- No mapping souces needed.

--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:	#SRC_DAT_EXP
--Purpose:	Data source for the expenditures of the municipalities in NRW for given years.
--Logic:	Transform the source data to the staging table structure and data types.
	DROP TABLE IF EXISTS #SRC_DAT_EXP
		SELECT
			 TRY_CAST(SRC.[time] AS INT)									AS [YEAR]				--Year of the expenditures
			,TRY_CAST(SRC.[1_variable_attribute_code] AS INT)				AS [MUNICIPALITY_KEY]	--Key of the municipality
			,TRY_CAST(SRC.[1_variable_attribute_label] AS NVARCHAR(MAX))	AS [MUNICIPALITY]		--Name of the municipality
			,TRY_CAST(SRC.[2_variable_attribute_code] AS NVARCHAR(MAX))		AS [ACCOUNT_KEY]		--Key of the account
			,TRY_CAST(SRC.[2_variable_attribute_label] AS NVARCHAR(MAX))	AS [ACCOUNT]			--Name of the account
			,TRY_CAST(SRC.[3_variable_attribute_code] AS NVARCHAR(MAX)) 	AS [PRODUCT_GROUP_KEY]	--Key of the product group
			,TRY_CAST(SRC.[3_variable_attribute_label] AS NVARCHAR(MAX))	AS [PRODUCT_GROUP]		--Name of the product group
			,ISNULL(TRY_CAST(SRC.[value] AS MONEY),0) 						AS [VALUE]				--Value of the expenditures
		INTO #SRC_DAT_EXP
		FROM DB_DWH.RAW.DATA_LDBNRW_MUNICIPALITIES_FINANCE_EXPENDITURES AS SRC

--Table:	#SRC_DAT_INC
--Purpose:	Data source for the income of the municipalities in NRW for given years.
--Logic:	Transform the source data to the staging table structure and data types.
	DROP TABLE IF EXISTS #SRC_DAT_INC
		SELECT
			 TRY_CAST(SRC.[time] AS INT)									AS [YEAR]				--Year of the income
			,TRY_CAST(SRC.[1_variable_attribute_code] AS INT)				AS [MUNICIPALITY_KEY]	--Key of the municipality
			,TRY_CAST(SRC.[1_variable_attribute_label] AS NVARCHAR(MAX))	AS [MUNICIPALITY]		--Name of the municipality
			,TRY_CAST(SRC.[2_variable_attribute_code] AS NVARCHAR(MAX))		AS [ACCOUNT_KEY]		--Key of the account
			,TRY_CAST(SRC.[2_variable_attribute_label] AS NVARCHAR(MAX))	AS [ACCOUNT]			--Name of the account
			,TRY_CAST(SRC.[3_variable_attribute_code] AS NVARCHAR(MAX)) 	AS [PRODUCT_GROUP_KEY]	--Key of the product group
			,TRY_CAST(SRC.[3_variable_attribute_label] AS NVARCHAR(MAX))	AS [PRODUCT_GROUP]		--Name of the product group
			,-ISNULL(TRY_CAST(SRC.[value] AS MONEY),0) 						AS [VALUE]				--Value of the income
		INTO #SRC_DAT_INC
		FROM DB_DWH.RAW.DATA_LDBNRW_MUNICIPALITIES_FINANCE_INCOME AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	#FINANCE_TABLE_UNION
--Purpose:	Union of the expenditures and income tables
	DROP TABLE IF EXISTS #FINANCE_TABLE_UNION
		SELECT
			*
		INTO #FINANCE_TABLE_UNION
		FROM #SRC_DAT_EXP
		UNION ALL (SELECT * FROM #SRC_DAT_INC)
	
	INSERT INTO DB_DWH.STG.NRW_MUNICIPALITIES_FINANCE
	SELECT
		 DATA_FINANCE.[YEAR]
		,DATA_FINANCE.[MUNICIPALITY_KEY]
		,DATA_FINANCE.[MUNICIPALITY]
		,DATA_FINANCE.[ACCOUNT_KEY]
		,DATA_FINANCE.[ACCOUNT]
		,DATA_FINANCE.[PRODUCT_GROUP_KEY]
		,DATA_FINANCE.[PRODUCT_GROUP]
		,DATA_FINANCE.[VALUE]
	FROM #FINANCE_TABLE_UNION AS DATA_FINANCE

END;