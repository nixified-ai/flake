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

The outputs run primarily on Linux, but can also run on Windows via [NixOS-WSL](https://github.com/nix-community/NixOS-WSL). It is able to utilize the GPU of the Windows host automatically, as our wrapper script sets `LD_LIBRARY_PATH` to make use of the host drivers.

You can explore all this flake has to offer through the nix repl (tab-completion is your friend):
```
$ nix repl
nix-repl> :lf github:nixified-ai/flake
Added 26 variables.

nix-repl>
```

The main outputs of the `flake.nix` at the moment are as follows:

## [ComfyUI](https://github.com/comfyanonymous/ComfyUI) ( A modular, node-based Stable Diffusion WebUI )

If you want to quickly get up and running, you have the option of using the packages meant to serve the [Krita AI plugin](https://github.com/Acly/krita-ai-diffusion) (currently v1.22.0), but the flake also provides ways to customise your setup.

`export vendor=amd` or `export vendor=nvidia` depending on your GPU.

### Pre-configured server

If you want to quickly get started with a pre-configured setup, you can run these ones made to serve the Krita plugin (Krita is not required to use them):
- `nix run github:nixified-ai/flake#krita-comfyui-server-${vendor}-minimal` - includes the bare minimum requirements
- `nix run github:nixified-ai/flake#krita-comfyui-server-${vendor}` - a fully featured server to provide all functionality available through the plugin

Note that the `comfyui-${vendor}` packages come with no models or custom nodes. They serve as a base to override with your own config, as shown below.

### Custom setup

To run your own setup, you can override the base package and add what you need: `nix eval --impure --expr 'with (builtins.getFlake "github:nixified-ai/flake"); packages.x86_64-linux."comfyui-'${vendor}'".override { models = {...}; customNodes = {...}; extraArgs = ["--listen 0.0.0.0"]; ... }`.

Clearly, such expressions can become unwieldy, and for that reason there is a template you can use to put your configuration into a flake.nix: `nix flake init -t github:nixified-ai/flake#templates.comfyui`.

See [./templates/comfyui/flake.nix](./templates/comfyui/flake.nix) to get an idea of how to specify models and nodes when overriding.

Here is what is included in `legacyPackages.x86_64-linux.comfyui`:
- `models` - the full model set included in this flake (see [./projects/comfyui/models/default.nix](./projects/comfyui/models/default.nix)). Note that they are not packages, but modules. To fetch a model without adding it to a setup, build its `.src`.
- `kritaModels` - the subset of `models` relevant to the Krita plugin (see [./projects/comfyui/models/krita-ai-plugin.nix](./projects/comfyui/models/krita-ai-plugin.nix))
  - `minimal` - models expected by the plugin
  - `full` - minimal plus models needed for all optional features of the plugin
- `"${vendor}"` (anything gpu-vendor-dependent)
  - `customNodes` - the full set of available custom nodes (see [./projects/comfyui/custom-nodes/default.nix](./projects/comfyui/custom-nodes/default.nix))
  - `kritaCustomNodes` - the subset of `customNodes` relevant to the Krita plugin (see [./projects/comfyui/custom-nodes/krita-ai-plugin.nix](./projects/comfyui/custom-nodes/krita-ai-plugin.nix))

## [InvokeAI](https://github.com/invoke-ai/InvokeAI) ( A Stable Diffusion WebUI )

(warning: unmaintained - you have to use the last working commit in order to use it)
- `nix run github:nixified-ai/flake/63339e4c8727578a0fe0f2c63865f60b6e800079#invokeai-amd`
- `nix run github:nixified-ai/flake/63339e4c8727578a0fe0f2c63865f60b6e800079#invokeai-nvidia`

![invokeai](https://raw.githubusercontent.com/nixified-ai/flake/images/invokeai.webp)

## [textgen](https://github.com/oobabooga/text-generation-webui) ( Also called text-generation-webui: A WebUI for LLMs and LoRA training )

(warning: unmaintained - you have to use the last working commit in order to use it)
- `nix run github:nixified-ai/flake/63339e4c8727578a0fe0f2c63865f60b6e800079#textgen-amd`
- `nix run github:nixified-ai/flake/63339e4c8727578a0fe0f2c63865f60b6e800079#textgen-nvidia`

![textgen](https://raw.githubusercontent.com/nixified-ai/flake/images/textgen.webp)

## Install NixOS-WSL in Windows

If you're interested in running nixified.ai in the Windows Subsystem for Linux, you'll need to enable the WSL and then install NixOS-WSL via it. We provide a script that will do everything for you.

1. Execute the following in Powershell

   `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/nixified-ai/flake/master/install.ps1'))`

The WSL must be installed via the Windows Store. The script will make an attempt to enable it automatically, but this only works on a fresh system, not one that has been modified manually.

See the following documentation from Microsoft for the details on how to enable and use the WSL manually

- https://learn.microsoft.com/en-us/windows/wsl/install

## Enable binary cache

To make the binary substitution work and save you some time building packages, you need to tell nix to trust nixified-ai's binary cache.
On nixos you can do that by adding these 2 lines to `/etc/nixos/configuration.nix` and rebuilding your system:

    nix.settings.trusted-substituters = ["https://ai.cachix.org"];
    nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];

If you are on another distro, just add these two lines to `/etc/nix/nix.conf`. In fact the line `trusted-public-keys = ...` should already be there and you only need to append the key for ai.cachix.org.

    trusted-substituters = https://ai.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=


