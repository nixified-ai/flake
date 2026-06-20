from .freeze_string import FreezeStringNode

NODE_CLASS_MAPPINGS = {
    "FreezeStringNode": FreezeStringNode
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "FreezeStringNode": "Freeze String"
}

WEB_DIRECTORY = "./web"

__all__ = ["NODE_CLASS_MAPPINGS", "NODE_DISPLAY_NAME_MAPPINGS", "WEB_DIRECTORY"]
