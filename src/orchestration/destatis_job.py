
import pandas
from src.extractors import destatis_extractor
from config.destatis_data import TABLE_CONFIG
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
        year_start = config.get("year_start", 2020)
        year_end = config.get("year_end", 2025)
        language_data = config.get("language_data", "de")
        table_name_db = config.get("table_name_db")

        logger.info('Starting data extraction for table ID: %s, years: %d-%d, language: %s', table_id, year_start, year_end, language_data)
        
        try:
            data_frame = destatis_extractor.extract(table_id, year_start, year_end, language_data)
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