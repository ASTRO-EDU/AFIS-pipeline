import logging
import sys
import os
from datetime import datetime
from enum import Enum

RECEIVER_LOG_LEVEL_ENV = "RECEIVER_LOG_LEVEL"
RECEIVER_LOG_MODE_ENV = "RECEIVER_LOG_MODE"
DEFAULT_FILE_LOG_ENV = "DEFAULT_FILE_LOG"

current_time=datetime.now()
datestr = current_time.strftime("%Y-%m-%d_%H-%M-%S")
DEFAULT_FILE_LOG = f"receiver-{datestr}.log"
class LogMode(Enum):
    BOTH = "both"
    FILE = "file"
    STDOUT_STDERR = "stdout_stderr"

DEFAULT_LOG_MODE = LogMode.BOTH
def get_log_mode():
    """
    reads the environment variable 'RECEIVER_LOG_MODE' and determines the log mode 'both', 'file' 'stdout_stderr'
    default: both
    """
    log_mode_str = os.getenv(RECEIVER_LOG_MODE_ENV,"").lower()
    try:
        log_mode = LogMode(log_mode_str)
    except ValueError:
        print(f"Undefined or not recognized log mode value: {log_mode_str}")
        log_mode = DEFAULT_LOG_MODE
    return log_mode

def get_log_level():
    """
    Reads the environment variable 'RECEIVER_LOG_LEVEL' and determines the log level.
    default: DEBUG
    """
    log_level_str = os.getenv(RECEIVER_LOG_LEVEL_ENV, "DEBUG").upper()
    return getattr(logging, log_level_str, logging.DEBUG)

def configure_logger(log_file=DEFAULT_FILE_LOG, mode=LogMode.STDOUT_STDERR, level=logging.DEBUG):
    """
    Configures the global logger.

    :param mode: logging mode. It can be "both", "stdout_stderr", or "file".
    :param log_file: log file name (used only when mode="file" or "both").
    :param level: required logging level.
    """
    if log_file is None:
        log_file = DEFAULT_FILE_LOG
    logger = logging.getLogger()
    logger.setLevel(level)  # Livello globale del logger

    # Rimuovi eventuali handler esistenti
    if logger.hasHandlers():
        logger.handlers.clear()

    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    def add_stream_handlers():
        # Handler per stdout
        stdout_handler = logging.StreamHandler(sys.stdout)
        stdout_handler.setLevel(logging.INFO)
        stdout_handler.setFormatter(formatter)
        logger.addHandler(stdout_handler)

        # Handler per stderr
        stderr_handler = logging.StreamHandler(sys.stderr)
        stderr_handler.setLevel(logging.ERROR)
        stderr_handler.setFormatter(formatter)
        logger.addHandler(stderr_handler)
    
    if mode == LogMode.STDOUT_STDERR:
        add_stream_handlers()

    elif mode == LogMode.FILE:
        try:
            # Handler per file
            file_handler = logging.FileHandler(log_file)
            file_handler.setLevel(logging.DEBUG)
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
        except Exception as e:
            print(f"Error while configuring the log file: {e}. Logging only to stdout and stderr.", file=sys.stderr)
            add_stream_handlers()

    elif mode == LogMode.BOTH:
        try:
            # Handler per file
            file_handler = logging.FileHandler(log_file)
            file_handler.setLevel(logging.DEBUG)
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
        except Exception as e:
            print(f"Error while configuring the log file: {e}. Logging only to stdout and stderr.", file=sys.stderr)
            add_stream_handlers()

        # Handler per stdout e stderr
        stdout_handler = logging.StreamHandler(sys.stdout)
        stdout_handler.setLevel(logging.INFO)
        stdout_handler.setFormatter(formatter)
        logger.addHandler(stdout_handler)

        stderr_handler = logging.StreamHandler(sys.stderr)
        stderr_handler.setLevel(logging.ERROR)
        stderr_handler.setFormatter(formatter)
        logger.addHandler(stderr_handler)

    logger=logging.getLogger()
    logger.info(f"Logger Mode: '{mode.value}'. Level: '{logging.getLevelName(level)}'")


