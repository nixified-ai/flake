{fetchFromHuggingFace}:
with {inherit (import ./meta.nix) base-models model-types;}; let
  fetchFromUrl = import <nix/fetchurl.nix>;
in {
  # https://huggingface.co/Comfy-Org/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors
  flux1-schnell-fp8 = {
    installPath = "checkpoints/flux1-schnell-fp8.safetensors";
    src = fetchFromHuggingFace {
      owner = "Comfy-Org";
      repo = "flux1-schnell";
      resource = "flux1-schnell-fp8.safetensors";
      sha256 = "sha256-6tQmJ4tJAw6dpd+GKZTyXOlKsu5N84tVbd3bPbCTv3I=";
    };
    type = checkpoint;
    base = flux;
  };

  # https://huggingface.co/Acly/SD-Checkpoints/resolve/main/flat2DAnimerge_v45Sharp.safetensors
  flat2DAnimerge_v45Sharp = {
    installPath = "checkpoints/flat2DAnimerge_v45Sharp.safetensors";
    src = fetchFromHuggingFace {
      owner = "Acly";
      repo = "SD-Checkpoints";
      resource = "flat2DAnimerge_v45Sharp.safetensors";
      sha256 = "sha256-/pUGO6YLySmNYOslL5jQVwOdmoghWK/gQvJmvcGx5Sg=";
    };
    type = checkpoint;
    base = sd15;
  };

  # https://civitai.com/models/119229?modelVersionId=563988
  # Consider using DPM++ 3M SDE Exponential for this model
  # TIPS
  # To maintain optimal results and avoid excessive duplication of subjects, limit the generated image size to a maximum of 1024x1024 pixels or 640x1536 (or vice versa). If you require higher resolutions, it is recommended to utilise the Hires fix, followed by the img2img upscale technique, with particular emphasis on the controlnet tile upscale method. This approach will help you achieve superior results when aiming for higher resolution outputs. However, as this workflow doesn't work with SDXL yet, you may want to use an SD1.5 model for the img2img step.
  # PROMPTS
  # Recommended positive prompts for specifically photorealism: 2000s vintage RAW photo, photorealistic, film grain, candid camera, color graded cinematic, eye catchlights, atmospheric lighting, macro shot, skin pores, imperfections, natural, shallow dof, or other photography related tokens.
  # Recommended negative prompts: As few negative prompts as you can, only use it when it does something you do not want, like watermarks. Consider using high contrast, oily skin, plastic skin if the skin is too contrasting or too oily/plastic. Also make sure to add anime to negative prompt if you want better photorealism, and more mature looking characters.
  # You are further encouraged to include additional specific details regarding the desired output. This should involve specifying the preferred style, camera angle, lighting techniques, poses, color schemes, and other relevant factors.
  # Recommended settings
  #     sdxl_vae.safetensors (baked in).
  #     DPM++ 3M SDE Exponential, DPM++ 2M SDE Karras, DPM++ 2M Karras, Euler A
  #     Steps 20~40 (lower range for DPM, higher range for Euler).
  #     Hires upscaler: UltraMix_Balanced.
  #     Hires upscale: Whatever maximum your GPU is capable of, but preferably between 1.5x~2x.
  #     CFG scale 4-10 (preferably somewhere around cfg 6-7)
  # Lightning LoRA specific settings:
  #     Euler sampler with SGM Uniform as Scheduler.
  #     Steps 4 (use the 4 steps LoRA)
  #     CFG scale 1-2 (CFG 1 at the higher weights for the LoRA)
  #     LoRA weight 0.6-1
  zavy-chroma-xl = {
    installPath = "checkpoints/zavychromaxl_v80.safetensors";
    src = fetchFromUrl {
      name = "zavychromaxl_v80";
      url = "https://civitai.com/api/download/models/563988?type=Model&format=SafeTensor&size=full&fp=fp16";
      sha256 = "sha256-Ha2znkA6gYxmOKjD44RDfbi66f5KN3CVWStjnZPMgQY=";
    };
    type = checkpoint;
    base = sdxl;
  };

  realisticVisionV51_v51VAE = {
    installPath = "checkpoints/realisticVisionV51_v51VAE.safetensors";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "fav_models";
      resource = "fav/realisticVisionV51_v51VAE.safetensors";
      sha256 = "sha256-FQEsU49QPOLr/CyFR7Jox1zNr/eigdtVOZlA/x1w4h0=";
    };
    type = checkpoint;
    base = sd15;
  };

  DreamShaper_8_pruned = {
    installPath = "checkpoints/DreamShaper_8_pruned.safetensors";
    src = fetchFromHuggingFace {
      owner = "Lykon";
      repo = "DreamShaper";
      resource = "DreamShaper_8_pruned.safetensors";
      sha256 = "sha256-h521I8MNO5AXFD1WcFAV4VostWKHYsEdCG/tlTir1/0=";
    };
    type = checkpoint;
    base = sd15;
  };

  juggernautXL_version6Rundiffusion = {
    installPath = "checkpoints/juggernautXL_version6Rundiffusion.safetensors";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "fav_models";
      resource = "fav/juggernautXL_version6Rundiffusion.safetensors";
      sha256 = "sha256-H+bH7FTHhgQM2rx7TolyAGnZcJaSLiDQHxPndkQStH8=";
    };
    type = checkpoint;
    base = sdxl;
  };

  # https://civitai.com/models/84728/photon
  # photorealism
  # Recommendation for generating the first image with Photon:
  #     Prompt: A simple sentence in natural language describing the image.
  #     Negative: "cartoon, painting, illustration, (worst quality, low quality, normal quality:2)"
  #     Sampler: DPM++ 2M Karras | Steps: 20 | CFG Scale: 6
  #     Size: 512x768 or 768x512
  #     Hires.fix: R-ESRGAN 4x+ | Steps: 10 | Denoising: 0.45 | Upscale x 2
  #     (avoid using negative embeddings unless absolutely necessary)
  # From this initial point, experiment by adding positive and negative tags and adjusting the settings.
  photon = {
    installPath = "checkpoints/photon_v1.safetensors";
    src = fetchFromUrl {
      name = "photon_v1.safetensors";
      url = "https://civitai.com/api/download/models/90072?type=Model&format=SafeTensor&size=pruned&fp=fp16";
      sha256 = "sha256-7EG9KoJxrN5K6BysAE2fMwDn+whw6ujL/gu8Tvjif5E=";
    };
    type = checkpoint;
    base = sd15;
  };

  # A high quality checkpoint but beware it also does nsfw very
  # easily.
  # https://civitai.com/models/147720/colossus-project-xl-sfwandnsfw
  # Some notes on usage, from the description:
  # Be aware that some samplers aren't working. Don't use following samplers:
  # DPM++ 2M Karras, DPM++ 2M,DPM++ 2M, DPM++ 2M SDE, DPM++ 2M SDE Heun,
  # Euler, LMS, LMS Karras, Heun, 3M SDE Karras, DPM fast, DPM2 Karras,
  # Restart, PLMS, DDIM, Uni PC, LCM, LCM Karras.
  # Recommended sampler:
  # In my tests DPM 2 a and DPM++ 2S a worked really good for fine
  # details. You can also use the Karras versions of these samplers. Also
  # DPM++ SDE, DPM++ SDE Karras, Euler a, Euler a Turbo, DDPM, DDPM
  # Karras, DPM++ 2M Turbo, DPM++ 2M SDE Heun Exponential worked great in
  # my tests.
  #
  # Keep the CFG around 2-4.
  colossus-xl-v6 = {
    installPath = "checkpoints/colossus-xl-v6.safetensors";
    src = fetchFromUrl {
      name = "colossus-xl-v6";
      url = "https://civitai.com/api/download/models/355884";
      sha256 = "sha256-ZymMt9jS1Z698wujJGxEMQZeyt0E97qaOtLfDdWjhuc=";
    };
    type = checkpoint;
    base = sdxl;
  };

  # https://civitai.com/models/112902/dreamshaper-xl
  # Preferred settings:
  # CFG = 2
  # 4-8 sampling steps.
  # Sampler: DPM SDE Kerras (not 2M).
  # ComfyUI workflow for upscaling: https://pastebin.com/79XN01xs
  dreamshaper-xl-fp16 = {
    installPath = "checkpoints/dreamshaper-xl-fp16.safetensors";
    src = fetchFromUrl {
      name = "dreamshaper-xl-fp16";
      url = "https://civitai.com/api/download/models/351306";
      sha256 = "sha256-RJazbUi/18/k5dvONIXbVnvO+ivvcjjSkNvUVhISUIM=";
    };
    type = checkpoint;
    base = sdxl;
  };

  # Pony generates some really high quality images - they tend to be more
  # based on a digital painting style but can do other things as well.
  # This makes it an excellent model for generating characters.
  # WARNING:  Pony is capable of generating some _very_ NSFW
  # images.  You should be able to use the negative prompt "nsfw" and
  # perhaps others to avoid this.
  pony-xl-v6 = {
    installPath = "checkpoints/pony-xl-v6.safetensors";
    src = fetchFromUrl {
      name = "pony-xl-v6";
      url = "https://civitai.com/api/download/models/290640?type=Model&format=SafeTensor&size=pruned&fp=fp16";
      sha256 = "1cxh5450k3y9mkrf9dby7hbaydj3ymjwq5fvzsrqk6j3xkc2zav7";
    };
    type = checkpoint;
    base = sdxl;
  };

  # Allow for video from images.  See
  # https://comfyanonymous.github.io/ComfyUI_examples/video/ for the
  # official ComfyUI documentation.
  stable-video-diffusion-img2vid = {
    installPath = "checkpoints/stable-video-diffusion-img2vid.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "stable-video-diffusion-img2vid";
      resource = "svd.safetensors";
      sha256 = "sha256-PgmUYm3zlaODHeAk8RstnSQRQ7tvFuLvusztJIqhjOA=";
    };
    type = checkpoint;
    base = svd;
  };
  stable-video-diffusion-img2vid-xt = {
    installPath = "checkpoints/stable-video-diffusion-img2vid-xt.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "stable-video-diffusion-img2vid-xt";
      resource = "svd_xt.safetensors";
      sha256 = "b2652c23d64a1da5f14d55011b9b6dce55f2e72e395719f1cd1f8a079b00a451";
    };
    type = checkpoint;
    base = svdxt;
  };

  MAT_Places512_G_fp16 = {
    installPath = "inpaint/MAT_Places512_G_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "Acly";
      repo = "MAT";
      resource = "MAT_Places512_G_fp16.safetensors";
      sha256 = "sha256-MJ3Wzm4EA03EtrFce9KkhE0VjgPrKhOeDsprNm5AwN4=";
    };
    type = inpaint;
  };

  fooocus_inpaint_head = {
    installPath = "inpaint/fooocus_inpaint_head.pth";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "fooocus_inpaint";
      resource = "fooocus_inpaint_head.pth";
      sha256 = "sha256-Mvf4OODG2PE0N7qEEed6RojXei4034hX5O9NUfa5dpI=";
    };
    type = inpaint;
  };

  inpaint_v26-fooocus = {
    installPath = "inpaint/inpaint_v26.fooocus.patch";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "fooocus_inpaint";
      resource = "inpaint_v26.fooocus.patch";
      sha256 = "sha256-+GV6AlEE4i1w+cBgY12OjCGW9DOHGi9o3ECr0hcfDVk=";
    };
    type = inpaint;
  };

  CLIP-ViT-H-14-laion2B-s32B-b79K = {
    installPath = "clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/image_encoder/model.safetensors";
      sha256 = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
    };
    type = clip_vision;
  };

  CLIP-ViT-bigG-14-laion2B-39B-b160k = {
    installPath = "clip_vision/CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "sdxl_models/image_encoder/model.safetensors";
      sha256 = "sha256-ZXcj4J9Gp8OVffZRYBAp9msXSK+xK0GYFjMPFu1F1k0=";
    };
    type = clip_vision;
    base = sdxl;
  };

  clip_vision-sd15 = {
    installPath = "clip_vision/clip-vision_vit-h.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/image_encoder/model.safetensors";
      sha256 = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
    };
    type = clip_vision;
    base = sd15;
  };

  # https://huggingface.co/TheMistoAI/MistoLine
  mistoline = {
    installPath = "controlnet/mistoLine_rank256.safetensors";
    src = fetchFromHuggingFace {
      owner = "TheMistoAI";
      repo = "MistoLine";
      resource = "mistoLine_rank256.safetensors";
      sha256 = "sha256-bEbIcaSb+edBFPDh+H2BhCYgP9YoR+eAQ+TOLUCDTVM=";
    };
    type = controlnet;
    base = sdxl;
  };

  # https://huggingface.co/lllyasviel/sd_control_collection
  sai_xl_canny_256lora = {
    installPath = "controlnet/sai_xl_canny_256lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "sd_control_collection";
      resource = "sai_xl_canny_256lora.safetensors";
      sha256 = "sha256-ySaXIbH3BDYl51t94vZaYRayrZmJWWVJRhbz8shUj1Q=";
    };
    type = controlnet;
    base = sdxl;
  };

  # A controlnet which supports many control types in condition text-to-image generation, such as:
  # - Tile Deblur
  # - Tile Variation
  # - Tile Super Resolution
  # - Image Inpainting
  # - Image Outpainting
  # - Openpose
  # - Depth
  # - Canny
  # - Lineart
  # - AnimeLineart
  # - Mlsd
  # - Scribble
  # - Hed
  # - Pidi(Softedge)
  # - Teed
  # - Segment
  # - Normal
  # https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/blob/main/diffusion_pytorch_model_promax.safetensors
  xinsir-controlnet-union-sdxl-promax = {
    installPath = "controlnet/xinsir-controlnet-union-sdxl-1.0-promax.safetensors";
    src = fetchFromHuggingFace {
      owner = "xinsir";
      repo = "controlnet-union-sdxl-1.0";
      resource = "diffusion_pytorch_model_promax.safetensors";
      sha256 = "sha256-n64uUMtDG/y+BYIrWewiKN9UXvJ/cR3qiUnp9O2ffNw=";
    };
    type = controlnet;
    base = sdxl;
  };

  # https://huggingface.co/xinsir/controlnet-canny-sdxl-1.0/blob/main/diffusion_pytorch_model_V2.safetensors
  xinsir-canny-xl-v2 = {
    installPath = "controlnet/xinsircanny-xl-v2.safetensors";
    src = fetchFromHuggingFace {
      owner = "xinsir";
      repo = "controlnet-canny-sdxl-1.0";
      resource = "diffusion_pytorch_model_V2.safetensors";
      sha256 = "sha256-s+SsR7yBQBnVDchC9XkwFEDettjwnuG5GjD1J6zhuFI=";
    };
    type = controlnet;
    base = sdxl;
  };

  # https://huggingface.co/depth-anything/Depth-Anything-V2-Base
  depth_anything_v2_vitb = {
    installPath = "controlnet/depth_anything_v2_vitb.pth";
    src = fetchFromHuggingFace {
      owner = "depth-anything";
      repo = "Depth-Anything-V2-Base";
      resource = "depth_anything_v2_vitb.pth";
      sha256 = "sha256-DStwAuYtOdZVVxw3EzM0C9iPZ6uVBQwDWRVVqgVkUyg=";
    };
    type = controlnet;
  };

  # https://huggingface.co/TencentARC/PhotoMaker
  # for preserving character identity
  photomaker = {
    installPath = "photomaker/photomaker-v1.bin";
    src = fetchFromHuggingFace {
      owner = "TencentARC";
      repo = "PhotoMaker";
      resource = "photomaker-v1.bin";
      sha256 = "sha256-Up1QP6N4v7OnTjOEqyBk1yadWfBjgyRVXSIGfDHidbw=";
    };
    # type = "???";
    base = sdxl; # ?
  };

  # https://huggingface.co/lllyasviel/ControlNet-v1-1
  # https://github.com/lllyasviel/ControlNet-v1-1-nightly
  # See also the accompanying controlnet-v1_1_f1e-sd15-tile.
  controlnet-v1_1_f1e-sd15-tile-config = {
    installPath = "configs/controlnet-v1_1_fe-sd15-tile.yaml";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "ControlNet-v1-1";
      resource = "control_v11f1e_sd15_tile.yaml";
      sha256 = "sha256-OeEzjEFDYYrbF2BPlsOj90DBq10VV9cbBE8DB6CmrbQ=";
    };
    type = config;
    base = sd15;
  };

  # https://huggingface.co/lllyasviel/ControlNet-v1-1
  # See also the accompanying controlnet-v1_1_f1e-sd15-tile-config.
  controlnet-v1_1_f1e-sd15-tile = {
    installPath = "controlnet/controlnet-v1_1_f1e-sd15-tile.pth";
    src = fetchFromHuggingFace {
      owner = "lllyasviel";
      repo = "ControlNet-v1-1";
      resource = "control_v11f1e_sd15_tile.pth";
      sha256 = "sha256-iqabjTkecsL87WplAmgTfcDtWUyv6KLA+LmUeZohl5s=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11p_sd15_openpose_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_openpose_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_openpose_fp16.safetensors";
      sha256 = "sha256-bI7d4knmuW9smwUWokPXXritw4Yk7+FxqcirX7Gmlgg=";
    };
    type = controlnet;
  };

  control_v11p_sd15_inpaint_fp16 = {
    installPath = "controlnet/control_v11p_sd15_inpaint_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_v11p_sd15_inpaint_fp16.safetensors";
      sha256 = "sha256-Z3pP41Ht7NQM0NfMIQqGhrWdTlUgcxfxIxnvdGp6Wok=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11f1e_sd15_tile_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors";
      sha256 = "sha256-zsADaemc/tHOyX4RJM8yIN96meRTVOqh4zUMSF5lFU8=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11p_sd15_scribble_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_scribble_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_scribble_fp16.safetensors";
      sha256 = "sha256-8fAojNbUkNmXap9MNigvPUfLjgLcaAWqRLONRAT+AIo=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11p_sd15_lineart_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_lineart_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_lineart_fp16.safetensors";
      sha256 = "sha256-nTqRttVaMSNIPesJ9xzFWKC9VOXsQUL1GHmE29LgmdE=";
    };
    type = controlnet;
    base = sd15;
  };

  control_v11p_sd15_lineart_fp16 = {
    installPath = "controlnet/control_v11p_sd15_lineart_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_v11p_sd15_lineart_fp16.safetensors";
      sha256 = "sha256-EFWRBtG7gZYpi3qBVl7eknkpXSst8VFludvhiZlN71Y=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11p_sd15_softedge = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_softedge.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_softedge_fp16.safetensors";
      sha256 = "sha256-AQiSrKkewwKOtms0troweabbVNqF7UsI8XLg0Gr5sX0=";
    };
    type = controlnet;
    base = sd15;
  };

  control_v11p_sd15_softedge_fp16 = {
    installPath = "controlnet/control_v11p_sd15_softedge_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_v11p_sd15_softedge_fp16.safetensors";
      sha256 = "sha256-54/qW0WZ/sLs1+PxSxcf6ykLiCAMldVp7A/1mhm8NHg=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11p_sd15_canny = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_canny.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_canny_fp16.safetensors";
      sha256 = "sha256-RQU9NBrDbYVZrTAUOPwIsyBCHngqXsiIirivFrd2PGs=";
    };
    type = controlnet;
    base = sd15;
  };

  control_v11p_sd15_canny_fp16 = {
    installPath = "controlnet/control_v11p_sd15_canny_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_v11p_sd15_canny_fp16.safetensors";
      sha256 = "sha256-iTK2bhWq6DWzSQ2/mJ9WwlMQTO4IqIvyEoN2L1V8nxA=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11f1p_sd15_depth_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11f1p_sd15_depth_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11f1p_sd15_depth_fp16.safetensors";
      sha256 = "sha256-egSAgFlH83eYWowmhLjlLN0mX8sltmBOqUCazgjbPTQ=";
    };
    type = controlnet;
    base = sd15;
  };

  control_lora_rank128_v11p_sd15_normalbae_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_normalbae_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_normalbae_fp16.safetensors";
      sha256 = "sha256-yoQBCo6DLT0uZxx2ZP80X2RfPvfoNZy8o+KzbYa8/zA=";
    };
    type = controlnet;
    base = sd15;
  };

  # https://huggingface.co/xinsir/controlnet-openpose-sdxl-1.0/blob/main/
  xinsir-openpose-xl = {
    installPath = "controlnet/xinsiropenpose_xl.safetensors";
    src = fetchFromHuggingFace {
      owner = "xinsir";
      repo = "controlnet-openpose-sdxl-1.0";
      resource = "diffusion_pytorch_model.safetensors";
      sha256 = "sha256-uFJOVXp99g0IH11KDrEJln0QffIXlDv4jC2ZuevMBsU=";
    };
    type = controlnet;
    base = sdxl;
  };

  control-lora-openposexl2-rank = {
    installPath = "controlnet/control-lora-openposexl2-rank.safetensors";
    src = fetchFromHuggingFace {
      owner = "thibaud";
      repo = "controlnet-openpose-sdxl-1.0";
      resource = "control-lora-openposeXL2-rank256.safetensors";
      sha256 = "sha256-ivoHkoW/k4Tq+PYyKITLTyS75AXaSQ+R9VQNO/9YXnU=";
    };
    type = controlnet;
    base = sdxl;
  };

  control_lora_rank128_v11p_sd15_openpose = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_openpose.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_openpose_fp16.safetensors";
      sha256 = "sha256-bI7d4knmuW9smwUWokPXXritw4Yk7+FxqcirX7Gmlgg=";
    };
    type = controlnet;
    base = sd15;
  };

  # https://huggingface.co/abovzv/sdxl_segmentation_controlnet_ade20k
  sdxl_segmentation_controlnet_ade20k = {
    installPath = "controlnet/sdxl_segmentation_ade20k_controlnet.safetensors";
    src = fetchFromHuggingFace {
      owner = "abovzv";
      repo = "sdxl_segmentation_controlnet_ade20k";
      resource = "sdxl_segmentation_ade20k_controlnet.safetensors";
      sha256 = "sha256-cOLDkmMQIrW+ljoZHAgTHPg5fjTHdMfm0r56q+Z+H8o=";
    };
    type = controlnet;
    base = sdxl;
  };

  control_lora_rank128_v11p_sd15_seg_fp16 = {
    installPath = "controlnet/control_lora_rank128_v11p_sd15_seg_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "comfyanonymous";
      repo = "ControlNet-v1-1_fp16_safetensors";
      resource = "control_lora_rank128_v11p_sd15_seg_fp16.safetensors";
      sha256 = "sha256-EZN5QVl6ZxUO8PdKow8IKxY0QxCA3uYJ0CMamlm3+k8=";
    };
    type = controlnet;
    base = sd15;
  };

  # https://huggingface.co/monster-labs/control_v1p_sdxl_qrcode_monster
  control_v1p_sdxl_qrcode_monster = {
    installPath = "controlnet/control_v1p_sdxl_qrcode_monster.safetensors";
    src = fetchFromHuggingFace {
      owner = "monster-labs";
      repo = "control_v1p_sdxl_qrcode_monster";
      resource = "diffusion_pytorch_model.safetensors";
      sha256 = "sha256-EeSbTicvq9pgCUs1vm/T4hXlUSESEJOOOB0nSX/SIVw=";
    };
    type = controlnet;
    base = sdxl;
  };

  control_v1p_sd15_qrcode_monster = {
    installPath = "controlnet/control_v1p_sd15_qrcode_monster.safetensors";
    src = fetchFromHuggingFace {
      owner = "monster-labs";
      repo = "control_v1p_sd15_qrcode_monster";
      resource = "control_v1p_sd15_qrcode_monster.safetensors";
      sha256 = "sha256-x/Q/cOJmFT0S9eG7HJ574/RRPPDu8EMmYbEzG/4Ryt8=";
    };
    type = controlnet;
    base = sd15;
  };

  control_sd15_inpaint_depth_hand_fp16 = {
    installPath = "controlnet/control_sd15_inpaint_depth_hand_fp16.safetensors";
    src = fetchFromHuggingFace {
      owner = "hr16";
      repo = "ControlNet-HandRefiner-pruned";
      resource = "control_sd15_inpaint_depth_hand_fp16.safetensors";
      sha256 = "sha256-lEt0uO03ARF//lVQAmu/8shhbxySsbsv7gDlNJ/0YlY=";
    };
    type = controlnet;
    base = sd15;
  };

  control-lora-sketch-rank = {
    installPath = "controlnet/control-lora-sketch-rank.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "control-lora";
      resource = "control-LoRAs-rank128/control-lora-sketch-rank128-metadata.safetensors";
      sha256 = "sha256-Z5xhaAeuxzxHu3KBokp23f5S+ltdaFMvVCq4EzR7Lq4=";
    };
    type = controlnet;
    base = sdxl;
  };

  control-lora-recolor-rank = {
    installPath = "controlnet/control-lora-recolor-rank.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "control-lora";
      resource = "control-LoRAs-rank128/control-lora-recolor-rank128.safetensors";
      sha256 = "sha256-1sAdWIVQ1Bq0f/JTSuE1RB7Y5hS3KzFnh+i3kWzgjmE=";
    };
    type = controlnet;
    base = sdxl;
  };

  # https://huggingface.co/xinsir/controlnet-scribble-sdxl-1.0
  xinsir-scribble-sdxl = {
    installPath = "controlnet/xinsirscribble-sdxl.safetensors";
    src = fetchFromHuggingFace {
      owner = "xinsir";
      repo = "controlnet-scribble-sdxl-1.0";
      resource = "diffusion_pytorch_model.safetensors";
      sha256 = "sha256-s+SsR7yBQBnVDchC9XkwFEDettjwnuG5GjD1J6zhuFI=";
    };
    type = controlnet;
    base = sdxl;
  };

  control-lora-canny-rank = {
    installPath = "controlnet/control-lora-canny-rank.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "control-lora";
      resource = "control-LoRAs-rank128/control-lora-canny-rank128.safetensors";
      sha256 = "sha256-VjiduyRcpE3pHWYlKb1CmKvFXOIxj2C8GUVPty/2gkc=";
    };
    type = controlnet;
    base = sdxl;
  };

  control-lora-depth-rank = {
    installPath = "controlnet/control-lora-depth-rank.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "control-lora";
      resource = "control-LoRAs-rank128/control-lora-depth-rank128.safetensors";
      sha256 = "sha256-N+ORdX5sAEL6o3lRdKy+EaMZkiUgWM+4u6zPEQc1Z7Q=";
    };
    type = controlnet;
    base = sdxl;
  };

  # https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic_V1
  ttplanet_sdxl_controlnet_tile_realistic = {
    installPath = "controlnet/ttplanet_sdxl_controlnet_tile_realistic.safetensors";
    src = fetchFromHuggingFace {
      owner = "TTPlanet";
      repo = "TTPLanet_SDXL_Controlnet_Tile_Realistic_V1";
      resource = "TTPLANET_Controlnet_Tile_realistic_v1_fp16.safetensors";
      sha256 = "sha256-+ipfL+yBSBnINUA8d4viwkN9FHkxkhMEVp/M7CtFFzw=";
    };
    type = controlnet;
    base = sdxl;
  };

  # Basic model, average strength
  ip-adapter_sd15 = {
    installPath = "ipadapter/ip-adapter_sd15.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/ip-adapter_sd15.safetensors";
      sha256 = "sha256-KJtF8W0EPQv1QuRYMflx3Nqr4YtlbxHobZ37p+nuM2k=";
    };
    type = ipadapter;
    base = sd15;
  };

  # SDXL model
  ip-adapter_sdxl_vit-h = {
    installPath = "ipadapter/ip-adapter_sdxl_vit-h.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "sdxl_models/ip-adapter_sdxl_vit-h.safetensors";
      sha256 = "sha256-6/BdkYNIrsersCpens73fgquppFKXE6hP1DUXrFoGDE=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # Light impact model
  ip-adapter_sd15_light_v11 = {
    installPath = "ipadapter/ip-adapter_sd15_light_v11.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/ip-adapter_sd15_light_v11.bin";
      sha256 = "sha256-NQtjpXhHwWPi6YSwEJD4X/5g6q4g8ysrLJ4czH3dlys=";
    };
    type = ipadapter;
    base = sd15;
  };

  # Plus model, very strong
  ip-adapter-plus_sd15 = {
    installPath = "ipadapter/ip-adapter-plus_sd15.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/ip-adapter-plus_sd15.safetensors";
      sha256 = "sha256-ocJQvkBFXMYaQ9oSAew/HtrqcSFIZftH9Xkn4Gy+SZY=";
    };
    type = ipadapter;
    base = sd15;
  };

  # Face model, portraits
  ip-adapter-plus-face_sd15 = {
    installPath = "ipadapter/ip-adapter-plus-face_sd15.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/ip-adapter-plus-face_sd15.safetensors";
      sha256 = "sha256-HJ7cIa9vc33B1uDnNBkOl2z6z4AtawJLd6o76SL3Vps=";
    };
    type = ipadapter;
    base = sd15;
  };

  # Stronger face model, not necessarily better
  ip-adapter-full-face_sd15 = {
    installPath = "ipadapter/ip-adapter-full-face_sd15.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/ip-adapter-full-face_sd15.safetensors";
      sha256 = "sha256-9KF/tkO/h2I1pFoOh6SdooVb5lhLKMoExiqXq1/xxvM=";
    };
    type = ipadapter;
    base = sd15;
  };

  # Base model, requires bigG clip vision encoder
  ip-adapter_sd15_vit-G = {
    installPath = "ipadapter/ip-adapter_sd15_vit-G.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "models/ip-adapter_sd15_vit-G.safetensors";
      sha256 = "sha256-om9zavB7s0GoPf6iNxNTHQV1dg6O2UfGjLMaTGLZyQs=";
    };
    type = ipadapter;
    base = sd15;
  };

  # SDXL plus model
  ip-adapter-plus_sdxl_vit-h = {
    installPath = "ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors";
      sha256 = "sha256-P1BiuEAMlLcVlmWyG6XGKs3NdoImJ0PX8q7+3vAOZYE=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # SDXL face model
  ip-adapter-plus-face_sdxl_vit-h = {
    installPath = "ipadapter/ip-adapter-plus-face_sdxl_vit-h.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors";
      sha256 = "sha256-Z3rYhgIE99C/uhLSnmwx3tm+798+S70QJRg1fTGiksE=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # vit-G SDXL model, requires bigG clip vision encoder
  ip-adapter_sdxl = {
    installPath = "ipadapter/ip-adapter_sdxl.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter";
      resource = "sdxl_models/ip-adapter_sdxl.safetensors";
      sha256 = "sha256-uhACUp54NgTF8ybUnwEiAlOS0dIKyNVzs+6z5t6k67Y=";
    };
    type = ipadapter;
    base = sdxl;
  };

  ## FaceID models (these require the insightface python package, and most require specific loras)

  # base FaceID model
  ip-adapter-faceid_sd15 = {
    installPath = "ipadapter/ip-adapter-faceid_sd15.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid_sd15.bin";
      sha256 = "sha256-IBNE4i5vVYSc8HynpuU9jDsAEyfGbLlxDWn9XaSKjac=";
    };
    type = ipadapter;
    base = sd15;
  };

  # FaceID plus v2
  ip-adapter-faceid-plusv2_sd15 = {
    installPath = "ipadapter/ip-adapter-faceid-plusv2_sd15.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-plusv2_sd15.bin";
      sha256 = "sha256-JtDYah1g1syBHTuIYheLRh4e62Ueb+K3K6F6qVQR4xM=";
    };
    type = ipadapter;
    base = sd15;
  };

  # text prompt style transfer for portraits
  ip-adapter-faceid-portrait-v11_sd15 = {
    installPath = "ipadapter/ip-adapter-faceid-portrait-v11_sd15.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-portrait-v11_sd15.bin";
      sha256 = "sha256-pIy0+J7RjgLGAA9lqp7+xFLofq7Uobyfz0pGDI0OO8Y=";
    };
    type = ipadapter;
    base = sd15;
  };

  # SDXL base FaceID
  ip-adapter-faceid_sdxl = {
    installPath = "ipadapter/ip-adapter-faceid_sdxl.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid_sdxl.bin";
      sha256 = "sha256-9FX+0k4gfIeOweBGazSpadN7q4V8X6pOjSWaC0/2PX4=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # SDXL plus v2
  ip-adapter-faceid-plusv2_sdxl = {
    installPath = "ipadapter/ip-adapter-faceid-plusv2_sdxl.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-plusv2_sdxl.bin";
      sha256 = "sha256-xpRdgrVDcAzDzLuY02O4N+nFligWB4V8dLcTqHba9fs=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # SDXL text prompt style transfer
  ip-adapter-faceid-portrait_sdxl = {
    installPath = "ipadapter/ip-adapter-faceid-portrait_sdxl.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-portrait_sdxl.bin";
      sha256 = "sha256-VjHOeCTNr9LbN8XoW5hXMKlf9ZxbT8gMK3mwvuVxFRI=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # very strong style transfer SDXL only
  ip-adapter-faceid-portrait_sdxl_unnorm = {
    installPath = "ipadapter/ip-adapter-faceid-portrait_sdxl_unnorm.bin";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-portrait_sdxl_unnorm.bin";
      sha256 = "sha256-Igu4biBTk6PQQRYxy0c8rdvzX9NxvikFypAIgYFw21U=";
    };
    type = ipadapter;
    base = sdxl;
  };

  # https://huggingface.co/ByteDance/Hyper-SD
  hyper-sd15-1step = {
    installPath = "loras/Hyper-SD15-1step-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SD15-1step-lora.safetensors";
      sha256 = "sha256-oE/ZpTXB5W0491kO5yoT/VygQJhTtP/wIeWpSCzxyjs=";
    };
    type = lora;
    base = sd15;
  };

  hyper-sdxl-1step = {
    installPath = "loras/Hyper-SDXL-1step-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SDXL-1step-lora.safetensors";
      sha256 = "sha256-yRLfGExRFnktLGBNJsa8KqkWaF9KeTdVJVzaHEOjx4o=";
    };
    type = lora;
    base = sdxl;
  };

  hyper-sd15-4steps = {
    installPath = "loras/Hyper-SD15-4steps-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SD15-4steps-lora.safetensors";
      sha256 = "sha256-xd0FhhZGHtUFPisU7sTb4/oO6jsTaIZC9tbIDqK6WVg=";
    };
    type = lora;
    base = sd15;
  };

  hyper-sdxl-4steps = {
    installPath = "loras/Hyper-SDXL-4steps-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SDXL-4steps-lora.safetensors";
      sha256 = "sha256-EvgaJ9AKdRpA1o/RVZcJGJbFqQ871jL7bEdWB8va124=";
    };
    type = lora;
    base = sdxl;
  };

  hyper-sd15-8steps = {
    installPath = "loras/Hyper-SD15-8steps-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SD15-8steps-lora.safetensors";
      sha256 = "sha256-kfwxhiNulW1k27Q1fy4SDGm5aLeK99LbmISlynTTzRM=";
    };
    type = lora;
    base = sd15;
  };

  hyper-sdxl-8steps = {
    installPath = "loras/Hyper-SDXL-8steps-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SDXL-8steps-lora.safetensors";
      sha256 = "sha256-ymiRkOjEYDhVA4S1Z1SIUmz+WkDTX4Kyest1wQD0F8E=";
    };
    type = lora;
    base = sdxl;
  };

  hyper-sd15-8steps-cfg = {
    installPath = "loras/Hyper-SD15-8steps-CFG-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SD15-8steps-CFG-lora.safetensors";
      sha256 = "sha256-9hI9W5UNUlCrbDNgDif03PcbMJnr+IhoXgHp6BF85II=";
    };
    type = lora;
    base = sd15;
  };

  hyper-sdxl-8steps-cfg = {
    installPath = "loras/Hyper-SDXL-8steps-CFG-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SDXL-8steps-CFG-lora.safetensors";
      sha256 = "sha256-VbUTNMhQYa//Xv98VQthljyLhgelhou+TybbSTdHGbE=";
    };
    type = lora;
    base = sdxl;
  };

  hyper-sd15-12steps-cfg = {
    installPath = "loras/Hyper-SD15-12steps-CFG-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SD15-12steps-CFG-lora.safetensors";
      sha256 = "sha256-ZLmENzg1N82Wj9pvh6BcMxYOzpx5/0dXlJoeIS/3g2E=";
    };
    type = lora;
    base = sd15;
  };

  hyper-sdxl-12steps-cfg = {
    installPath = "loras/Hyper-SDXL-12steps-CFG-lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "ByteDance";
      repo = "Hyper-SD";
      resource = "Hyper-SDXL-12steps-CFG-lora.safetensors";
      sha256 = "sha256-C5f0R7WHgyOij758Ubp6zr0h9Nd1Urp3sEsRyJEYJbY=";
    };
    type = lora;
    base = sdxl;
  };

  lcm-lora-sdv1-5 = {
    installPath = "loras/lcm-lora-sdv1-5.safetensors";
    src = fetchFromHuggingFace {
      owner = "latent-consistency";
      repo = "lcm-lora-sdv1-5";
      resource = "pytorch_lora_weights.safetensors";
      sha256 = "sha256-j5DYQOB1/1iKWOIsZYbirppveSKZbuZkmn8BByMzr+Q=";
    };
    type = lora;
    base = sd15;
  };

  lcm-lora-sdxl = {
    installPath = "loras/lcm-lora-sdxl.safetensors";
    src = fetchFromHuggingFace {
      owner = "latent-consistency";
      repo = "lcm-lora-sdxl";
      resource = "pytorch_lora_weights.safetensors";
      sha256 = "sha256-p2TmhZtuBAR812HAj/DO6WQTqOAEyfB3B1MM13axkUE=";
    };
    type = lora;
    base = sdxl;
  };

  # Helps with eyes.
  # https://civitai.com/models/118427/perfect-eyes-xl?modelVersionId=128461
  perfect-eyes-xl = {
    installPath = "loras/perfect-eyes-xl.safetensors";
    src = fetchFromUrl {
      name = "perfect-eyes-xl";
      url = "https://civitai.com/api/download/models/128461?type=Model&format=SafeTensor";
      sha256 = "sha256-8kg2TPCsx6ALxLUUW0TA378Q5x6bDvtrd/CVauryQRw=";
    };
    type = lora;
    base = sdxl;
  };

  # Helps with indicating various styles in PonyXL, such as oil,
  # realistic, digital art, and combinations thereof.
  # https://civitai.com/models/264290?modelVersionId=398292
  ponyx-xl-v6-non-artist-styles = {
    installPath = "loras/ponyx-xl-v6-non-artist-styles.safetensors";
    src = fetchFromUrl {
      name = "ponyx-xl-v6-non-artist-styles";
      url = "https://civitai.com/api/download/models/398292?type=Model&format=SafeTensor";
      sha256 = "01m4zq2i1hyzvx95nq2v3n18b2m98iz0ryizdkyc1y42f1rwd0kx";
    };
    type = lora;
    base = sdxl;
  };

  # TODO: Maybe figure out how to obfuscate?
  ralph-breaks-internet-disney-princesses = {
    installPath = "loras/ralph-breaks-internet-disney-princesses.safetensors";
    src = fetchFromUrl {
      name = "ralph-breaks-internet-disney-princesses";
      url = "https://civitai.com/api/download/models/244808?type=Model&format=SafeTensor.SafeTensor";
      sha256 = "sha256-gKpnkTrryJoBvhkH5iEi8zn9/ucMFxq3upZ8Xl/PJ+o=";
    };
    type = lora;
  };

  ip-adapter-faceid_sd15_lora = {
    installPath = "loras/ip-adapter-faceid_sd15_lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid_sd15_lora.safetensors";
      sha256 = "sha256-cGmfDb+t1H3h+B0mPPTIa9S3Jx2EEwSvmzQLOn846Go=";
    };
    type = lora;
    base = sd15;
  };

  ip-adapter-faceid-plusv2_sd15_lora = {
    installPath = "loras/ip-adapter-faceid-plusv2_sd15_lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-plusv2_sd15_lora.safetensors";
      sha256 = "sha256-ir/4ehWgSfPgGGwugsHI53eDuvLPtj80xBJlYFLrV7A=";
    };
    type = lora;
    base = sd15;
  };

  # SDXL FaceID LoRA
  ip-adapter-faceid_sdxl_lora = {
    installPath = "loras/ip-adapter-faceid_sdxl_lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid_sdxl_lora.safetensors";
      sha256 = "sha256-T8+T1ujcjdGPX55RyDBvNpSG7QqgeAremWEwiv9/DWQ=";
    };
    type = lora;
    base = sdxl;
  };

  # SDXL plus v2 LoRA
  ip-adapter-faceid-plusv2_sdxl_lora = {
    installPath = "loras/ip-adapter-faceid-plusv2_sdxl_lora.safetensors";
    src = fetchFromHuggingFace {
      owner = "h94";
      repo = "IP-Adapter-FaceID";
      resource = "ip-adapter-faceid-plusv2_sdxl_lora.safetensors";
      sha256 = "sha256-8ktLstrWY4oJwA8VHN6EmRuvN0QJOFvLq1PBhxowy3s=";
    };
    type = lora;
    base = sdxl;
  };

  # https://civitai.com/models/199663/indigenous-mix-by-noerman
  indigenous-mix-by-noerman = {
    installPath = "loras/indigenous-mix-by-noerman.safetensors";
    src = fetchFromUrl {
      name = "indigenous-mix-by-noerman";
      url = "https://civitai.com/api/download/models/227236?type=Model&format=SafeTensor";
      sha256 = "sha256-9OmsnpnknlfMhnWNwRD+RlYOAyYChF7+OgGCU6GGafY=";
    };
    type = lora;
    base = sd15;
  };

  # https://civitai.com/models/201636/south-america-indigenous-mix-by-noerman
  south-america-indigenous-mix-by-noerman = {
    installPath = "loras/south-america-indigenous-mix-by-noerman.safetensors";
    src = fetchFromUrl {
      name = "south-america-indigenous-mix-by-noerman";
      url = "https://civitai.com/api/download/models/226955?type=Model&format=SafeTensor";
      sha256 = "sha256-HMmTe9ALD+b35BB80lYfM2UMlJsrlYbIVKCLLJ3sJzc=";
    };
    type = lora;
    base = sd15;
  };

  # Upscaler comparisons can be found here:
  # https://civitai.com/articles/636/sd-upscalers-comparison
  "4x_NMKD-Superscale-SP_178000_G" = {
    installPath = "upscale_models/4x_NMKD-Superscale-SP_178000_G.pth";
    src = fetchFromHuggingFace {
      owner = "gemasai";
      repo = "4x_NMKD-Superscale-SP_178000_G";
      resource = "4x_NMKD-Superscale-SP_178000_G.pth";
      sha256 = "sha256-HRsAeP5xRG4EadjU31npa6qA2DzaYA1oI31lWDCCG8w=";
    };
    type = upscaler;
  };

  OmniSR_X2_DIV2K = {
    installPath = "upscale_models/OmniSR_X2_DIV2K.safetensors";
    src = fetchFromHuggingFace {
      owner = "Acly";
      repo = "Omni-SR";
      resource = "OmniSR_X2_DIV2K.safetensors";
      sha256 = "sha256-eUCPwjIDvxYfqpV8SmAsxAUh7SI1py2Xa9nTdeZkRhE=";
    };
    type = upscaler;
  };

  OmniSR_X3_DIV2K = {
    installPath = "upscale_models/OmniSR_X3_DIV2K.safetensors";
    src = fetchFromHuggingFace {
      owner = "Acly";
      repo = "Omni-SR";
      resource = "OmniSR_X3_DIV2K.safetensors";
      sha256 = "sha256-T7C2j8MU95jS3c8fPSJTBFuj2VnYua4nDFqZufhi7hI=";
    };
    type = upscaler;
  };

  OmniSR_X4_DIV2K = {
    installPath = "upscale_models/OmniSR_X4_DIV2K.safetensors";
    src = fetchFromHuggingFace {
      owner = "Acly";
      repo = "Omni-SR";
      resource = "OmniSR_X4_DIV2K.safetensors";
      sha256 = "sha256-3/JeTtOSy1y+U02SDikgY6BVXfkoHFTF7DIUkKKlmDI=";
    };
    type = upscaler;
  };

  # https://openmodeldb.info/models/4x-realesrgan-x4plus
  # https://github.com/xinntao/Real-ESRGAN
  real-esrgan-4xplus = {
    installPath = "upscale_models/real-esrgan-4xplus.pth";
    src = fetchFromUrl {
      name = "real-esrgan-4xplus";
      url = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth";
      sha256 = "sha256-T6DTiQX3WsButJp5UbQmZwAhvjAYJl/RkdISXfnWgvE=";
    };
    type = upscaler;
  };

  # Doesn't work at all - unsupported model.  Must be older SD version
  # only.
  stable-diffusion-4x-upscaler = {
    installPath = "upscale_models/stable-diffusion-4x-upscaler.safetensors";
    src = fetchFromHuggingFace {
      owner = "stabilityai";
      repo = "stable-diffusion-x4-upscaler";
      resource = "x4-upscaler-ema.safetensors";
      sha256 = "35c01d6160bdfe6644b0aee52ac2667da2f40a33a5d1ef12bbd011d059057bc6";
    };
    type = upscaler;
  };

  # Samael1976 reposted this to civitai.com - the alternative is to
  # download it from mega.nz, which I do not believe is friendly to
  # headless activity such as this.  The original model is listed here:
  # https://openmodeldb.info/models/4x-UltraSharp
  kim2091-4k-ultrasharp = {
    installPath = "upscale_models/kim2091-4k-ultrasharp.pth";
    src = fetchFromHuggingFace {
      owner = "Kim2091";
      repo = "UltraSharp";
      resource = "4x-UltraSharp.pth";
      sha256 = "sha256-pYEiMfyTa0KvCKXtunhBlUldMD1bMkjCRInvDEAh/gE=";
    };
    type = upscaler;
  };

  sdxl_vae = {
    installPath = "vae/sdxl_vae.safetensors";
    src = fetchFromUrl {
      name = "sdxl_vae";
      url = "https://civitai.com/api/download/models/290640?type=VAE";
      sha256 = "1qf65fia7g0ammwjw2vw1yhijw5kd2c54ksv3d64mgw6inplamr3";
    };
    type = vae;
    base = sdxl;
  };

  inswapper_128 = {
    installPath = "insightface/inswapper_128.onnx";
    src = fetchFromHuggingFace {
      owner = "datasets";
      repo = "Gourieff";
      resource = "ReActor/models/inswapper_128.onnx";
      sha256 = "sha256-5KPwjHU8ty0E4Qqg99vj3uu/OVZ9Tq1tzgjpiqSeFq8=";
    };
  };

  "GFPGAN-v1.3" = {
    installPath = "facerestore_models/GFPGANv1.3.pth";
    src = fetchFromHuggingFace {
      owner = "datasets";
      repo = "Gourieff";
      resource = "ReActor/models/facerestore_models/GFPGANv1.3.pth";
      sha256 = "sha256-yVOojycnyFw9mucuK9SEa7r1n+aXKtlBMOI+cBdSSnA=";
    };
  };
  "GFPGAN-v1.4" = {
    installPath = "facerestore_models/GFPGANv1.4.pth";
    src = fetchFromHuggingFace {
      owner = "datasets";
      repo = "Gourieff";
      resource = "ReActor/models/facerestore_models/GFPGANv1.4.pth";
      sha256 = "sha256-4s1HA6sU9NAf0Tg6iosmb5pYM9rO6OannTvyGhtr5a0=";
    };
  };
  "codeformer-v0.1.0" = {
    installPath = "facerestore_models/codeformer-v0.1.0.pth";
    src = fetchFromHuggingFace {
      owner = "datasets";
      repo = "Gourieff";
      resource = "ReActor/models/facerestore_models/codeformer-v0.1.0.pth";
      sha256 = "sha256-EAnlN+DCoH1Mq85jVfU8tmdnzUtCl+x6SmTKS4pWhLc=";
    };
  };
  GPEN-BFR-512 = {
    installPath = "facerestore_models/GPEN-BFR-512.onnx";
    src = fetchFromHuggingFace {
      owner = "datasets";
      repo = "Gourieff";
      resource = "ReActor/models/facerestore_models/GPEN-BFR-512.onnx";
      sha256 = "sha256-v4CsuOkbqIUuPwElBb4sO2zWs+7V7GBePbh4Y8TnTU4=";
    };
  };
}
