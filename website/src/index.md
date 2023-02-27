
<p align="center">
<br/>
<a href="https://nixified.ai">
  <img src="https://raw.githubusercontent.com/nixified-ai/flake/images/nixified.ai-text.png" width=60% height=60% title="nixified.ai"/>
</a>
</p>

---

## Making AI reproducible and easy to run

The goal of nixified.ai is to simplify and make available a large repository of
AI executable code that would otherwise be impractical to run yourself, due to
package management and complexity issues.

- Self-contained
- Easy to run
- Support for NVIDIA and AMD GPUs
- Works with Windows Subsystem for Linux

---

# KoboldAI

- [Official website](https://github.com/KoboldAI/KoboldAI-Client)

A browser-based front-end for AI-assisted writing with multiple local & remote AI models.

#### Get started

- `nix run github:nixified-ai/flake#koboldai-amd`
- `nix run github:nixified-ai/flake#koboldai-nvidia`

![](https://raw.githubusercontent.com/nixified-ai/flake/images/koboldai.webp)

---

# InvokeAI (A Stable Diffusion WebUI)

- [Official website](https://invoke-ai.github.io/InvokeAI/)

InvokeAI is an implementation of Stable Diffusion, the open source text-to-image and image-to-image generator. It provides a streamlined process with various new features and options to aid the image generation process.

#### Get started

- `nix run github:nixified-ai/flake#invokeai-amd`
- `nix run github:nixified-ai/flake#invokeai-nvidia`

![](https://raw.githubusercontent.com/nixified-ai/flake/images/invokeai.webp)
