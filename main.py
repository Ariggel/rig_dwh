import os
from dotenv import load_dotenv

from src.loaders.sql_loader import create_sql_engine, load_dataframe
from src.orchestration import ldbnrw_munic_fin_exp_job, ldbnrw_munic_fin_inc_job

#from src.extractors import ldbnrw_extractor

load_dotenv()
engine = create_sql_engine()



results = ldbnrw_munic_fin_inc_job.run()



for table, payload in results.items():
    load_dataframe(
         data_frame = payload["data_frame"]
        ,schema_name="RAW"
        ,table_name = payload["table_name_db"]
        ,engine = engine
    )
    

