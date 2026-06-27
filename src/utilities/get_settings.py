import json
from config import paths

def get() -> dict:
    """
    Get settings from the configuration file.

    Returns:
        dict: A dictionary containing the settings.

    Raises:
        FileNotFoundError:
            If the settings file does not exist.

        json.JSONDecodeError:
            If the settings file is not a valid JSON.

        Exception:
            For any other exceptions that may occur while reading the settings.
    """
    try:
        with open(paths.dir_config / "settings.json") as settings:
            return json.load(settings)
    except FileNotFoundError as e:  
        raise FileNotFoundError(f"Settings file not found: {e.filename}") from e
    except json.JSONDecodeError as e:
        raise json.JSONDecodeError(f"Invalid JSON in settings file: {e.msg}", e.doc, e.pos) from e