import os
import requests
import time

from src.utilities import logging, exceptions, get_settings

def data_tablefile(table_id : str, year_start : int, year_end : int, language_data : str = 'de'):
    """
    Downloads data from the DESTATIS API for a specified table and time range.

    Args:
        table_id (str):
            The identifier of the table to extract data from.
        year_start (int):
            The starting year for the data extraction.
        year_end (int):
            The ending year for the data extraction.
        language_data (str, optional):
            The language code for the data extraction. Defaults to 'de' (German).

    Returns:
        requests.Response:
            The response object from the API request, which contains the extracted data.

    Raises:
        exceptions.DataDownloadError:
            If there is an error during the API request.

    Notes:
        This function uses the DESTATIS API to download data for a specified table and time range

    Security:
        Ensure that the DESTATIS_ACCESS_TOKEN environment variable is set with a valid access token before calling this function.
    
    Example:
        >>> response = data('46241-0012', 2020, 2025, 'de')
        >>> print(response.status_code)
        200
    """
    logger = logging.get_logger(__name__)

    config = get_settings.get()

    api_access_url = config['api_destatis']['base_url']
    api_access_token = os.getenv('DESTATIS_ACCESS_TOKEN')

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
        
    return data_raw_request


def job(table_id : str, year_start : int, year_end : int, language_data : str = 'de'):
    """
    Submits a request to the DESTATIS API to initiate a background job for data extraction.

    Args:
        table_id (str):
            The identifier of the table to extract data from.
        year_start (int):
            The starting year for the data extraction.
        year_end (int):
            The ending year for the data extraction.
        language_data (str, optional):
            The language code for the data extraction. Defaults to 'de' (German).
    
    Returns:
        requests.Response:
            The response object from the API request, which contains information about the initiated job.
    Raises:
        exceptions.DataDownloadError:
            If there is an error during the API request.

    Notes:
        This function uses the DESTATIS API to initiate a background job for data extraction. It
        will send a POST request to the API with the specified parameters and return the response object.
    
    Security:
        Ensure that the DESTATIS_USER and DESTATIS_PASSWORD environment variables are set with valid credentials before calling this function.
    
    Example:
        >>> response = job('46241-0012', 2020, 2025, 'de')
        >>> print(response.status_code)
        200
    """
    logger = logging.get_logger(__name__)

    config = get_settings.get()

    api_access_url = config['api_destatis']['base_url']
    api_user = os.getenv('DESTATIS_USER')
    api_password = os.getenv('DESTATIS_PASSWORD')

    headers = {
         'Content-Type' : 'application/x-www-form-urlencoded'
        ,'username'     : api_user
        ,'password'     : api_password
    }

    try:
        job_request = requests.post(
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
                ,'job'      : 'true'
            }
        )
        logger.info('API request successful, status code: %s', job_request.status_code)
    except requests.RequestException as e:
        logger.critical('API request failed: %s', job_request.status_code)
        raise exceptions.DataDownloadError(f"Failed to download data: {e}")
        
    return job_request


def poll(job_id : str, timeout : int = 600) -> bool:
    """
    Polls the API for the status of a background job until it is completed or a timeout occurs.

    Args:
        job_id (str):
            The identifier of the background job to poll.
        timeout (int, optional):
            Maximum time in seconds to wait for the job to complete. Defaults to 600 seconds.
    
    Returns:
        bool:
            True if the job completed successfully.
    
    Raises:
        TimeoutError:
            If the job does not complete within the specified timeout.
        exceptions.DataDownloadError:
            If there is an error during the polling request.
    
    Notes:
        This function uses the DESTATIS API to check the status of a background job. It will repeatedly send POST requests to the API until the job is marked as completed or the timeout is reached.

    Security:
        Ensure that the DESTATIS_USER and DESTATIS_PASSWORD environment variables are set with valid credentials before calling this function.
    
    Example:
        >>> job_id = "46241-0012_908548251"
        >>> poll(job_id, timeout=300)
        True
    """
    logger = logging.get_logger(__name__)

    config = get_settings.get()

    api_url_base = config['api_destatis']['base_url']
    api_url_resultlist = config['api_destatis']['suffix_resultlist']
    api_url = api_url_base + api_url_resultlist
    api_sleep = config['api_destatis']['timeout']

    api_user = os.getenv('DESTATIS_USER')
    api_password = os.getenv('DESTATIS_PASSWORD')

    headers = {
         "Content-Type": "application/x-www-form-urlencoded"
        ,"username" : api_user
        ,"password" : api_password
    }

    logger.info("Polling background job %s...", job_id)

    start_time = time.time()
    
    while True:
        try:
            response = requests.post(
                api_url,
                headers=headers,
                data={
                     "selection"    : job_id
                    ,"language"     : "de"
                    ,"pagelength"   : 250
                    ,"area"         : "all"
                },
            )
            response.raise_for_status()
        except requests.RequestException as e:
            logger.error('Polling request failed: %s', e)
            raise exceptions.DataDownloadError(f'Polling failed: {e}') from e
        
        response_list = response.json().get("List",[])
        
        if response_list:
            logger.info("Background job %s completed.", job_id)
            return True
        else:
            if time.time() - start_time > timeout:
                logger.error('Polling timed out after %s seconds for job %s.',timeout, job_id)
                raise TimeoutError(f'Background job {job_id} did not finish within {timeout} seconds.')
            logger.debug('Background job %s is not ready yet. Waiting %s seconds.',job_id, api_sleep)
            time.sleep(api_sleep)


