let
     SqlServer = Sql.Databases(".\MSSQLSERVER01")               // Select the server ip for the desired sql server
    ,Database = SqlServer{[Name="DB_DWH"]}[Data]                // Select the database
    ,Dataset = Database{[Schema="CORE",Item="DIM_ROAD_ENVIRONMENT"]}[Data]     // Select the dataset to download
    
in
    Dataset