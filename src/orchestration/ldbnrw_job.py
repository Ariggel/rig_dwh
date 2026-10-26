
import pandas
from config.ldbnrw_data import TABLE_CONFIG
from src.extractors import ldbnrw_extractor
from src.utilities import logging, exceptions

def run() -> dict[str, pandas.DataFrame]:
    """ 
    Orchestrates the extraction of data from the Genesis API for a specified table ID.

    This function retrieves the configuration for the specified table ID from a predefined
    configuration dictionary. It then calls the `extract` function from the `destatis_extractor`
    module to download and parse the data, returning it as a pandas DataFrame.

    Args:
        table_id (str):
            Identifier of the table to be retrieved from the API.
    
    Returns:
        dict[str, pandas.DataFrame]:
            Dictionary mapping table IDs to their corresponding DataFrames.
    
    Raises:
        KeyError:
            If the specified table ID is not found in the configuration dictionary.
        
        exceptions.DataDownloadError:
            If there is an error during the data extraction process.
    """
    logger = logging.get_logger(__name__)

    results = {}
    for table_id, config in TABLE_CONFIG.items():
        logger.info('Retrieving configuration for table ID: %s', table_id)

        table_name_db = config.get("table_name_db")

        year_start = config.get("year_start", 2020)
        year_end = config.get("year_end", 2025)

        regionalvar = config.get("regionalvar", None)
        regionalkey = config.get("regionalkey", None)

        classifyingvar1 = config.get("classifyingvar1", None)
        classifyingkey1 = config.get("classifyingkey1", None)
        classifyingvar2 = config.get("classifyingvar2", None)
        classifyingkey2 = config.get("classifyingkey2", None)
        classifyingvar3 = config.get("classifyingvar3", None)
        classifyingkey3 = config.get("classifyingkey3", None)
        
        language_data = config.get("language_data", "de")


        logger.info('Starting data extraction for table ID: %s, years: %d-%d, language: %s', table_id, year_start, year_end, language_data)
        
        try:
            data_frame = ldbnrw_extractor.extract(
                 table_id
                
                ,year_start
                ,year_end

                ,regionalvar
                ,regionalkey

                ,classifyingvar1
                ,classifyingkey1
                ,classifyingvar2
                ,classifyingkey2
                ,classifyingvar3
                ,classifyingkey3
                
                ,language_data
            )
            logger.info('Data extraction completed for table ID: %s', table_id)
        except exceptions.DataDownloadError as e:
            logger.error('Data extraction failed for table ID: %s with error: %s', table_id, e)
            raise

        try:
            results[table_id] = {
                 "data_frame" : data_frame
                ,"table_name_db" : table_name_db
            }
            logger.info('Data for table ID: %s stored in results dictionary', table_id)
        except Exception as e:
            logger.error('Failed to store data for table ID: %s in results dictionary: %s', table_id, e)
            raise exceptions.DataStorageError(f"Failed to store data for table ID: {table_id} in results dictionary: {e}") 
        
    return results