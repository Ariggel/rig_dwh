import zipfile, io, requests, pandas
from src.utilities import logging, exceptions

def zip(data_raw_request : requests.Response) -> zipfile.ZipFile:
    """
    
    Args:
    
    Returns:
    
    Raises:
    
    Notes:
    
    Security:
    
    Example:
    """

    logger = logging.get_logger(__name__)

    logger.info('Attempting to interpret API response as ZIP archive, with content length: %s bytes', len(data_raw_request.content))
    try:
        data_raw_bytes = io.BytesIO(data_raw_request.content)
        data_raw_zipped = zipfile.ZipFile(data_raw_bytes)
        logger.info('API response successfully interpreted as ZIP archive, containing files: %s', data_raw_zipped.namelist())
    except zipfile.BadZipFile as e:
        logger.critical('Failed to interpret API response as ZIP archive: %s', e)
        raise exceptions.DataDownloadError(f"Failed to interpret API response as ZIP archive: {e}")
    
    return data_raw_zipped

def csv(data_raw_zipped : zipfile.ZipFile) -> pandas.DataFrame:
    """
    """
    
    logger = logging.get_logger(__name__)

    logger.info('Attempting to parse CSV content from ZIP archive, containing files: %s', data_raw_zipped.namelist())
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
        logger.critical('Failed to parse CSV content into DataFrame: %s', e)
        raise exceptions.DataDownloadError(f"Failed to parse CSV content into DataFrame: {e}")
    return data_raw_data_frame