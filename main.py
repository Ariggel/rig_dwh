from src.orchestration import destatis_job
import os
from dotenv import load_dotenv


load_dotenv()

results = destatis_job.run()