import os, requests
from dotenv import load_dotenv

from src.loaders.sql_loader import create_sql_engine, load_dataframe
from src.extractors.ldbnrw_extractor import post_request,joblist

from config import paths
import json

load_dotenv()
engine = create_sql_engine()



test_file = paths.dir_config / 'test.json'
with open(test_file, 'r') as file:
    test_json = json.load(file)

test_json_status = test_json.get("Status")
print(test_json_status)
test_json_content = test_json_status.get("Content")
print(test_json_content)
test_json_table = test_json_content.split(': ')[-1].strip()
print(test_json_table)
print('_____________________________________________')
print('_____________________________________________')
print('_____________________________________________')
print('_____________________________________________')


with open(paths.dir_config / 'settings.json', 'r') as file_settings:
    config = json.load(file_settings)['api_ldbnrw']

from src.utilities import logging
logger = logging.get_logger(__name__)

logger.info('Preparing URL for API tablefile request')
url = config['base_url'] + 'data/resultfile'
logger.info('API tablefile request URL: %s', url)
logger.info('Preparing headers for API request')
url_header = {
     'Content-Type' : config['content_type']
    ,'username' : os.getenv('LDBNRW_USER')
    ,'password' : os.getenv('LDBNRW_PASSWORD')
}
logger.info('API request headers prepared')
logger.info('Preparing body for API request')
url_body = {
     'name'                 : test_json_table
    ,'area' : 'all'
    ,'compress' : 'true'
    ,'format' : 'ffcsv'
}
logger.info('API request body successfully prepared: %s', url_body)
logger.info('Sending API request for tablefile to %s', url)
import time

stamp_api_post = time.time()
api_response = requests.post(url, headers=url_header, data=url_body)
stamp_api_get = time.time()
time_api = stamp_api_get - stamp_api_post
print('API time: ',time_api/60)
print(api_response.content)
import io,zipfile
api_bytes = io.BytesIO(api_response.content)
api_zipped = zipfile.ZipFile(api_bytes)
print(api_zipped)

import pandas

data_raw_csv = api_zipped.open(api_zipped.namelist()[0])
data_raw_data_frame = pandas.read_csv(
        data_raw_csv
        ,delimiter  = ';'
        ,decimal    = ','
        ,na_values  = ['...','.','-','/','x']
)
print(data_raw_data_frame)
#api_response = post_request.tablefile(
#    "79118-12i"
#    ,2009
#    ,2009
#    ,"GEMGFR"
#    ,"*"
#    ,"PRODGR"
#    ,"*"
#    ,"KONTO5"
#    ,"*"
#    ,''
#    ,''
#    ,'true'
#    ,'de'
#)
#print(api_response)
#print(api_response.content)


#api_response_status = api_response.json().get("Status", {})
#api_response_content = api_response_status.get("Content")

#print("Content: ",api_response_content)

#import io,zipfile

#api_bytes = io.BytesIO(api_response)
#print("api_bytes: ",api_bytes)

#api_zipped = zipfile.ZipFile(api_bytes)
#print("api_zipped: ",api_zipped)

#print('Code:',api_response.json().get("Code"))
#print('Content:',api_response.json().get("Content"))
#print('Type:',api_response.json().get("Type"))
#