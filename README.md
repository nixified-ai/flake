# nixified.ai

The goal of nixified.ai is to simplify and make available a large repository of
AI executable code, that would otherwise be impractical to run yourself, due to
package management issues.

The main outputs of the `flake.nix` at the moment are as follows:

###### Linux

- `.#invokeai-amd`
- `.#invokeai-nvidia`

###### Windows

These outputs will run on Windows via [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)

- `.#invokeai-amd-wsl`
- `.#invokeai-nvidia-wsl`

They can be ran using `nix run`, such as `nix run .#invokeai-nvidia-wsl` on a
Windows machine via the WSL, or `nix run .#invokeai-nvidia` on a Linux host.
