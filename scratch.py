class Gemma4GGUFModelLoader:
    RETURN_TYPES = ("GEMMA4_GGUF_MODEL",)
    RETURN_NAMES = ("model",)
    FUNCTION = "load_model"
    @classmethod
    def IS_CHANGED(cls, **kwargs):
        if not kwargs.get("keep_model_loaded", True):
            import time
            return time.time()
        return ""

    CATEGORY = "Gemma4 GGUF"

    def load_model(self):
        pass
