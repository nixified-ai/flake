import { api } from "../../scripts/api.js";
import { app } from "../../scripts/app.js";
import { $el } from "../../scripts/ui.js";

app.registerExtension({
	name: "ComfyUI.PersistentQueue",
	async setup(app_instance) {
		console.warn(
			"🚀 [ComfyUI-Persistent-Queue] Extension setup() is running! If you don't see this, clear your cache.",
		);

		// 1. Try to add to the new V1 app.menu if it exists
		if (
			app_instance &&
			app_instance.menu &&
			typeof app_instance.menu.addAction === "function"
		) {
			app_instance.menu.addAction({
				id: "persistent-queue",
				label: "Manage Saved Queue",
				action: () => showManagerDialog(),
			});
			console.log("[ComfyUI-Persistent-Queue] Added to V1 app.menu");
		}

		// 2. Create the button element
		const queueButton = $el("button", {
			textContent: "Manage Saved Queue",
			onclick: () => showManagerDialog(),
		});

		// 3. Try legacy .comfy-menu insertion
		const standardQueueBtn = document.getElementById("QueueButton");
		if (standardQueueBtn && standardQueueBtn.offsetParent !== null) {
			standardQueueBtn.parentNode.insertBefore(
				queueButton,
				standardQueueBtn.nextSibling,
			);
			console.log("[ComfyUI-Persistent-Queue] Added to legacy comfy-menu");
		} else {
			// 4. Fallback for new ComfyUI Frontend where legacy menu is hidden
			queueButton.style.position = "fixed";
			queueButton.style.bottom = "80px"; // Above the new bottom bar
			queueButton.style.right = "40px";
			queueButton.style.zIndex = "999999";
			queueButton.style.padding = "10px 15px";
			queueButton.style.backgroundColor = "#ff5722";
			queueButton.style.color = "white";
			queueButton.style.border = "2px solid white";
			queueButton.style.borderRadius = "8px";
			queueButton.style.cursor = "pointer";
			queueButton.style.boxShadow = "0 4px 12px rgba(0,0,0,0.5)";
			queueButton.style.fontWeight = "bold";
			queueButton.style.boxShadow = "0 4px 6px rgba(0,0,0,0.3)";

			// Add hover effect
			queueButton.onmouseover = () => (queueButton.style.background = "#333");
			queueButton.onmouseout = () => (queueButton.style.background = "#222");

			document.body.append(queueButton);
		}
	},
});

