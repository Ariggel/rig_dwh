import os
import requests
import json
import zipfile
import io
import pandas
from config import paths
from src.utilities import exceptions,logging


def download_raw(table_id : str, year_start : int = 2020, year_end : int = 2025, language_data : str = 'de') -> pandas.DataFrame:
    """
    Downloads tabular data from the Genesis API, extracts the compressed CSV response,
    and returns it as a pandas DataFrame.

    The function reads API configuration from a local JSON settings file and uses an
    access token provided via environment variable for authentication. The API response
    is expected to be a compressed (ZIP) file containing a single CSV file in "ffcsv" format.

    Args:
        table_id (str):
            Identifier of the table to be retrieved from the API.

        year_start (int, optional):
            First year of the requested time range (inclusive).
            Defaults to 2020.

        year_end (int, optional):
            Last year of the requested time range (inclusive).
            Defaults to 2025.

        language_data (str, optional):
            Language code for the returned dataset (e.g., 'de', 'en').
            Defaults to 'de'.

    Returns:
        pandas.DataFrame:
            DataFrame containing the parsed CSV data. The CSV is interpreted using:
            - semicolon (;) as delimiter
            - comma (,) as decimal separator
            - predefined missing value markers: ['...', '.', '-', '/', 'x']

    Raises:
        FileNotFoundError:
            If the configuration file (settings.json) cannot be found.

        KeyError:
            If required keys (e.g., API base URL) are missing in the configuration.

        EnvironmentError:
            If the required environment variable 'GENESIS_ACCESS_TOKEN' is not set.

        requests.RequestException:
            If the API request fails (e.g., network issues, invalid response).

        zipfile.BadZipFile:
            If the API response cannot be interpreted as a valid ZIP archive.

        pandas.errors.ParserError:
            If the CSV content cannot be parsed into a DataFrame.

    Notes:
        - The API endpoint is expected to return a ZIP archive containing exactly one CSV file.
        - Authentication is handled via the 'username' field using an access token.
        - The password field is intentionally left empty as per API specification.

    Security:
        - The API access token is retrieved from an environment variable and is not stored in code.
        - Ensure that environment variables are managed securely in production environments.

    Example:
        >>> data_raw = download_raw("12345-0001", 2020, 2022, "de")
    """
    
    logger = logging.get_logger(__name__)

    settings_file = paths.dir_config / 'settings.json'
    with open(settings_file, 'r') as f:
        config = json.load(f)

    api_access_url = config['api']['base_url']
    api_access_token = os.getenv('GENESIS_ACCESS_TOKEN')
    
    headers = {
         'Content-Type' : 'application/x-www-form-urlencoded'
        ,'username'     : api_access_token
        ,'password'     : ''
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
        logger.info('API request successful, status code: %s', data_raw_request.status_code)
    except requests.RequestException as e:
        logger.critical('API request failed: %s', data_raw_request.status_code)
        raise exceptions.DataDownloadError(f"Failed to download data: {e}")

    try:
        data_raw_bytes = io.BytesIO(data_raw_request.content)
        data_raw_zipped = zipfile.ZipFile(data_raw_bytes)
        logger.info('API response successfully interpreted as ZIP archive, containing files: %s', data_raw_zipped.namelist())
    except zipfile.BadZipFile as e:
        logger.critical('Failed to interpret API response as ZIP archive: %s', {e})
        raise exceptions.DataDownloadError(f"Failed to interpret API response as ZIP archive: {e}")
    
    try:
        data_raw_csv = data_raw_zipped.open(data_raw_zipped.namelist()[0])
        data_raw_data_frame = pandas.read_csv(
             data_raw_csv
            ,delimiter  = ';'
            ,decimal    = ','
            ,na_values  = ['...','.','-','/','x']
        )
        logger.info('CSV content successfully parsed into DataFrame with shape: %s', data_raw_data_frame.shape)
    except pandas.errors.ParserError as e:
        logger.critical('Failed to parse CSV content into DataFrame: %s', {e})
        raise exceptions.DataDownloadError(f"Failed to parse CSV content into DataFrame: {e}")

    return data_raw_data_frame