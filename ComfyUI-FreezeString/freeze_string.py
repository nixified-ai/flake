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
                "disable": ("BOOLEAN", {"default": False}),
            },
            "hidden": {
                "unique_id": "UNIQUE_ID",
                "prompt": "PROMPT",
                "extra_pnginfo": "EXTRA_PNGINFO",
            }
        }

    RETURN_TYPES = ("STRING",)
    RETURN_NAMES = ("text",)
    FUNCTION = "process"
    CATEGORY = "utils"
    OUTPUT_NODE = True

    def check_lazy_status(self, freeze, frozen_text, disable=False, **kwargs):
        if disable or freeze:
            return []
        return ["text_input"]

    def process(self, freeze, frozen_text, disable=False, text_input=None, unique_id=None, prompt=None, extra_pnginfo=None):
        if disable:
            chosen_value = None
            ui_text = frozen_text
        elif freeze:
            chosen_value = frozen_text
            ui_text = str(chosen_value)
        else:
            chosen_value = text_input if text_input is not None else ""

        # Batching Support: text_input might be a list of strings if batching is used.
        # Ensure the script handles converting lists into a single multiline string
        # (e.g., using \n.join) before sending it to the "ui" payload so the frontend doesn't crash.
        if isinstance(chosen_value, list):
            ui_text = "\n".join(str(item) for item in chosen_value)
        elif chosen_value is None:
            # If disabled, chosen_value is None, but ui_text is already set to frozen_text
            pass
        else:
            ui_text = str(chosen_value)

        # Update the serialized workflow and prompt on the server-side during execution
        # so that saved images contain the actual output string inside the node's widget metadata.
        if not freeze and not disable:
            if prompt is not None and unique_id in prompt:
                prompt[unique_id]["inputs"]["frozen_text"] = ui_text

            if extra_pnginfo is not None and "workflow" in extra_pnginfo:
                workflow = extra_pnginfo["workflow"]
                if "nodes" in workflow:
                    for node in workflow["nodes"]:
                        if str(node.get("id")) == str(unique_id):
                            widgets_values = node.get("widgets_values")
                            if widgets_values is not None:
                                while len(widgets_values) <= 1:
                                    widgets_values.append("")
                                widgets_values[1] = ui_text
                            else:
                                node["widgets_values"] = [freeze, ui_text, disable]

        return {
            "result": (chosen_value,),
            "ui": {
                "text": [ui_text]
            }
        }

    @classmethod
    def IS_CHANGED(cls, freeze, frozen_text, disable=False, text_input=None, **kwargs):
        if disable:
            return "disabled"
        if freeze:
            # If freeze is True, return the frozen_text string so ComfyUI caches it properly.
            return frozen_text
        # If freeze is False, return float("NaN") to completely bypass caching.
        return float("NaN")
