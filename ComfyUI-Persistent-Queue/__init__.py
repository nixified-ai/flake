
try:
    from .persistent_queue import PersistentQueueManager
except ImportError:
    from persistent_queue import PersistentQueueManager

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}
WEB_DIRECTORY = "./web"

import sys  # noqa: E402

manager = PersistentQueueManager()
if "pytest" not in sys.modules:
    manager.setup()
