/*===========================================================================================================
			HEADER
=============================================================================================================*/
/*
Basic documentary
--------------------------------------------------------------------------------------------------------------
Name:			DB_DWH.CORE.RUN_FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
Object:			Procedure
Developer:		Sascha Klein
Creation Date:	05.07.2026
Topic:			Traffic Accidents
Sources:		DESTATIS

Business Definition
--------------------------------------------------------------------------------------------------------------
Provides the central fact table containing the number of traffic accident
participants.

The procedure transforms the staged accident participant dataset into the
dimensional data warehouse model by replacing all descriptive attributes with
their corresponding surrogate keys from the dimension tables.

The resulting fact table stores one measure per unique combination of reporting
period, demographic characteristics, accident category, road environment and
traffic participation category.

Business Rules
--------------------------------------------------------------------------------------------------------------
- All participants of a traffic accident are loaded.
- All descriptive attributes are replaced by surrogate keys from the corresponding dimension tables.
- One fact record exists per unique combination of age, road environment,
  traffic participation, accident category, sex and reporting period.
- Existing fact records are preserved.
- Only previously unknown fact records are inserted.
- Technical metadata from both staging and fact loading is stored.

Logic
--------------------------------------------------------------------------------------------------------------
1. Load all required dimension tables.
2. Load the staged party-of-fault participant dataset.
3. Replace descriptive attributes by surrogate keys using the dimension tables.
4. Preserve the reporting period and participant measure.
5. Exclude fact records already existing in the fact table.
6. Add technical metadata.
7. Insert the transformed records into
   DB_DWH.CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.

Result
--------------------------------------------------------------------------------------------------------------
Fact table containing the number of traffic accident participants.
 [FACT_ID]                         INT             Surrogate fact identifier
,[AGE_ID]                          INT             Foreign key to DIM_AGE
,[ROAD_ENVIRONMENT_ID]             INT             Foreign key to DIM_ROAD_ENVIRONMENT
,[TRAFFIC_PARTICIPATION_ID]        INT             Foreign key to DIM_TRAFFIC_PARTICIPATION
,[SEX_ID]                          INT             Foreign key to DIM_SEX
,[TRAFFIC_ACCIDENT_CATEGORY_ID]    INT             Foreign key to DIM_TRAFFIC_ACCIDENT_CATEGORY
,[YEAR]                            INT             Reporting year
,[MONTH]                           INT             Reporting month
,[PARTICIPANTS]                    INT             Number of participants in a traffic accident
,[STAMP_SOURCE]                    NVARCHAR(100)   Technical source identifier
,[STAMP_SOURCE_STG]                NVARCHAR(100)   Source identifier inherited from staging
,[STAMP_TIME]                      DATETIME        Fact load timestamp
,[STAMP_TIME_STG]                  DATETIME        Original staging load timestamp

Pipelines
--------------------------------------------------------------------------------------------------------------
- Currently no dedicated orchestration pipeline assigned.

Dependencies
--------------------------------------------------------------------------------------------------------------
Source Objects:
- DB_DWH.STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
- DB_DWH.CORE.DIM_AGE
- DB_DWH.CORE.DIM_ROAD_ENVIRONMENT
- DB_DWH.CORE.DIM_TRAFFIC_PARTICIPATION
- DB_DWH.CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY

Target Objects:
- DB_DWH.CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS

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

DROP PROCEDURE IF EXISTS CORE.RUN_FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS;
GO

CREATE PROCEDURE CORE.RUN_FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS (
	@DEFAULT NVARCHAR(100)
)
AS
BEGIN
--Table definition
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('DB_DWH.CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS') IS NULL
BEGIN

CREATE TABLE DB_DWH.CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS (
	 [FACT_ID]				        INT				IDENTITY(1,1) NOT NULL PRIMARY KEY
	,[AGE_ID]				        INT				-- Age group identifier
	,[ROAD_ENVIRONMENT_ID]			INT				-- Road Environment identifier
	,[TRAFFIC_PARTICIPATION_ID]		INT     		-- Traffic Participation identifier
    ,[SEX_ID]                       INT             -- Standardized sex identifier
    ,[TRAFFIC_ACCIDENT_CATEGORY_ID] INT             -- Traffic accident category identifier
    ,[YEAR]                         INT             -- Reporting year
    ,[MONTH]                        INT             -- Reporting month
    ,[PARTICIPANTS]                 INT             -- 
	,[STAMP_SOURCE]			        NVARCHAR(100)	-- Source definition, here: STAGING
	,[STAMP_SOURCE_STG]		        NVARCHAR(100)	-- Source definition of staged data, here: 
	,[STAMP_TIME]			        DATETIME		-- Loading time
	,[STAMP_TIME_STG]		        DATETIME		-- Loading time of the staged data
    ,CONSTRAINT UNIQUE_FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS UNIQUE
    (
         [AGE_ID]
    	,[ROAD_ENVIRONMENT_ID]
        ,[TRAFFIC_PARTICIPATION_ID]
        ,[SEX_ID]
        ,[TRAFFIC_ACCIDENT_CATEGORY_ID]
        ,[YEAR]
        ,[MONTH]
    )
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
--Dimension sources
--------------------------------------------------------------------------------------------------------------
--Table:	#SRC_DIM_AGE
--Purpose:	Replacing nvarchar age span names of the data source with surrogate keys.
--Logic:	Raw loading of dimension table.
DROP TABLE IF EXISTS #SRC_DIM_AGE
	SELECT
         SRC.[AGE_ID]   -- Surrogate key
        ,SRC.[AGE_NAME] -- Nvarchar names for age spans
	INTO #SRC_DIM_AGE
	FROM CORE.DIM_AGE AS SRC
CREATE CLUSTERED INDEX IX_SRC_DIM_AGE ON #SRC_DIM_AGE([AGE_ID])

--Table:	#SRC_DIM_ROAD_ENVIRONMENT
--Purpose:	Replacing nvarchar road environment names of the data source with surrogate keys.
--Logic:	Raw loading of dimension table.
DROP TABLE IF EXISTS #SRC_DIM_ROAD_ENVIRONMENT
	SELECT
         SRC.[ROAD_ENVIRONMENT_ID]   -- Surrogate key
        ,SRC.[ROAD_ENVIRONMENT_NAME] -- Nvarchar names for road environments
	INTO #SRC_DIM_ROAD_ENVIRONMENT
	FROM CORE.DIM_ROAD_ENVIRONMENT AS SRC
CREATE CLUSTERED INDEX IX_SRC_DIM_ROAD_ENVIRONMENT ON #SRC_DIM_ROAD_ENVIRONMENT([ROAD_ENVIRONMENT_ID])

--Table:	#SRC_DIM_PARTICIPATION
--Purpose:	Replacing nvarchar traffic participation names of the data source with surrogate keys.
--Logic:	Raw loading of dimension table.
DROP TABLE IF EXISTS #SRC_DIM_PARTICIPATION
	SELECT
         SRC.[TRAFFIC_PARTICIPATION_ID]   -- Surrogate key
        ,SRC.[TRAFFIC_PARTICIPATION_NAME] -- Nvarchar names for traffic participation categories
	INTO #SRC_DIM_PARTICIPATION
	FROM CORE.DIM_TRAFFIC_PARTICIPATION AS SRC
CREATE CLUSTERED INDEX IX_SRC_DIM_PARTICIPATION ON #SRC_DIM_PARTICIPATION([TRAFFIC_PARTICIPATION_ID])

--Table:	#SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY
--Purpose:	Replacing nvarchar traffic accident categroy names of the data source with surrogate keys.
--Logic:	Raw loading of dimension table.
DROP TABLE IF EXISTS #SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY
	SELECT
         SRC.[TRAFFIC_ACCIDENT_CATEGORY_ID]   -- Surrogate key
        ,SRC.[TRAFFIC_ACCIDENT_CATEGORY_NAME] -- Nvarchar names for traffic accident categories
	INTO #SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY
	FROM CORE.DIM_TRAFFIC_ACCIDENT_CATEGORY AS SRC
CREATE CLUSTERED INDEX IX_SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY ON #SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY([TRAFFIC_ACCIDENT_CATEGORY_ID])


--Data sources
--------------------------------------------------------------------------------------------------------------
--Table:    #SRC_DAT_TR_ACC_PART_CAT_LOC_PARTICIPANTS
--Purpose:  Load the staged traffic accident participant dataset containing
--          parties of fault.
--Logic:    Raw extraction of the staged dataset without any business
--          transformation. The descriptive attributes are preserved and will
--          be replaced by surrogate keys during the transformation step.
DROP TABLE IF EXISTS #SRC_DAT_TR_ACC_PART_CAT_LOC_PARTICIPANTS
	SELECT
		 SRC.[AGE_CATEGORY]
        ,SRC.[ACCIDENT_LOCATION]
        ,SRC.[ACCIDENT_PARTICIPATION_OPERATOR]
        ,SRC.[SEX_ID]
        ,SRC.[ACCIDENT_CATEGORY]
        ,SRC.[YEAR]
        ,SRC.[MONTH]
        ,SRC.[PARTICIPANTS]
        ,SRC.[STAMP_SOURCE]
        ,SRC.[STAMP_TIME]
	INTO #SRC_DAT_TR_ACC_PART_CAT_LOC_PARTICIPANTS
	FROM STG.TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS AS SRC

/*===========================================================================================================
			TRANSFORMATIONS
=============================================================================================================*/
--Table:    Resultset
--Purpose:  Transform staged party-of-fault participant records into the dimensional fact model.
--Logic:    - Replace descriptive attributes by surrogate keys from the dimension tables.
--          - Preserve measures and reporting period.
--          - Insert only previously unknown fact records.
--          - Add technical metadata.

	
INSERT INTO DB_DWH.CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS (
     [AGE_ID]				        
	,[ROAD_ENVIRONMENT_ID]			
	,[TRAFFIC_PARTICIPATION_ID]		
    ,[SEX_ID]                       
    ,[TRAFFIC_ACCIDENT_CATEGORY_ID]
    ,[YEAR]                         
    ,[MONTH]    
    ,[PARTICIPANTS]                    
	,[STAMP_SOURCE]			        
	,[STAMP_SOURCE_STG]		        
	,[STAMP_TIME]			        
	,[STAMP_TIME_STG]		        
)

