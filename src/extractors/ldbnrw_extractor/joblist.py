import os, json, requests
from config import paths
from src.utilities import logging, exceptions


def get(
        area_type : str
    ):

    logger = logging.get_logger(__name__)
    with open(paths.dir_config / 'settings.json', 'r') as file_settings:
        config = json.load(file_settings)['api_ldbnrw']

    logger.info('Preparing URL for API joblist request')
    url = config['base_url'] + config['suffix_resultlist']
    logger.info('API joblist request URL: %s', url)

    logger.info('Preparing headers for API request')
    url_header = {
         'Content-Type' : config['content_type']
        ,'username' : os.getenv('LDBNRW_USER')
        ,'password' : os.getenv('LDBNRW_PASSWORD')
    }
    logger.info('API request headers prepared')

    logger.info('Preparing body for API request')
    url_body = {
         'selection' : '*'
        ,'searchcriterion' : 'code'
        ,'sortcriterion' : 'code'
        ,'type' : 'all'
        ,'area' : area_type
        
    }
    logger.info('API request body successfully prepared: %s', url_body)

    logger.info('Sending API request for joblist to %s', url)
    try:
        api_response = requests.post(url, headers=url_header, data=url_body)
        logger.info('API request sent, received status code: %s', api_response.status_code)
    except requests.RequestException as e:
        logger.error('API request failed: %s', e)
        raise exceptions.DataDownloadError(f"Failed to download data: {e}")

    return api_response

