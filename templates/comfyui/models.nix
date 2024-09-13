{
  localResources,
  ecosystems,
  baseModels,
  modelTypes,
  kritaModelInstalls,
  installModels,
}: let
  # implementation detail tip: if a resource does not require login, it is preferable to not supply it with an
  # authToken because a different fetcher will be used which has better output and supports parallel downloads.
  # WARNING: do not share the result of building comfyui if you add your token here; it will be added to the store.
  civitaiToken = null;
in
  {
    inherit
      (kritaModelInstalls.full)
      "clip/clip_l.safetensors"
      "clip/t5-v1_1-xxl-encoder-Q5_K_M.gguf"
      "diffusion_models/flux1-schnell-Q4_0.gguf"
      "loras/Hyper-SD15-8steps-CFG-lora.safetensors"
      "loras/Hyper-SDXL-8steps-CFG-lora.safetensors"
      ;
  }
  // installModels {
    # "loras/example.safetensors" = {
    #   air = "urn:air:xxxxx:lora:civitai:000000@000000";
    #   sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    #   # authToken = civitaiToken;
    # };
    # "checkpoint/example.safetensors" = {
    #   url = "...";
    #   sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    #   # authToken = otherToken;
    #   base = baseModels.flux1-d;
    # };
    # "loras/my-lora.safetensors" = {
    #   src = localResources.my-lora;
    #   base = baseModels.sd15;
    # };

    "checkpoints/photon_v1.safetensors" = {
      air = "urn:air:sd1:checkpoint:civitai:84728@90072";
      sha256 = "sha256-7EG9KoJxrN5K6BysAE2fMwDn+whw6ujL/gu8Tvjif5E=";
    };

    "checkpoints/pony-xl-v6.safetensors" = {
      air = "urn:air:pony:checkpoint:civitai:257749@290640";
      sha256 = "67AB2FD8EC439A89B3FEDB15CC65F54336AF163C7EB5E4F2ACC98F090A29B0B3";
    };

    "vae/pony-xl-v6-vae.safetensors" = {
      air = "urn:air:pony:vae:civitai:257749@290640";
      sha256 = "235745AF8D86BF4A4C1B5B4F529868B37019A10F7C0B2E79AD0ABCA3A22BC6E1";
    };

    "vae/flux1-vae.safetensors" = {
      url = "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/vae/diffusion_pytorch_model.safetensors";
      sha256 = "f5b59a26851551b67ae1fe58d32e76486e1e812def4696a4bea97f16604d40a3";
      type = modelTypes.vae;
      base = baseModels.flux1-s;
    };
  }
