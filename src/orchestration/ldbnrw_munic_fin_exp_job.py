
import pandas
from config.ldbnrw_data import TABLE_CONFIG
from config.ldbnrw_municipalities_exp_accounts import ACCOUNT_LIST
from config.ldbnrw_munic_fin_exp_municipalities import MUNICIPALITY_LIST
from src.extractors.ldbnrw_extractor import extract
from src.utilities import logging, exceptions

def run() -> dict[str, pandas.DataFrame]:
    """ 
    """
    logger = logging.get_logger(__name__)

    results = {}

    all_dataframes = []

    table_name_db = 'DATA_LDBNRW_MUNICIPALITIES_FINANCE_EXPENDITURES'
    table_id = '79118-12i'
    regionalvar = 'GEMGFR'
    classifyingvar1 = "PRODGR"
    classifyingkey1 =  "*"
    classifyingvar2 = 'KONTO5'
    year_start = 2009
    year_end = 2021
    language_data = 'de'
    
    for municipality in MUNICIPALITY_LIST:
        logger.info('Rerieving configuration for table ID and municipality: %s', municipality)

        regionalkey_m = municipality

        for account in ACCOUNT_LIST:
            logger.info('Rerieving configuration for table ID and account: %s', account)

            classifyingkey2 = account

            logger.info('Starting data extraction for table ID: %s, years: %d-%d, language: %s, regionalkey: %s, classifyingkey1: %s, classifyingkey2: %s', table_id, year_start, year_end, language_data, regionalkey_m, classifyingkey1, classifyingkey2)

            try:
                data_frame = extract.run(
                     table_id

                    ,year_start
                    ,year_end
                    
                    ,regionalvar
                    ,regionalkey_m

                    ,classifyingvar1
                    ,classifyingkey1
                    ,classifyingvar2
                    ,classifyingkey2

                    ,language_data ='de'
                    
                )
    
                logger.info('Data extraction completed for table ID: %s', table_id)

                all_dataframes.append(data_frame)

            except exceptions.DataDownloadError as e:
                logger.error('Data extraction failed for table ID: %s with error: %s', table_id, e)
                raise

    if all_dataframes:
        logger.info('Concatenating %d DataFrames into a single large DataFrame.', len(all_dataframes))
        final_dataframe = pandas.concat(all_dataframes, ignore_index=True)
    else:
        logger.warning('No data was extracted. Returning empty DataFrame.')
        final_dataframe = pandas.DataFrame()

    try:
        results[table_id] = {
             "data_frame" : final_dataframe
            ,"table_name_db" : table_name_db
        }
        logger.info('Data for table ID: %s stored in results dictionary', table_id)
    except Exception as e:
        logger.error('Failed to store data for table ID: %s in results dictionary: %s', table_id, e)
        raise exceptions.DataStorageError(f"Failed to store data for table ID: {table_id} in results dictionary: {e}") 
        
    return results