
<p align="center">
<br/>
<a href="nixified.ai">
  <img src="https://github.com/nixified-ai/flake/blob/images/nixified.ai-text.png" width=60% height=60% title="nixified.ai"/>
</a>
</p>

---

The goal of nixified.ai is to simplify and make available a large repository of
AI executable code that would otherwise be impractical to run yourself, due to
package management and complexity issues.

The outputs run primarily on Linux, but can also run on Windows via [NixOS-WSL](https://github.com/nix-community/NixOS-WSL). It is able to utilize the GPU of the Windows host automatically, as our wrapper script sets `LD_LIBRARY_PATH` to make use of the host drivers.

The main outputs of the `flake.nix` at the moment are as follows:

#### KoboldAI ( A WebUI for GPT Writing )

- `nix run .#koboldai-amd`
- `nix run .#koboldai-nvidia`

![koboldai](/../images/koboldai.webp)

#### InvokeAI ( A Stable Diffusion WebUI )

- `nix run .#invokeai-amd`
- `nix run .#invokeai-nvidia`

![invokeai](/../images/invokeai.webp)
