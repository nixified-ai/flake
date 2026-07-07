#!/usr/bin/env bash

cat << 'EOF'
{
  "last_node_id": 4,
  "last_link_id": 2,
  "nodes": [
    {
      "id": 1,
      "type": "LoadImage",
      "pos": [0, 0],
      "size": [315, 314],
      "flags": {},
      "order": 0,
      "mode": 0,
      "inputs": [],
      "outputs": [
        { "name": "IMAGE", "type": "IMAGE", "links": [1], "slot_index": 0 },
        { "name": "MASK", "type": "MASK", "links": null }
      ],
      "properties": { "Node name for S&R": "LoadImage" },
      "widgets_values": ["ComfyUI_00001.png", "image"]
    },
    {
      "id": 2,
      "type": "LLMTextProcessor",
      "pos": [400, 0],
      "size": [400, 500],
      "flags": {},
      "order": 1,
      "mode": 0,
      "inputs": [
        { "name": "image", "type": "IMAGE", "link": 1 }
      ],
      "outputs": [
        { "name": "RESPONSE", "type": "STRING", "links": [2], "slot_index": 0 },
        { "name": "REASONING", "type": "STRING", "links": null },
        { "name": "PERF", "type": "STRING", "links": null }
      ],
      "properties": { "Node name for S&R": "LLMTextProcessor" },
      "widgets_values": [
        "google_gemma-3-4b-it-Q4_K_M.gguf",
        "mmproj-google_gemma-3-4b-it-f16.gguf",
        "none",
        "detailed caption",
        128,
        0.7,
        0.8,
        20,
        1.0,
        4096,
        "gpu_layers",
        100,
        1,
        1,
        300,
        "off",
        true,
        ""
      ]
    },
    {
      "id": 4,
      "type": "SaveText|pysssss",
      "pos": [900, 0],
      "size": [300, 200],
      "flags": {},
      "order": 2,
      "mode": 0,
      "inputs": [
        { "name": "text", "type": "STRING", "link": 2 }
      ],
      "outputs": [],
      "properties": { "Node name for S&R": "SaveText|pysssss" },
      "widgets_values": [
        "output",
        "gemma_output.txt",
        "overwrite",
        true
      ]
    }
  ],
  "links": [
    [1, 1, 0, 2, 0, "IMAGE"],
    [2, 2, 0, 4, 0, "STRING"]
  ],
  "groups": [],
  "config": {},
  "extra": {},
  "version": 0.4
}
EOF
