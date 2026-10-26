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
 [COLUMN]      <DATA_TYPE>             -- <DESCRIPTION>

Pipelines
--------------------------------------------------------------------------------------------------------------
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
/*DROP TABLE IF EXISTS DB_DWH.STG.NRW_MUNICIPALITIES_FINANCE

CREATE TABLE DB_DWH.STG.NRW_MUNICIPALITIES_FINANCE (
	 [VARIABLE] 		INT
)*/

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
--Table:	#SRC_DAT_EXP
--Purpose:	
--Logic:	
DROP TABLE IF EXISTS #SRC_DAT_EXP
	SELECT
		 TRY_CAST(SRC.[time] AS INT)									AS [YEAR]
		,TRY_CAST(SRC.[1_variable_attribute_code] AS INT)				AS [MUNICIPALITY_KEY]
		,TRY_CAST(SRC.[1_variable_attribute_label] AS NVARCHAR(MAX))	AS [MUNICIPALITY]
		,TRY_CAST(SRC.[2_variable_attribute_code] AS NVARCHAR(MAX))		AS [ACCOUNT_KEY]
		,TRY_CAST(SRC.[2_variable_attribute_label] AS NVARCHAR(MAX))	AS [ACCOUNT]
		,TRY_CAST(SRC.[3_variable_attribute_code] AS NVARCHAR(MAX)) 	AS [PRODUCT_GROUP_KEY]
		,TRY_CAST(SRC.[3_variable_attribute_label] AS NVARCHAR(MAX))	AS [PRODUCT_GROUP]
		,ISNULL(TRY_CAST(SRC.[value] AS MONEY),0) 						AS [VALUE]
	INTO #SRC_DAT_EXP
	FROM DB_DWH.RAW.DATA_LDBNRW_MUNICIPALITIES_FINANCE_EXPENDITURES AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:	
--Purpose:	
--Logic:   	- 
--         	- 

	
/*INSERT INTO DB_DWH.STG.TABLE*/

SELECT
	*
FROM #SRC_DAT_EXP

END;