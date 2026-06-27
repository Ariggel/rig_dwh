import pandas
from sqlalchemy.engine import Engine
from src.utilities import logging, exceptions


def load_dataframe(data_frame: pandas.DataFrame,schema_name: str,table_name: str, engine : Engine  ) -> None:
    """
    Loads a pandas DataFrame into a SQL Server database table.
    
    Args:
        data_frame (pandas.DataFrame): The DataFrame to be loaded into the database.    
        schema_name (str): The name of the schema in the database where the table resides.
        table_name (str): The name of the table in the database where the DataFrame will be loaded.
        engine (Engine): The SQL Server engine connection.

    Raises:
        exceptions.DataStorageError:
            If there is an error while loading the DataFrame into the database.

    Load Behaviour:
        - If the table already exists, it will be replaced with the new data.
        - The DataFrame's index will not be written to the database.
    
    Notes:
        - The function performs no business transformation.
        - Table structure is inferred from pandas dtypes.
    """

    logger = logging.get_logger(__name__)

    if data_frame.empty:
        logger.warning("The DataFrame is empty. No data will be loaded into %s.%s", schema_name, table_name)
        return

    try:
        

        logger.info("Loading %s rows into %s.%s", len(data_frame), schema_name, table_name)

        data_frame.to_sql(
             name=table_name
            ,schema=schema_name
            ,con=engine
            ,if_exists="replace"
            ,index=False
        )

        logger.info("Loaded %s rows into %s.%s",len(data_frame),schema_name,table_name)

    except Exception as e:
        logger.critical(
            "Failed loading data into %s.%s: %s",schema_name,table_name,e)
        raise exceptions.DataStorageError(f"Failed loading data into {schema_name}.{table_name}: {e}")