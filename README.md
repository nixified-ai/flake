<p align="center">
<br/>
<a href="nixified.ai">
  <img src="https://github.com/nixified-ai/flake/blob/images/nixified.ai-text.png" width=60% height=60% title="nixified.ai"/>
</a>
</p>

---

## Discussion

Anyone interested in discussing nixified.ai in realtime can join our matrix channel

- In a Matrix client you can type `/join #nixified.ai:matrix.org`
- Via the web you can join via https://matrix.to/#/#nixified.ai:matrix.org

## The Goal

The goal of nixified.ai is to simplify and make available a large repository of
AI executable code that would otherwise be impractical to run yourself, due to
package management and complexity issues.

The outputs run primarily on NixOS and-or Linux, but can also run on Windows via [NixOS-WSL](https://github.com/nix-community/NixOS-WSL). It is able to utilize the GPU of the Windows host automatically, as our wrapper script sets `LD_LIBRARY_PATH` to make use of the host drivers.

You can explore all this flake has to offer through the nix repl (tab-completion is your friend):
```
$ nix repl
nix-repl> :lf github:nixified-ai/flake
Added 26 variables.

nix-repl>
```

The main outputs of the `flake.nix` at the moment are as follows:

## [ComfyUI](https://github.com/comfyanonymous/ComfyUI) ( A modular, node-based Stable Diffusion WebUI )

(warning: this will give you an empty comfyui without custom_nodes or models, see [flake-modules/projects/comfyui/README.md](./flake-modules/projects/comfyui) for information on how to configure and use comfyui)
- `nix run github:nixified-ai/flake/2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d#invokeai-nvidia`
- `nix run github:nixified-ai/flake/2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d#invokeai-amd` (Broken due to lack of Nixpkgs ROCm support)

![ComfyUI Screenshot](https://github.com/user-attachments/assets/7ccaf2c1-9b72-41ae-9a89-5688c94b7abe)

<details>
<summary>Deprecated Packages (Due to lack of funding)</summary>

## [InvokeAI](https://github.com/invoke-ai/InvokeAI) ( A Stable Diffusion WebUI )

(warning: unmaintained - you have to use the last working commit in order to use it)
- `nix run github:nixified-ai/flake/2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d#invokeai-amd`
- `nix run github:nixified-ai/flake/2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d#invokeai-nvidia`

![invokeai](https://raw.githubusercontent.com/nixified-ai/flake/images/invokeai.webp)

## [textgen](https://github.com/oobabooga/text-generation-webui) ( Also called text-generation-webui: A WebUI for LLMs and LoRA training )

(warning: unmaintained - you have to use the last working commit in order to use it)
- `github:nixified-ai/flake/2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d .#textgen-amd`
- `github:nixified-ai/flake/2aeb76f52f72c7a242f20e9bc47cfaa2ed65915d .#textgen-nvidia`

![textgen](https://raw.githubusercontent.com/nixified-ai/flake/images/textgen.webp)

</details>

## Enable binary cache

To make the binary substitution work and save you some time building packages, you need to tell nix to trust nixified-ai's binary cache.
On nixos you can do that by adding these 2 lines to `/etc/nixos/configuration.nix` and rebuilding your system:

    nix.settings.trusted-substituters = ["https://ai.cachix.org"];
    nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];

If you are on another distro, just add these two lines to `/etc/nix/nix.conf`. In fact the line `trusted-public-keys = ...` should already be there and you only need to append the key for ai.cachix.org.

    trusted-substituters = https://ai.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=


# Contributing

## License

Code in this repo was initially publish under AGPL license (apart from code in [flake-modules/packages](./flake-modules/packages), which was published under MIT), however on February 3rd 2026 a transition to MIT license has been initiated. Any contributions from that date shall be licensed under both AGPL (see [LICENSE](./LICENSE) file) and MIT (see [LICENSE-MIT](./LICENSE-MIT) file), until all significant past contributors agree to re-licensing their contributions as MIT, from which point all further contributions will be licensed exquisitely under MIT license.
