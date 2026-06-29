import pandas
import zipfile

from src.utilities import logging, exceptions

def parse_csv (data_raw_zip : zipfile.ZipFile) -> pandas.DataFrame:
    """
    Parses the CSV file contained within a ZIP archive into a pandas DataFrame.

    Args:
        data_raw_zip (zipfile.ZipFile):
            The ZIP archive containing the CSV file. It is expected to contain exactly one CSV file.
        
    Returns:
        pandas.DataFrame: A DataFrame containing the parsed CSV data.
    
    Raises:
        exceptions.DataDownloadError: If the CSV file cannot be parsed into a DataFrame.

    Examples:
        >>> zip_archive = zipfile.ZipFile('data.zip')
        >>> df = parse_csv(zip_archive)
        >>> print(df.shape)
        (100, 10)

    Notes:
        - The CSV is expected to be in "ffcsv" format, which uses semicolon (;) as the delimiter and comma (,) as the decimal separator.
        - Missing values in the CSV are represented by specific markers: ['...', '.', '-', '/', 'x'].
    """

    logger = logging.get_logger(__name__)
    
    try:
        data_raw_csv = data_raw_zip.open(data_raw_zip.namelist()[0])
        data_raw_data_frame = pandas.read_csv(
                data_raw_csv
                ,delimiter  = ';'
                ,decimal    = ','
                ,na_values  = ['...','.','-','/','x']
        )
        logger.info('CSV content successfully parsed into DataFrame with shape: %s', data_raw_data_frame.shape)
    except pandas.errors.ParserError as e:
        logger.error('Error occurred while parsing CSV content: %s', e)
        raise exceptions.DataDownloadError(f"Failed to parse CSV content into DataFrame: {e}")
    
    return data_raw_data_frame 