import io
import zipfile
from src.utilities import exceptions, logging   


def parse_zip(data_raw_request) -> zipfile.ZipFile:
    """
    Parses the raw API response content into a ZIP archive. 
    
    
    Args:
        data_raw_request (requests.Response):
            The raw response object returned from the API request.  
    
    Returns:
        zipfile.ZipFile: The parsed ZIP archive.    
    
    Raises:
        exceptions.DataDownloadError: If the API response cannot be interpreted as a ZIP archive. 
    """

    logger = logging.get_logger(__name__)

    try:
        data_raw_bytes = io.BytesIO(data_raw_request.content)
        data_raw_zipped = zipfile.ZipFile(data_raw_bytes)
        logger.info('API response successfully interpreted as ZIP archive, containing files: %s', data_raw_zipped.namelist())
    except zipfile.BadZipFile as e:
        logger.critical('Failed to interpret API response as ZIP archive: %s', {e})
        raise exceptions.DataDownloadError(f"Failed to interpret API response as ZIP archive: {e}")
    
    return data_raw_zipped