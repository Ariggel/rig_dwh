import os, json, requests
from config import paths
from src.utilities import logging, exceptions


def tablefile(
         table_id   : str
        ,year_start : int
        ,year_end   : int
        ,regvar     : str = None
        ,regkey     : str = None
        ,classvar1  : str = None
        ,classkey1  : str = None
        ,classvar2  : str = None
        ,classkey2  : str = None
        ,classvar3  : str = None
        ,classkey3  : str = None
        ,job        : str = 'false'
        ,language   : str = 'de'
    ):# -> requests.Response:

    logger = logging.get_logger(__name__)
    with open(paths.dir_config / 'settings.json', 'r') as file_settings:
        config = json.load(file_settings)['api_ldbnrw']

    logger.info('Preparing URL for API tablefile request')
    url = config['base_url'] + config['suffix_tablefile']
    logger.info('API tablefile request URL: %s', url)

    logger.info('Preparing headers for API request')
    url_header = {
         'Content-Type' : config['content_type']
        ,'username' : os.getenv('LDBNRW_USER')
        ,'password' : os.getenv('LDBNRW_PASSWORD')
    }
    logger.info('API request headers prepared')

    logger.info('Preparing body for API request')
    url_body = {
         'name'                 : table_id
        ,'startyear'            : year_start
        ,'endyear'              : year_end
        ,'regionalvariable'     : regvar
        ,'regionalkey'          : regkey
        ,'classifyingvariable1' : classvar1
        ,'classifyingkey1'      : classkey1
        ,'classifyingvariable2' : classvar2
        ,'classifyingkey2'      : classkey2
        ,'classifyingvariable3' : classvar3
        ,'classifyingkey3'      : classkey3
        ,'language'             : language
        ,'job'                  : job
        ,'transpose'            : 'true'
        ,'compress'             : 'true'
        ,'format'               : 'ffcsv'
    }
    logger.info('API request body successfully prepared: %s', url_body)

    logger.info('Sending API request for tablefile to %s', url)
    try:
        api_response = requests.post(url, headers=url_header, data=url_body)
        logger.info('API request sent, received status code: %s', api_response.status_code)
    except requests.RequestException as e:
        logger.error('API request failed: %s', e)
        raise exceptions.DataDownloadError(f"Failed to download data: {e}")

    return api_response

