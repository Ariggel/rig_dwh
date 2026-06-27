import os
from dotenv import load_dotenv

from src.loaders.sql_loader import create_sql_engine, load_dataframe
from src.orchestration import destatis_job

load_dotenv()
engine = create_sql_engine()


results = destatis_job.run()




for table, payload in results.items():
    load_dataframe(
         data_frame = payload["data_frame"]
        ,schema_name="RAW"
        ,table_name = payload["table_name_db"]
        ,engine = engine
    )
    