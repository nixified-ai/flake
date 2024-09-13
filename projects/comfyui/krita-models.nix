# reference managed server: https://github.com/Acly/krita-ai-diffusion/blob/main/ai_diffusion/cloud_client.py
# model urls: https://github.com/Acly/krita-ai-diffusion/blob/main/ai_diffusion/resources.py
{
  installModels,
  ecosystems,
  baseModels,
}: let
  required = installModels {
    "upscale_models/4x_NMKD-Superscale-SP_178000_G.pth" = {
      url = "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth?download=true";
      sha256 = "sha256-HRsAeP5xRG4EadjU31npa6qA2DzaYA1oI31lWDCCG8w=";
    };

    "upscale_models/OmniSR_X2_DIV2K.safetensors" = {
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X2_DIV2K.safetensors?download=true";
      sha256 = "sha256-eUCPwjIDvxYfqpV8SmAsxAUh7SI1py2Xa9nTdeZkRhE=";
    };

    "upscale_models/OmniSR_X3_DIV2K.safetensors" = {
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X3_DIV2K.safetensors?download=true";
      sha256 = "sha256-T7C2j8MU95jS3c8fPSJTBFuj2VnYua4nDFqZufhi7hI=";
    };

    "upscale_models/OmniSR_X4_DIV2K.safetensors" = {
      url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X4_DIV2K.safetensors?download=true";
      sha256 = "sha256-3/JeTtOSy1y+U02SDikgY6BVXfkoHFTF7DIUkKKlmDI=";
    };

    "clip_vision/clip-vision_vit-h.safetensors" = {
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors?download=true";
      sha256 = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
      base = baseModels.sd15;
    };

    "inpaint/MAT_Places512_G_fp16.safetensors" = {
      url = "https://huggingface.co/Acly/MAT/resolve/main/MAT_Places512_G_fp16.safetensors?download=true";
      sha256 = "sha256-MJ3Wzm4EA03EtrFce9KkhE0VjgPrKhOeDsprNm5AwN4=";
    };

    "inpaint/fooocus_inpaint_head.pth" = {
      url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth?download=true";
      sha256 = "sha256-Mvf4OODG2PE0N7qEEed6RojXei4034hX5O9NUfa5dpI=";
      base = baseModels.sdxl1;
    };

    "inpaint/inpaint_v26.fooocus.patch" = {
      url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch?download=true";
      sha256 = "sha256-+GV6AlEE4i1w+cBgY12OjCGW9DOHGi9o3ECr0hcfDVk=";
      base = baseModels.sdxl1;
    };

    "controlnet/control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors?download=true";
      sha256 = "sha256-zsADaemc/tHOyX4RJM8yIN96meRTVOqh4zUMSF5lFU8=";
      base = baseModels.sd15;
    };

    "controlnet/control_v11p_sd15_inpaint_fp16.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_inpaint_fp16.safetensors?download=true";
      sha256 = "sha256-Z3pP41Ht7NQM0NfMIQqGhrWdTlUgcxfxIxnvdGp6Wok=";
      base = baseModels.sd15;
    };

    "ipadapter/ip-adapter_sd15.safetensors" = {
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors?download=true";
      sha256 = "sha256-KJtF8W0EPQv1QuRYMflx3Nqr4YtlbxHobZ37p+nuM2k=";
      base = baseModels.sd15;
    };

    "ipadapter/ip-adapter_sdxl_vit-h.safetensors" = {
      url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors?download=true";
      sha256 = "sha256-6/BdkYNIrsersCpens73fgquppFKXE6hP1DUXrFoGDE=";
      base = baseModels.sdxl1;
    };

    "loras/Hyper-SD15-8steps-CFG-lora.safetensors" = {
      url = "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SD15-8steps-CFG-lora.safetensors?download=true";
      sha256 = "sha256-9hI9W5UNUlCrbDNgDif03PcbMJnr+IhoXgHp6BF85II=";
      base = baseModels.sd15;
    };

    "loras/Hyper-SDXL-8steps-CFG-lora.safetensors" = {
      url = "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-CFG-lora.safetensors?download=true";
      sha256 = "sha256-VbUTNMhQYa//Xv98VQthljyLhgelhou+TybbSTdHGbE=";
      base = baseModels.sdxl1;
    };

    "embeddings/EasyNegative.safetensors" = {
      url = "https://huggingface.co/embed/EasyNegative/resolve/main/EasyNegative.safetensors";
      sha256 = "sha256-x0tOgQsDD2t1/elZ4ttnjCaNBxFbhTVtPAE4ul60I0A=";
      base = baseModels.sd15;
    };
  };

  defaultCheckpoints = installModels {
    "checkpoints/dreamshaper_8.safetensors" = {
      air = "urn:air:sd1:checkpoint:civitai:4384@128713";
      sha256 = "879DB523C30D3B9017143D56705015E15A2CB5628762C11D086FED9538ABD7FD";
    };

    "checkpoints/flat2DAnimerge_v45Sharp.safetensors" = {
      air = "urn:air:sd1:checkpoint:civitai:35960@266360";
      sha256 = "sha256-/pUGO6YLySmNYOslL5jQVwOdmoghWK/gQvJmvcGx5Sg=";
    };

    "checkpoints/flux1-schnell-fp8.safetensors" = {
      air = "urn:air:flux1:checkpoint:huggingface:Comfy-Org/flux1-schnell@flux1-schnell-fp8.safetensors";
      sha256 = "sha256-6tQmJ4tJAw6dpd+GKZTyXOlKsu5N84tVbd3bPbCTv3I=";
    };

    "checkpoints/juggernautXL_version6Rundiffusion.safetensors" = {
      air = "urn:air:sdxl:checkpoint:civitai:133005@198530";
      sha256 = "sha256-H+bH7FTHhgQM2rx7TolyAGnZcJaSLiDQHxPndkQStH8=";
    };

    "checkpoints/zavychromaxl_v80.safetensors" = {
      air = "urn:air:sdxl:checkpoint:civitai:119229@563988";
      sha256 = "sha256-Ha2znkA6gYxmOKjD44RDfbi66f5KN3CVWStjnZPMgQY=";
    };

    "checkpoints/realisticVisionV51_v51VAE.safetensors" = {
      air = "urn:air:sd1:checkpoint:civitai:4201@130072";
      sha256 = "sha256-FQEsU49QPOLr/CyFR7Jox1zNr/eigdtVOZlA/x1w4h0=";
    };
  };

  # these are part of the default managed server, which we'll use as a reference
  default =
    required
    // defaultCheckpoints
    // installModels {
      "upscale_models/HAT_SRx4_ImageNet-pretrain.pth" = {
        url = "https://huggingface.co/Acly/hat/resolve/main/HAT_SRx4_ImageNet-pretrain.pth";
        sha256 = "sha256-TuBTxCRhGHhG3A6Tqlq9NFkcByWo4ESlkADpLuIV6DM=";
      };

      "controlnet/control_lora_rank128_v11p_sd15_scribble_fp16.safetensors" = {
        url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_scribble_fp16.safetensors?download=true";
        sha256 = "sha256-8fAojNbUkNmXap9MNigvPUfLjgLcaAWqRLONRAT+AIo=";
        base = baseModels.sd15;
      };

      "controlnet/control_v11p_sd15_lineart_fp16.safetensors" = {
        url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_lineart_fp16.safetensors?download=true";
        sha256 = "sha256-EFWRBtG7gZYpi3qBVl7eknkpXSst8VFludvhiZlN71Y=";
        base = baseModels.sd15;
      };

      "controlnet/control_v11p_sd15_softedge_fp16.safetensors" = {
        url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_softedge_fp16.safetensors?download=true";
        sha256 = "sha256-54/qW0WZ/sLs1+PxSxcf6ykLiCAMldVp7A/1mhm8NHg=";
        base = baseModels.sd15;
      };

      "controlnet/control_v11p_sd15_canny_fp16.safetensors" = {
        url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_canny_fp16.safetensors?download=true";
        sha256 = "sha256-iTK2bhWq6DWzSQ2/mJ9WwlMQTO4IqIvyEoN2L1V8nxA=";
        base = baseModels.sd15;
      };

      "controlnet/control_lora_rank128_v11f1p_sd15_depth_fp16.safetensors" = {
        url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11f1p_sd15_depth_fp16.safetensors?download=true";
        sha256 = "sha256-egSAgFlH83eYWowmhLjlLN0mX8sltmBOqUCazgjbPTQ=";
        base = baseModels.sd15;
      };

      "controlnet/control_v1p_sd15_qrcode_monster.safetensors" = {
        url = "https://huggingface.co/monster-labs/control_v1p_sd15_qrcode_monster/resolve/main/control_v1p_sd15_qrcode_monster.safetensors";
        sha256 = "sha256-x/Q/cOJmFT0S9eG7HJ574/RRPPDu8EMmYbEzG/4Ryt8=";
        base = baseModels.sd15;
      };

      "controlnet/xinsir-controlnet-union-sdxl-1.0-promax.safetensors" = {
        url = "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors?download=true";
        sha256 = "sha256-n64uUMtDG/y+BYIrWewiKN9UXvJ/cR3qiUnp9O2ffNw=";
        base = baseModels.sdxl1;
      };
    };

  # these are optional and not part of the default managed server, but used by the plugin
  extra = installModels {
    "upscale_models/Real_HAT_GAN_sharper.pth" = {
      url = "https://huggingface.co/Acly/hat/resolve/main/Real_HAT_GAN_sharper.pth";
      sha256 = "sha256-WAC2cTYAbrjKs7TtfI1ztqGVuxjmzHCbZ0+aoGnAAnE=";
    };

    "controlnet/control_lora_rank128_v11p_sd15_normalbae_fp16.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_normalbae_fp16.safetensors?download=true";
      sha256 = "sha256-yoQBCo6DLT0uZxx2ZP80X2RfPvfoNZy8o+KzbYa8/zA=";
      base = baseModels.sd15;
    };

    "controlnet/control_lora_rank128_v11p_sd15_openpose_fp16.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_openpose_fp16.safetensors?download=true";
      sha256 = "sha256-bI7d4knmuW9smwUWokPXXritw4Yk7+FxqcirX7Gmlgg=";
      base = baseModels.sd15;
    };

    "controlnet/control_lora_rank128_v11p_sd15_seg_fp16.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_seg_fp16.safetensors?download=true";
      sha256 = "sha256-EZN5QVl6ZxUO8PdKow8IKxY0QxCA3uYJ0CMamlm3+k8=";
      base = baseModels.sd15;
    };

    "ipadapter/ip-adapter-faceid-plusv2_sdxl.bin" = {
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin?download=true";
      sha256 = "sha256-xpRdgrVDcAzDzLuY02O4N+nFligWB4V8dLcTqHba9fs=";
      base = baseModels.sdxl1;
    };

    "loras/ip-adapter-faceid-plusv2_sdxl_lora.safetensors" = {
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors?download=true";
      sha256 = "sha256-8ktLstrWY4oJwA8VHN6EmRuvN0QJOFvLq1PBhxowy3s=";
      base = baseModels.sdxl1;
    };

    "controlnet/control_sd15_inpaint_depth_hand_fp16.safetensors" = {
      url = "https://huggingface.co/hr16/ControlNet-HandRefiner-pruned/resolve/main/control_sd15_inpaint_depth_hand_fp16.safetensors?download=true";
      sha256 = "sha256-lEt0uO03ARF//lVQAmu/8shhbxySsbsv7gDlNJ/0YlY=";
      base = baseModels.sd15;
    };

    "ipadapter/ip-adapter-faceid-plusv2_sd15.bin" = {
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15.bin?download=true";
      sha256 = "sha256-JtDYah1g1syBHTuIYheLRh4e62Ueb+K3K6F6qVQR4xM=";
      base = baseModels.sd15;
    };

    "loras/ip-adapter-faceid-plusv2_sd15_lora.safetensors" = {
      url = "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15_lora.safetensors?download=true";
      sha256 = "sha256-ir/4ehWgSfPgGGwugsHI53eDuvLPtj80xBJlYFLrV7A=";
      base = baseModels.sd15;
    };

    "controlnet/mistoline_flux.dev_v1.safetensors" = {
      url = "https://huggingface.co/TheMistoAI/MistoLine_Flux.dev/resolve/main/mistoline_flux.dev_v1.safetensors";
      sha256 = "sha256-QAkoVU+hTbpBrDy9kGuihYrCSSjxVGCCztHgxNDYIEY=";
      base = baseModels.flux1-d;
    };

    "controlnet/flux-canny-controlnet-v3.safetensors" = {
      url = "https://huggingface.co/XLabs-AI/flux-controlnet-collections/resolve/main/flux-canny-controlnet-v3.safetensors";
      sha256 = "sha256-ZUbykEl5YQGmNw2wpD0mcdApQofDaytOh5LPnmjw6vA=";
      ecosystem = ecosystems.flux1;
    };

    "controlnet/flux-depth-controlnet-v3.safetensors" = {
      url = "https://huggingface.co/XLabs-AI/flux-controlnet-collections/resolve/main/flux-depth-controlnet-v3.safetensors";
      sha256 = "sha256-1S7q+Act6J1yse55473Hm115XtCmiBoCm74T2DPffl8=";
      ecosystem = ecosystems.flux1;
    };

    "vae/vae-ft-mse-840000-ema-pruned.safetensors" = {
      url = "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors";
      sha256 = "735e4c3a447a3255760d7f86845f09f937809baa529c17370d83e4c3758f3c75";
      base = baseModels.sd15;
    };

    "vae/sdxl_vae.safetensors" = {
      url = "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors";
      sha256 = "63aeecb90ff7bc1c115395962d3e803571385b61938377bc7089b36e81e92e2e";
      base = baseModels.sd15;
    };

    "vae/ae.safetensors" = {
      url = "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors";
      sha256 = "afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38";
      base = baseModels.flux1-s;
    };

    "clip/clip_l.safetensors" = {
      air = "urn:air:flux1:lora:huggingface:comfyanonymous/flux_text_encoders@clip_l.safetensors";
      sha256 = "sha256-ZgxvWxq66dxJisLSHhNH0qvbDPbAwMhXbNeWSR2abN0=";
    };

    "clip/t5-v1_1-xxl-encoder-Q5_K_M.gguf" = {
      url = "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q5_K_M.gguf";
      sha256 = "b51cbb10b1a7aac6dd1c3b62f0ed908bfd06e0b42d2f3577d43e061361f51dae";
      ecosystem = ecosystems.flux1;
    };

    "diffusion_models/flux1-schnell-Q4_0.gguf" = {
      url = "https://huggingface.co/city96/FLUX.1-schnell-gguf/resolve/main/flux1-schnell-Q4_0.gguf?download=true";
      sha256 = "sha256-kKOT06RL7GkccHAD9DT93gYGS4cLs8IG63pPEJsl/04=";
      base = baseModels.flux1-s;
    };
  };
in {
  inherit required default;
  full = default // extra;
}
