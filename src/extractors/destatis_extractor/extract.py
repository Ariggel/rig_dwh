import pandas
import json
from src.utilities import logging
from src.extractors.destatis_extractor import parse, request_post

def extract(table_id : str, year_start : int = 2020, year_end : int = 2025, language_data : str = 'de') -> pandas.DataFrame:
    """
    """
    
    logger = logging.get_logger(__name__)

    logger.info('Starting data extraction for table %s from %s to %s in language %s', table_id, year_start, year_end, language_data)
    data_raw_request = request_post.data_tablefile(table_id, year_start, year_end, language_data)
    
    logger.info('Data extraction request completed with status code: %s', data_raw_request.status_code)
    try:
        logger.debug('Attempting to parse response as JSON to check for background job.')
        data_raw_request.json()


        logger.info('Response indicates a background job needs to be initiated. API is currently not able to handle jobs. Request canceled.')
        return None

        logger.info('Response indicates a background job needs to be initiated. Proceeding to handle background job.')
        raw_job = request_post.job(table_id, year_start, year_end, language_data)

        logger.info('Background job request completed with status code: %s', raw_job.status_code)
        job_id = parse.response(table_id, raw_job)

        if job_id:
            logger.info('Background job initiated with job ID: %s. Waiting for job completion.', job_id)
            request_post.poll(job_id)

            logger.info('Background job %s completed. Retrieving data.', job_id)
            data_raw_request = request_post.data_tablefile(job_id, year_start, year_end, language_data)

    except ValueError:
        logger.info('Response does not indicate a background job. Proceeding to parse data directly.')
        data_raw_zipped = parse.zip(data_raw_request)

        logger.info('Data successfully retrieved and parsed from API response. Proceeding to convert to DataFrame.')
        data_raw_data_frame = parse.csv(data_raw_zipped)

    return data_raw_data_frame