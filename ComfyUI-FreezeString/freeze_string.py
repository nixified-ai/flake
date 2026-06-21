class FreezeStringNode:
    @classmethod
    def INPUT_TYPES(cls):
        return {
            "required": {
                "freeze": ("BOOLEAN", {"default": False}),
                "frozen_text": ("STRING", {"multiline": True, "default": ""}),
            },
            "optional": {
                "text_input": ("STRING", {"forceInput": True, "lazy": True}),
            }
        }

    RETURN_TYPES = ("STRING",)
    RETURN_NAMES = ("text",)
    FUNCTION = "process"
    CATEGORY = "utils"
    OUTPUT_NODE = True

    def check_lazy_status(self, freeze, frozen_text, **kwargs):
        if freeze:
            return []
        return ["text_input"]

    def process(self, freeze, frozen_text, text_input=None):
        if freeze:
            chosen_value = frozen_text
        else:
            chosen_value = text_input if text_input is not None else ""

        # Batching Support: text_input might be a list of strings if batching is used.
        # Ensure the script handles converting lists into a single multiline string
        # (e.g., using \n.join) before sending it to the "ui" payload so the frontend doesn't crash.
        if isinstance(chosen_value, list):
            ui_text = "\n".join(str(item) for item in chosen_value)
        else:
            ui_text = str(chosen_value)

        return {
            "result": (chosen_value,),
            "ui": {
                "text": [ui_text]
            }
        }

    @classmethod
    def IS_CHANGED(cls, freeze, frozen_text, text_input=None):
        if freeze:
            # If freeze is True, return the frozen_text string so ComfyUI caches it properly.
            return frozen_text
        # If freeze is False, return float("NaN") to completely bypass caching.
        return float("NaN")
