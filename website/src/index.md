
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

- Self-contained, without containers:
  - Each AI project in the repository is packaged as a self-contained Nix package, including all the necessary dependencies to run the code. This guarantees that you don't have to worry about version conflicts, missing dependencies, or the state of your operating system. Nix uses an approach different from containers, which eliminates the need for complex container runtimes or virtualization.
- Easy to contribute to:
  - nixified.ai is an open-source project that welcomes contributions from the community. If there is a project you think you could help with packaging, or want packaged, then please [make an issue on GitHub](https://github.com/nixified-ai/flake/issues)
- Reproducible
  - By using a reproducible build process, nixified.ai aims to provide users with the ability to confidently run AI workloads in the long term, without worrying about the shifting sands of the software ecosystem
- Built from source
  - Each AI project in the repository is built from source, along with all of its input dependencies, ensuring that the code is reproducible and can be trusted. Nix allows advanced users to customize and modify the build process at any granularity if desired.
- Cached
  - Thanks to a Nix concept called "Binary Substitution", any `nix` command ran by the user will not need to be built from source unless they have made modifications to the source code. This is because when code is built by our CI [(Hercules CI)](https://hercules-ci.com), it is pushed to cachix.org, where it can be pulled by any `nix` client like a traditional binary distribution. If this infrastructure were to disappear however, the user could still reproduce everything locally thanks to Nix.
- Easy to run
  - Users can install and run AI executable code from the nixified.ai repository using a single `nix` command, on any distribution of Linux, and even Windows by using the Nix package manager.
- Support for NVIDIA and AMD GPUs
- Works with Windows Subsystem for Linux
  - nixified.ai provides support for running AI executable code on the Windows Subsystem for Linux (WSL), a compatibility layer for running Linux applications on Windows. With the help of [NixOS-WSL](https://github.com/nix-community/NixOS-WSL), users can run GPU-accelerated AI workloads on WSL, providing a seamless experience for users who prefer to use Windows as their primary operating system.

## Professional support

If you need your own AI project packaged in nixified.ai or need support with nixified.ai, professional support is available through the authors and contributors of the project.

Please contact [matthew.croughan@nix.how](mailto:matthew.croughan@nix.how) or [check the AUTHORS file](https://raw.githubusercontent.com/nixified-ai/flake/master/AUTHORS) for a list of contributors you can reach out to. We can assist you in your AI endeavors.

---

# Packaged Projects

### KoboldAI

- [Official website](https://github.com/KoboldAI/KoboldAI-Client)

A browser-based front-end for AI-assisted writing with multiple local & remote AI models.

#### Get started

- `nix run github:nixified-ai/flake#koboldai-amd`
- `nix run github:nixified-ai/flake#koboldai-nvidia`

![](https://raw.githubusercontent.com/nixified-ai/flake/images/koboldai.webp)

---

### InvokeAI (A Stable Diffusion WebUI)

- [Official website](https://invoke-ai.github.io/InvokeAI/)

InvokeAI is an implementation of Stable Diffusion, the open source text-to-image and image-to-image generator. It provides a streamlined process with various new features and options to aid the image generation process.

#### Get started

- `nix run github:nixified-ai/flake#invokeai-amd`
- `nix run github:nixified-ai/flake#invokeai-nvidia`

![](https://raw.githubusercontent.com/nixified-ai/flake/images/invokeai.webp)
