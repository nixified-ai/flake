### Configuring (NixOS)

The best way to use comfyui with this flake, is to use the `nixosModule` provided by it. This allows you, on NixOS to add a small amount of configuration to the NixOS system like below. In addition to being easy to use and configure, this runs as a systemd service that is sandboxed from the rest of your system, with robust hardening, so you will be unlikely to fall victim to the kinds of security issues comfyui has become notorious for.

State (outputs of comfyui) will be stored in `/var/lib/comfyui/.local/share/comfyui` by default, but read the NixOS module source code to figure out what else the module can do.

```
{
  services.comfyui = {
    enable = true;
    package = pkgs.comfyui-nvidia;
    host = "0.0.0.0";
    models = builtins.attrValues pkgs.nixified-ai.models;
    customNodes = with comfyui.pkgs; [
      comfyui-gguf
      comfyui-impact-pack
    ];
  };
}
```

To gain the ability to add comfyui to your config like above, enable the filestash module on a nixosConfiguration in your NixOS system's `flake.nix`:

```
{
  inputs.nixified-ai.url = "github:matthewcroughan/nixified-ai";
  outputs = { self, nixpkgs, nixified-ai }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [
        nixified-ai.nixosModules.comfyui

        # You can put this in a file like `./configuration.nix` and import it
        # in the list, or discretely perform it in your `modules` argument
        {
          services.comfyui.enable = true;
        }
      ];
    };
  };
}
```

### Configuring (Without NixOS)

This is not recommended, and not officially supported due to a lack of project funding, resources and contribution. It is unlikely that direct advice on the topic will be given by project maintainers beyond this document, so it is encouraged that Non-NixOS users help eachother [in the matrix community](https://matrix.to/#/#nixified.ai:matrix.org)

Running outside of systemd/NixOS is especially unrecommended due to custom_nodes security concerns, as it will run as your user, rather than as a completely sandboxed DynamicUser under systemd/NixOS.

To run your own setup, you can override the base package and add what you need: `nix eval --impure --expr 'with (builtins.getFlake "github:nixified-ai/flake"); packages.x86_64-linux."comfyui-'${vendor}'".override { withModels = {...}; withCustomNodes = {...}; }`.

Clearly, such expressions can become unwieldy, and for that reason there is a template you can use to put your configuration into a flake.nix: `nix flake init -t github:nixified-ai/flake#templates.comfyui`.

See [./template/flake.nix](./template/flake.nix) to get an idea of how to specify models and nodes when overriding.
