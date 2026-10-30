
import pandas
from config.ldbnrw_data import TABLE_CONFIG
from config.ldbnrw_municipalities_exp_accounts import ACCOUNT_LIST
from config.ldbnrw_munic_fin_exp_municipalities import MUNICIPALITY_LIST
from src.extractors.ldbnrw_extractor import extract
from src.utilities import logging, exceptions
from config import paths

def run() -> dict[str, pandas.DataFrame]:
    """ 
    """
    logger = logging.get_logger(__name__)

    results = {}
    all_dataframes = []

    config = open(paths.dir_config / "config_ldbnrw_municipalities.json")

    parameters_general = config["parameters_general"]
    parameters_specific = config["parameters_expenditures"]
    
    year_start = parameters_general["year_start"]
    year_end = parameters_general["year_end"]

    years = list(range(year_start, year_end +1))   
    
    for year in years:
        for account in ACCOUNT_LIST:

            logger.info('Starting data extraction for table ID: %s, year: %s, language: %s, regionalkey: %s, classifyingkey1: %s, classifyingkey2: %s', parameters_specific["table_id"], year, parameters_general["language_data"], parameters_general["regionalkey"], parameters_general["classifyingkey1"], account)
            try:
                data_frame = extract.run(
                     table_id           = parameters_specific["table_id"]
                    ,year_start         = year
                    ,year_end           = year
                    ,regionalvar        = parameters_general["regionalvariable"]
                    ,regionalkey        = parameters_general["regionalkey"]
                    ,classifyingvar1    = parameters_general["classifyingvariable1"]
                    ,classifyingkey1    = parameters_general["classifyingkey1"]
                    ,classifyingvar2    = parameters_specific["classifyingvariable2"]
                    ,classifyingkey2    = account
                    ,language_data      = parameters_general["language_data"]
                    
                )
    
                logger.info('Data extraction completed for table ID: %s', parameters_specific["table_id"])

                all_dataframes.append(data_frame)

            except exceptions.DataDownloadError as e:
                logger.error('Data extraction failed for table ID: %s with error: %s', parameters_specific["table_id"], e)
                raise

    if all_dataframes:
        logger.info('Concatenating %d DataFrames into a single large DataFrame.', len(all_dataframes))
        final_dataframe = pandas.concat(all_dataframes, ignore_index=True)
    else:
        logger.warning('No data was extracted. Returning empty DataFrame.')
        final_dataframe = pandas.DataFrame()

    try:
        results[parameters_specific["table_id"]] = {
             "data_frame"       : final_dataframe
            ,"table_name_db"    : parameters_specific["table_name_db"]
        }
        logger.info('Data for table ID: %s stored in results dictionary', parameters_specific["table_id"])
    except Exception as e:
        logger.error('Failed to store data for table ID: %s in results dictionary: %s', parameters_specific["table_id"], e)
        raise exceptions.DataStorageError(f"Failed to store data for table ID: {parameters_specific["table_id"]} in results dictionary: {e}") 
        
    return results