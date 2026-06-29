import pandas
import json
import os
import requests

from config import paths
from src.extractors.ldbnrw_extractor.parse_csv import parse_csv
from src.extractors.ldbnrw_extractor.parse_zip import parse_zip
from src.utilities import logging, exceptions

def extract(table_id : str, year_start : int, year_end : int, language_data :str) -> pandas.DataFrame:
    """
        Downloads tabular data from the LDB NRW API, extracts the compressed CSV response, and returns it as a pandas DataFrame.

        Args:
            table_id (str): The identifier of the table to download.
            year_start (int): The starting year for the data.
            year_end (int): The ending year for the data.
            language_data (str): The language code for the data.
        
        Returns:
            pandas.DataFrame: A DataFrame containing the extracted data.
        
        Raises:
            exceptions.DataDownloadError: If the API request fails or returns a non-200 status code.
        
        Notes:
            - The API endpoint is expected to return a ZIP archive containing exactly one CSV file.
            - The CSV is expected to be in "ffcsv" format, which uses semicolon (;) as the delimiter and comma (,) as the decimal separator.
            - Missing values in the CSV are represented by specific markers: ['...', '.', '-', '/', 'x'].
        
        Security:
            - The API access token is retrieved from an environment variable named 'LDBNRW_ACCESS_TOKEN'.
            - Ensure that the access token is kept secure and not exposed in logs or error messages.
        
        Examples:
            >>> df = extract('table_id_example', 2020, 2025, 'de')
            >>> print(df.head())
    """


    logger = logging.get_logger(__name__)

    settings_file = paths.dir_config / 'settings.json'
    with open(settings_file, 'r') as file:
        config = json.load(file)

    api_access_url = config['api_ldbnrw']['base_url']
    api_access_token = os.getenv('LDBNRW_ACCESS_TOKEN')

    headers = {
         'Content-Type': 'application/x-www-form-urlencoded'
        ,'username' : api_access_token
        ,'password' : ''
    }

    try:
        data_raw_request = requests.post(
            api_access_url + 'data/tablefile'
            ,headers = headers
            ,data = {
                 'name'     : table_id
                ,'startyear': year_start
                ,'endyear'  : year_end
                ,'transpose': 'true'
                ,'compress' : 'true'
                ,'format'   : 'ffcsv'
                ,'language' : language_data
            }
        )
        logger.info('API request successfull, status code: %s', data_raw_request.status_code)
    except requests.RequestException as e:
        logger.error('API request failed: %s', e)
        raise exceptions.DataDownloadError(f"Failed to download data: {e}")

    if data_raw_request.status_code == 200:
        raw_data_zipped = parse_zip(data_raw_request)
        raw_data_frame = parse_csv(raw_data_zipped)
    else:
        logger.error('API request failed with status code: %s', data_raw_request.status_code)
        raise exceptions.DataDownloadError(f"Failed to download data, status code: {data_raw_request.status_code}")

    return raw_data_frame