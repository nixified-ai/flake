---
name: huggingface-model-adder
description: Adds new HuggingFace models to the Nix project, including prefetching their sha256 hashes and validating the build.
---

# HuggingFace Model Adder Skill

This skill is designed to add new HuggingFace models to the `nixified-ai` project.

## Workflow

When the user asks to add a HuggingFace model, follow these steps:

### 1. Identify Model URLs
Determine the exact file URLs for the `.safetensors` (or other model format) files in the HuggingFace repository.
You can query the HuggingFace API to find files. Example:
```bash
curl -s "https://huggingface.co/api/models/<user>/<repo>/tree/main" | jq -r '.[] | select(.path | endswith(".safetensors")) | .path'
```
The download URL format is usually: `https://huggingface.co/<user>/<repo>/resolve/main/<file_path>`

### 2. Add to `models.nix`
Edit `flake-modules/models/models.nix` to include a new `fetchResource` entry for each model.
Leave `sha256 = "";` empty initially. Determine the correct `comfyui.installPaths` depending on whether it's a LoRA (`loras`), ControlNet (`controlnet`), Checkpoint (`checkpoints`), etc.

Example entry:
```nix
  my-model-attr-name = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/.../resolve/main/model.safetensors";
    sha256 = "";
    passthru = {
      comfyui.installPaths = [ "loras" ]; # Adjust appropriately
    };
  };
```

### 3. Prefetch `sha256` Hashes
To obtain the `sha256` hash for the newly added model, you MUST use `nix-prefetch-url` with the `--name model` argument. This is crucial because the fixed output derivation created by the model helper function always sets the derivation name to "model", which affects the resulting hash.

Run the following command, evaluating the URL from the Nix file:
```bash
nix-prefetch-url --type sha256 --name model "$(nix eval .#legacyPackages.x86_64-linux.nixified-ai.models.MODEL_ATTR_NAME.url --raw)"
```

### 4. Update the Hashes
Replace the empty `sha256 = "";` strings in `flake-modules/models/models.nix` with the hashes returned by the prefetch step.

### 5. Format and Build
1. Format the codebase:
   ```bash
   nix fmt
   ```
2. Build the model to verify it evaluates and downloads correctly:
   ```bash
   nix build ".#legacyPackages.x86_64-linux.nixified-ai.models.MODEL_ATTR_NAME"
   ```
   (Run this for each added model)

### 6. Commit
Once verified, commit the changes describing the newly added models.
