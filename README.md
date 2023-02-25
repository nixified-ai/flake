# nixified.ai

The goal of nixified.ai is to simplify and make available a large repository of
AI executable code that would otherwise be impractical to run yourself, due to
package management and complexity issues.

The main outputs of the `flake.nix` at the moment are as follows:

These outputs will run on Windows via [NixOS-WSL](https://github.com/nix-community/NixOS-WSL). It is able to utilize the GPU of the Windows host automatically, as our wrapper script sets `LD_LIBRARY_PATH` to make use of the host drivers.

##### KoboldAI ( A WebUI for GPT Writing )

- `nix run .#koboldai-amd`
- `nix run .#koboldai-nvidia`

##### InvokeAI ( A Stable Diffusion WebUI )

- `nix run .#invokeai-amd`
- `nix run .#invokeai-nvidia`
