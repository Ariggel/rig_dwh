import zipfile
import io

from src.utilities import logging, exceptions

def parse_zip(data_raw_request : io.BytesIO) -> zipfile.ZipFile:
    """
    Parses the raw API response content into a ZIP archive.

    Args:
        data_raw_request (requests.Response):
            The raw response object returned from the API request.  
    
    Returns:
        zipfile.ZipFile: The parsed ZIP archive.
    
    Raises:
        exceptions.DataDownloadError: If the API response cannot be interpreted as a ZIP archive.
    
    Examples:
        >>> response = requests.get('https://example.com/data.zip')
        >>> zip_archive = parse_zip(response)
        >>> print(zip_archive.namelist())
    """


    logger = logging.get_logger(__name__)

    try:
        data_raw_bytes = io.BytesIO(data_raw_request.content)
        data_raw_zip = zipfile.ZipFile(data_raw_bytes)

        logger.info('API response successfully interpreted as ZIP archive, containing files: %s', data_raw_zip.namelist())
    except zipfile.BadZipFile as e:
        logger.error('API response is not a valid ZIP archive: %s', e)
        raise exceptions.DataDownloadError(f"Failed to interpret API response as ZIP archive: {e}")
    
    return data_raw_zip