async function showManagerDialog() {
	const dialog = document.createElement("dialog");
	dialog.style.width = "800px";
	dialog.style.maxWidth = "90vw";
	dialog.style.height = "600px";
	dialog.style.maxHeight = "90vh";
	dialog.style.display = "flex";
	dialog.style.flexDirection = "column";
	dialog.style.background = "#222";
	dialog.style.color = "#fff";
	dialog.style.border = "1px solid #444";
	dialog.style.borderRadius = "8px";
	dialog.style.padding = "20px";
	dialog.style.fontFamily = "sans-serif";
	dialog.style.zIndex = "9999";

	const header = $el(
		"div",
		{
			style: {
				display: "flex",
				justifyContent: "space-between",
				alignItems: "center",
				marginBottom: "15px",
			},
		},
		[
			$el("h2", {
				textContent: "Persistent Queue Manager",
				style: { margin: 0 },
			}),
			$el("button", {
				textContent: "Close",
				onclick: () => dialog.remove(),
			}),
		],
	);

	const configContainer = $el("div", {
		style: {
			marginBottom: "15px",
			display: "flex",
			alignItems: "center",
			gap: "10px",
		},
	});
	const autoLoadCheckbox = $el("input", { type: "checkbox" });
	configContainer.append(
		autoLoadCheckbox,
		$el("span", { textContent: "Auto-inject saved queue on startup" }),
	);

	// Fetch config
	const configRes = await fetch("/comfyui-persistent-queue/config");
	const config = await configRes.json();
	autoLoadCheckbox.checked = config.auto_load || false;

	autoLoadCheckbox.onchange = async () => {
		await fetch("/comfyui-persistent-queue/config", {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify({ auto_load: autoLoadCheckbox.checked }),
		});
	};

	const tabsContainer = $el("div", {
		style: {
			display: "flex",
			gap: "10px",
			marginBottom: "15px",
			borderBottom: "1px solid #444",
			paddingBottom: "5px",
		},
	});
	const pendingTab = $el("div", {
		textContent: "Pending & Saved",
		style: {
			cursor: "pointer",
			fontWeight: "bold",
			borderBottom: "2px solid #fff",
		},
	});
	const historyTab = $el("div", {
		textContent: "History (Completed)",
		style: { cursor: "pointer", color: "#aaa" },
	});
	tabsContainer.append(pendingTab, historyTab);

	const contentArea = $el("div", {
		style: {
			flex: 1,
			overflowY: "auto",
			border: "1px solid #333",
			padding: "10px",
			background: "#1a1a1a",
		},
	});

	dialog.append(header, configContainer, tabsContainer, contentArea);
	document.body.append(dialog);
	dialog.showModal();

	let currentTab = "pending";

	pendingTab.onclick = () => {
		currentTab = "pending";
		pendingTab.style.fontWeight = "bold";
		pendingTab.style.color = "#fff";
		pendingTab.style.borderBottom = "2px solid #fff";
		historyTab.style.fontWeight = "normal";
		historyTab.style.color = "#aaa";
		historyTab.style.borderBottom = "none";
		renderContent();
	};

	historyTab.onclick = () => {
		currentTab = "history";
		historyTab.style.fontWeight = "bold";
		historyTab.style.color = "#fff";
		historyTab.style.borderBottom = "2px solid #fff";
		pendingTab.style.fontWeight = "normal";
		pendingTab.style.color = "#aaa";
		pendingTab.style.borderBottom = "none";
		renderContent();
	};

	async function renderContent() {
		contentArea.innerHTML = "Loading...";
		const res = await fetch("/comfyui-persistent-queue/prompts");
		const prompts = await res.json();
		contentArea.innerHTML = "";

		const filtered = prompts.filter((p) =>
			currentTab === "pending"
				? p.status !== "completed"
				: p.status === "completed",
		);

		if (filtered.length === 0) {
			contentArea.innerHTML =
				"<div style='color: #888; text-align: center; margin-top: 20px;'>No items found.</div>";
			return;
		}

		if (currentTab === "history") {
			const clearBtn = $el("button", {
				textContent: "Clear All History",
				style: {
					marginBottom: "10px",
					background: "#d32f2f",
					color: "white",
					border: "none",
					padding: "5px 10px",
					borderRadius: "3px",
					cursor: "pointer",
				},
				onclick: async () => {
					await fetch("/comfyui-persistent-queue/clear_history", {
						method: "POST",
					});
					renderContent();
				},
			});
			contentArea.append(clearBtn);
		}

		for (const p of filtered) {
			const item = $el("div", {
				style: {
					border: "1px solid #444",
					padding: "10px",
					marginBottom: "10px",
					borderRadius: "5px",
					background: "#2a2a2a",
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
				},
			});

			const info = $el("div", { style: { flex: 1 } }, [
				$el("div", {
					textContent: `ID: ${p.prompt_id.substring(0, 8)}...`,
					style: { fontSize: "0.9em", color: "#aaa" },
				}),
				$el("div", {
					textContent: `Status: ${p.status.toUpperCase()}`,
					style: { fontWeight: "bold", marginTop: "5px" },
				}),
				$el("div", {
					textContent: `Created: ${new Date(p.created_at + "Z").toLocaleString()}`,
					style: { fontSize: "0.8em", color: "#888", marginTop: "5px" },
				}),
			]);

			const actions = $el("div", {
				style: { display: "flex", gap: "5px", flexDirection: "column" },
			});

			if (p.status === "saved_from_crash" || currentTab === "history") {
				const queueBtn = $el("button", {
					textContent: "Queue This",
					onclick: async () => {
						const workflow = p.prompt_data.extra_data?.extra_pnginfo?.workflow;
						try {
							await api.queuePrompt(0, {
								output: p.prompt_data.prompt,
								workflow: workflow || p.prompt_data.prompt,
							});
						} catch (e) {
							console.error("[ComfyUI-Persistent-Queue] queuePrompt failed", e);
							// Fallback to fetch if api.queuePrompt is missing or fails
							const body = {
								prompt: p.prompt_data.prompt,
								extra_data: p.prompt_data.extra_data,
								client_id: api.clientId,
							};
							await fetch("/prompt", {
								method: "POST",
								headers: { "Content-Type": "application/json" },
								body: JSON.stringify(body),
							});
						}
						// If we just queued a crash-saved item, let's delete the crash record so it's not a duplicate
						// The diffing engine will catch the new one.
						if (p.status === "saved_from_crash") {
							await fetch("/comfyui-persistent-queue/delete", {
								method: "POST",
								headers: { "Content-Type": "application/json" },
								body: JSON.stringify({ prompt_id: p.prompt_id }),
							});
						}
						renderContent();
					},
				});
				actions.append(queueBtn);
			}

			const copyBtn = $el("button", {
				textContent: "Copy JSON",
				onclick: () => {
					navigator.clipboard.writeText(
						JSON.stringify(p.prompt_data.prompt, null, 2),
					);
					alert("Copied to clipboard");
				},
			});

			const saveBtn = $el("button", {
				textContent: "Save as Workflow",
				onclick: () => {
					// extra_data often contains the original workflow representation in "extra_pnginfo.workflow"
					const workflow =
						p.prompt_data.extra_data?.extra_pnginfo?.workflow ||
						p.prompt_data.prompt;
					const blob = new Blob([JSON.stringify(workflow, null, 2)], {
						type: "application/json",
					});
					const url = URL.createObjectURL(blob);
					const a = document.createElement("a");
					a.href = url;
					a.download = `workflow_${p.prompt_id.substring(0, 8)}.json`;
					a.click();
					URL.revokeObjectURL(url);
				},
			});

			const loadBtn = $el("button", {
				textContent: "Load into Workspace",
				style: { color: "#4caf50" },
				onclick: () => {
					const workflow = p.prompt_data.extra_data?.extra_pnginfo?.workflow;
					if (workflow) {
						app.loadGraphData(workflow);
					} else {
						app.loadApiJson(p.prompt_data.prompt);
					}
					dialog.remove(); // Close the dialog after loading
				},
			});

			const delBtn = $el("button", {
				textContent: "Delete",
				style: { color: "#ff6b6b" },
				onclick: async () => {
					await fetch("/comfyui-persistent-queue/delete", {
						method: "POST",
						headers: { "Content-Type": "application/json" },
						body: JSON.stringify({ prompt_id: p.prompt_id }),
					});
					renderContent();
				},
			});

			actions.append(copyBtn, saveBtn, loadBtn, delBtn);
			item.append(info, actions);
			contentArea.append(item);
		}
	}

	renderContent();
}