SELECT
     #SRC_DIM_AGE.[AGE_ID]
    ,#SRC_DIM_ROAD_ENVIRONMENT.[ROAD_ENVIRONMENT_ID]
    ,#SRC_DIM_PARTICIPATION.[TRAFFIC_PARTICIPATION_ID]
    ,SRC.[SEX_ID]
    ,#SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY.[TRAFFIC_ACCIDENT_CATEGORY_ID]
    ,SRC.[YEAR]
    ,SRC.[MONTH]
    ,SRC.[PARTICIPANTS]
    ,'STAGING'              AS [STAMP_SOURCE]
    ,SRC.[STAMP_SOURCE]     AS [STAMP_SOURCE_STG]
    ,GETDATE()              AS [STAMP_TIME]
    ,SRC.[STAMP_TIME]       AS [STAMP_TIME_STG]

FROM #SRC_DAT_TR_ACC_PART_CAT_LOC_PARTICIPANTS AS SRC
LEFT JOIN #SRC_DIM_AGE ON #SRC_DIM_AGE.[AGE_NAME] = SRC.[AGE_CATEGORY]
LEFT JOIN #SRC_DIM_ROAD_ENVIRONMENT ON #SRC_DIM_ROAD_ENVIRONMENT.[ROAD_ENVIRONMENT_NAME] = SRC.[ACCIDENT_LOCATION]
LEFT JOIN #SRC_DIM_PARTICIPATION ON #SRC_DIM_PARTICIPATION.[TRAFFIC_PARTICIPATION_NAME] = SRC.[ACCIDENT_PARTICIPATION_OPERATOR]
LEFT JOIN #SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY ON #SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY.[TRAFFIC_ACCIDENT_CATEGORY_NAME] = SRC.[ACCIDENT_CATEGORY]

WHERE NOT EXISTS (
	SELECT 1
	FROM DB_DWH.CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS
    WHERE   #SRC_DIM_AGE.[AGE_ID]                                               
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[AGE_ID]
    
    AND     #SRC_DIM_ROAD_ENVIRONMENT.[ROAD_ENVIRONMENT_ID]                     
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[ROAD_ENVIRONMENT_ID]
    
    AND     #SRC_DIM_PARTICIPATION.[TRAFFIC_PARTICIPATION_ID]                   
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[TRAFFIC_PARTICIPATION_ID]
    
    AND     SRC.[SEX_ID]                                                        
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[SEX_ID]
    
    AND     #SRC_DIM_TRAFFIC_ACCIDENT_CATEGORY.[TRAFFIC_ACCIDENT_CATEGORY_ID]   
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[TRAFFIC_ACCIDENT_CATEGORY_ID]
    
    AND     SRC.[YEAR]                                                          
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[YEAR]
    
    AND     SRC.[MONTH]                                                         
            = CORE.FACT_TRAFFIC_ACCIDENTS_PARTICIPATION_CATEGORY_LOCATION_PARTICIPANTS.[MONTH]
)

END;