---
name: comfyui-node-adder
description: Adds new custom nodes to the ComfyUI Nix project, including npins fetching, dependency resolution in package.nix, disabling impure pip installs, and verifying the Nix build.
---
# ComfyUI Node Adder

This skill provides the procedural workflow for adding new ComfyUI custom nodes from GitHub or GitLab to this Nixified project.

## Workflow

1. **Add the Node to `npins`**:
   - Run the script via Nix: `nix run .#legacyPackages.x86_64-linux.nixified-ai.internal.add-comfyui-node -- <repository_url>`
   - This script generates a sanitized lowercase node name (e.g., `comfyui-node-name`) and updates `flake-modules/projects/comfyui/customNodes-npins/sources.json`.

2. **Analyze Dependencies**:
   - Check the target repository for a `requirements.txt` or `pyproject.toml`.
   - Identify required Python packages.

3. **Check Nixpkgs Availability**:
   - Check if dependencies exist in Nix using: `nix build .#comfyui-nvidia.passthru.python3Packages.<package_name>.pname --raw`

4. **Create `package.nix` (if needed)**:
   - Create `flake-modules/projects/comfyui/customNodes/<sanitized-node-name>/package.nix`.
   - **Do not set `pname` or `version`**. These are automatically generated from the npin source data by the `nodePropsFromNpinSource` function in `flake-modules/projects/comfyui/lib.nix`.
   - Return an attrset of overrides (e.g. `{ propagatedBuildInputs = [ ... ]; }`).
   - Include dependencies in `propagatedBuildInputs`.
   - *Note: If there are no dependencies and no impure installation scripts, a `package.nix` is generally not needed.*

5. **Disable Impure Auto-Install Logic**:
   - **Crucial:** Many ComfyUI nodes attempt to run `pip install` or `apt-get` at runtime (e.g., in `__init__.py`). This will crash in a Nix environment.
   - Patch these out using `postPatch` in the `package.nix`:
     ```nix
     postPatch = ''
       # Safely replace function calls without breaking function definitions
       # Example: replacing `install_requirements()` with `pass` only when it's called
       sed -i -e 's/^\s*install_requirements().*/pass/g' __init__.py
       
       # Or, if a function is DEFINED in the file, make it return early:
       sed -i -e 's/def install_requirements():/def install_requirements():\n    return/g' __init__.py
     '';
     ```
   - Export any environment variables that skip auto-installs (e.g., `env.DISABLE_TENSORRT_AUTO_INSTALL = "true";`).

6. **Fix Inherited Build Tools (`ninja`)**:
   - If the node inherits native build tools (like `ninja` or `cmake`) from dependencies, the Nix `buildPhase` may incorrectly attempt to compile it and fail with `ninja: error: loading 'build.ninja'`.
   - To bypass this, add to `package.nix`:
     ```nix
     dontBuild = true;
     dontConfigure = true;
     ```

7. **Verify the Build**:
   - Test the custom node derivation: `nix build .#comfyui-nvidia.passthru.comfyuiCustomNodes.<sanitized-node-name> -L --no-link`

8. **Format Code**:
   - Run `nix fmt` in the workspace root to format the newly created and modified files.

9. **Commit**:
   - Stage the changes to `sources.json` and the newly created `package.nix` files.
   - Commit the changes with an appropriate message.
