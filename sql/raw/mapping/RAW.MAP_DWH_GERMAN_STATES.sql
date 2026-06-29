/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.RAW.RUN_MAP_GERMAN_STATES
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	29.06.2026
Topic:			Standardized mapping of DESTATIS state attributes to numeric state values
Sources:		Static mapping definition

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides a centralized reference table for mapping German federal states
(Bundesländer) to standardized numeric identifiers.

The mapping is used throughout the Data Warehouse to ensure consistent
representation of state attributes across STAGING, CORE and reporting layers,
independent of source system formatting.

Business Rules
--------------------------------------------------------------------------------------------------------------
- Each German federal state must have exactly one unique identifier.
- State identifiers are immutable once assigned.
- The mapping serves as the central state reference across the entire Data Warehouse.

Logic
--------------------------------------------------------------------------------------------------------------
1. Create the mapping table if it does not already exist.
2. Insert one record for each German federal state.
3. Prevent duplicate entries by checking existing state names.
4. Enrich each record with technical metadata including source identifier and
   load timestamp.

Result
--------------------------------------------------------------------------------------------------------------
Static reference table containing one record per German federal state.

 [STATE_ID]      INT             -- Standardized numeric identifier
,[STATE_NAME]    NVARCHAR(100)   -- Official German federal state name
,[STAMP_SOURCE]  NVARCHAR(100)   -- Technical source identifier
,[STAMP_TIME]    DATETIME        -- Technical load timestamp

Pipelines
--------------------------------------------------------------------------------------------------------------
- PIPELINE_INTERNAL_MAPPING

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- No source objects assigned (static mapping definition).

Target Objects:
- DB_DWH.RAW.MAP_GERMAN_STATES

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

DROP PROCEDURE IF EXISTS RAW.RUN_MAP_DWH_GERMAN_STATES;
GO

CREATE PROCEDURE RAW.RUN_MAP_DWH_GERMAN_STATES (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN

--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.RAW.MAP_DWH_GERMAN_STATES') IS NULL
BEGIN
CREATE TABLE DB_DWH.RAW.MAP_DWH_GERMAN_STATES (
	 [STATE_ID]		INT				-- Numeric state representation (1–16)
	,[STATE_NAME] 	NVARCHAR(100) 	-- DESTATIS state attribute code (e.g. Bremen, Bayern)
	,[STAMP_SOURCE] NVARCHAR(100)	-- Source definition, here: INTERNAL_MAPPING
    ,[STAMP_TIME]	DATETIME		-- Loading time
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
-- Static mapping table. No external data sources required.

--Data sources
--------------------------------------------------------------------------------------------------------------
-- Static mapping table. No external data sources required.

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:    Resultset
--Purpose:  Populate the static German state reference table.
--Logic:    - Insert one record for each German federal state.
--          - Assign a deterministic numeric identifier.
--          - Prevent duplicate inserts.
--          - Add technical metadata for source tracking.
INSERT INTO DB_DWH.RAW.MAP_DWH_GERMAN_STATES (
	 [STATE_ID]
	,[STATE_NAME]
	,[STAMP_SOURCE]
    ,[STAMP_TIME]
)

SELECT
	 TEMP.[STATE_ID]
	,TEMP.[STATE_NAME]
	,'INTERNAL_MAPPING'	AS [STAMP_SOURCE]
    ,GETDATE()			AS [STAMP_TIME]
FROM (
VALUES 
	 (1,'Brandenburg')
    ,(2,'Hessen')
    ,(3,'Schleswig-Holstein')
    ,(4,'Mecklenburg-Vorpommern')
    ,(5,'Thüringen')
    ,(6,'Saarland')
    ,(7,'Sachsen-Anhalt')
    ,(8,'Nordrhein-Westfalen')
    ,(9,'Bremen')
    ,(10,'Rheinland-Pfalz')
    ,(11,'Hamburg')
    ,(12,'Niedersachsen')
    ,(13,'Sachsen')
    ,(14,'Berlin')
    ,(15,'Baden-Württemberg')
    ,(16,'Bayern')
) TEMP([STATE_ID],[STATE_NAME])

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.RAW.MAP_DWH_GERMAN_STATES AS SRC
	WHERE SRC.[STATE_NAME] = TEMP.[STATE_NAME]
)

END;




