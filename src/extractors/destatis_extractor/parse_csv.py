import pandas
from src.utilities import logging, exceptions   

def parse_csv(data_raw_zipped) -> pandas.DataFrame:
    """
    Parses the CSV content from the provided ZIP archive into a pandas DataFrame.

    Args:
        data_raw_zipped (zipfile.ZipFile):  
            The ZIP archive containing the CSV file to be parsed. It is expected that the archive contains exactly one CSV file.
    Returns:
        pandas.DataFrame:
            DataFrame containing the parsed CSV data. The CSV is interpreted using:
            - semicolon (;) as delimiter
            - comma (,) as decimal separator
            - predefined missing value markers: ['...', '.', '-', '/', 'x']
    Raises:
        exceptions.DataDownloadError:
            If the CSV content cannot be parsed into a DataFrame.
    """
    logger = logging.get_logger(__name__)

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