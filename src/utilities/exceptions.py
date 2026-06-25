class GenesisError(Exception):
    """Base class for all Genesis-related errors."""
    pass

class AuthenticationError(GenesisError):
    pass

class DataDownloadError(GenesisError):
    pass
