import { app } from "../../scripts/app.js";

app.registerExtension({
    name: "Comfy.FreezeString",
    async beforeRegisterNodeDef(nodeType, nodeData, app) {
        if (nodeData.name === "FreezeStringNode") {
            const onExecuted = nodeType.prototype.onExecuted;
            nodeType.prototype.onExecuted = function (message) {
                // Call the original onExecuted
                onExecuted?.apply(this, arguments);

                // 1. Check current UI freeze widget state. If frozen, do not overwrite user edits.
                const freezeWidget = this.widgets?.find((w) => w.name === "freeze");
                if (freezeWidget && freezeWidget.value === true) {
                    return;
                }

                // 2. Check execution freeze state. If the run was frozen, do not overwrite.
                const isMessageFrozen = Array.isArray(message?.freeze) ? message.freeze[0] === true : message?.freeze === true;
                if (isMessageFrozen) {
                    return;
                }

                if (message && message.text) {
                    // Find the widget named 'frozen_text'
                    const widget = this.widgets?.find((w) => w.name === "frozen_text");
                    if (widget) {
                        // Extract text string from payload (handling array or single string)
                        const textValue = Array.isArray(message.text) ? message.text[0] : message.text;
                        widget.value = textValue;
                        if (widget.inputEl) {
                            widget.inputEl.value = textValue;
                        }
                        this.setDirtyCanvas(true, true);
                    }
                }
            };
        }
    }
});
