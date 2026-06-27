import os
from sqlalchemy import Engine, create_engine

from src.utilities import logging, get_settings

def create_sql_engine() -> Engine:
    """
    Creates a SQLAlchemy engine for connecting to a SQL Server database.

    Returns:
        create_engine: SQLAlchemy engine instance.

    Raises:
        EnvironmentError:
            If required environment variables for SQL credentials are not set.

        KeyError:
            If required keys (e.g., server, database) are missing in the configuration.

        Exception:
            For any other exceptions that may occur during engine creation.
    """

    logger = logging.get_logger(__name__)

    try:
        config = get_settings.get()

        server = config["sql"]["server"]
        database = config["sql"]["database"]

        user = os.getenv("SQL_USER")
        password = os.getenv("SQL_PASSWORD")

        if not user or not password:
            raise EnvironmentError("SQL_USER and SQL_PASSWORD environment variables must be set.")

        connection_string = (
            f"mssql+pyodbc://{user}:{password}@{server}/{database}"
            "?driver=ODBC+Driver+17+for+SQL+Server"
        )
        engine = create_engine(connection_string)

    except (EnvironmentError, KeyError) as e:
        logger.error(f"Error creating SQL engine: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error occurred: {e}")
        raise

    return engine
