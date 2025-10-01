{
  fetchResource,
  fetchair,
}: {
  flux1-dev-q4_0 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_0.gguf";
    sha256 = "143fqhqjazxcgv1pnqrll1vfc2adk9ji0l7nrg5hrn20arbyjrr8";
    passthru = {
      comfyui.installPaths = ["diffusion_models"];
    };
  };

  flux-ae = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors";
    sha256 = "0f4ya8isiyyhbr6jrcbcx4ifvhg9ij8vdkds34wxn5fdfa1f5j5g";
    passthru = {
      comfyui.installPaths = ["vae"];
    };
  };

  flux-text-encoder-1 = fetchResource {
    name = "text_encoder-1.safetensors";
    url = "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/text_encoder/model.safetensors";
    sha256 = "10nhkq7lgda6iai0vi09jvspqwiyzvbvlk5brm1fv4s67yi6fgc9";
    passthru = {
      comfyui.installPaths = ["text_encoders"];
    };
  };

  t5-v1_1-xxl-encoder = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q4_K_M.gguf";
    sha256 = "1x0svg0mh6f9rqqk3ia6rsbsj0x10aw8rj20jf8z4z6ywavv1qkb";
    passthru = {
      comfyui.installPaths = ["text_encoders"];
    };
  };

  stable-diffusion-v1-5 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors";
    sha256 = "sha256-GhifC+adYQakhUjnYmIH3d1wQqQY2/Nyzv0F4M26YbY=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  sams = fetchResource rec {
    name = baseNameOf url;
    url = "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth";
    sha256 = "0bi6dz13iwyr8sg6gfvk64yw7md2v4vzcgwip9x2dwgbyc13pgx7";
    passthru = {
      comfyui.installPaths = ["sams"];
    };
  };

  ltx-video = fetchResource {
    name = "ltx-video-2b-v0.9.1.safetensors";
    url = "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.1.safetensors";
    sha256 = "sha256-ojIAiWxe3fIVx8uVF4IMV2OisFTrYrqGy85rhxpFd+M=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  t5xxl_fp16 = fetchResource {
    name = "t5xxl_fp16.safetensors";
    url = "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/t5xxl_fp16.safetensors";
    sha256 = "sha256-bkgLCfrgSactKoxfvMuNPpL+vrIzu+nf5yVpWKkWdjU=";
    passthru = {
      comfyui.installPaths = ["clip"];
    };
  };

  hyper-sd15-1step-lora = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SD15-1step-lora.safetensors";
    sha256 = "sha256-oE/ZpTXB5W0491kO5yoT/VygQJhTtP/wIeWpSCzxyjs=";
    passthru = {
      comfyui.installPaths = ["loras"];
    };
  };

  christmas-couture-lora = fetchair {
    name = "christmas-couture.safetensors";
    air = "urn:air:flux1:lora:civitai:1016234@1139381";
    sha256 = "07A336BFBE072C44EF2FBE0ECB69B7CD880FD3F096984ED87AD27919208FD207";
    passthru = {
      comfyui.installPaths = ["loras"];
    };
  };

  ultrarealistic-lora = fetchResource {
    name = "ultrarealistic.safetensors";
    url = "https://civitai.com/api/download/models/1026423?type=Model&format=SafeTensor";
    sha256 = "B1C4DDF95671E6B51817B4F3802865E544040C232C467E76B1CB0C251BD6B634";
    passthru = {
      comfyui.installPaths = ["loras"];
    };
  };

  Kolors-ControlNet-Canny = fetchResource {
    name = "Kolors_Canny.safetensors";
    url = "https://huggingface.co/Kwai-Kolors/Kolors-ControlNet-Canny/resolve/main/diffusion_pytorch_model.safetensors";
    hash = "sha256-qzSWm07lehgt625S4V0GyBxShXOcr02y2HdBNf0rmec=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  Kolors-ControlNet-Depth = fetchResource {
    name = "Kolors_Depth.safetensors";
    url = "https://huggingface.co/Kwai-Kolors/Kolors-ControlNet-Depth/resolve/main/diffusion_pytorch_model.safetensors";
    hash = "sha256-sun5/2fGyOOz++gz+VltnRbUVrGRFjOvmutLgJSe5gs=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  Kolors-IP-Adapter-Plus-General = fetchResource {
    name = "Kolor_ip_adapter_plus_general.bin";
    url = "https://huggingface.co/Kwai-Kolors/Kolors-IP-Adapter-Plus/resolve/main/ip_adapter_plus_general.bin";
    hash = "sha256-GYPD+SessqL0KF4eE08wL6uObXRKOwWORoSKuplXpg8=";
    passthru = {
      comfyui.installPaths = ["ipadapter"];
    };
  };

  Kolors-IP_Adapter-Plus-Encoder = fetchResource {
    name = "pytorch_model.bin";
    url = "https://huggingface.co/Kwai-Kolors/Kolors-IP-Adapter-Plus/resolve/main/image_encoder/pytorch_model.bin";
    hash = "sha256-xgMsLgyq49wtT7o1U1+mMH27Sd9Zx+GCsbxLMym4GAE=";
    passthru = {
      comfyui.installPaths = ["ipadapter"];
    };
  };

  Kolors-Realistic-add-detailer = fetchair {
    name = "kolors-realistic-add-detailer.safetensors";
    air = "urn:air:kolors:lora:civitai:631003@705394";
    sha256 = "sha256-BONX0G9X/OwqILCBIRobOtZfATzpz4qIWx593uJoFxU=";
    passthru = {
      comfyui.installPaths = ["checpoint"];
    };
  };

  Kolors-VAE = fetchair {
    name = "kolors-vae.safetensors";
    air = "urn:air:kolors:vae:civitai:617699@690627";
    sha256 = "sha256-FZjz0kkyvP5mNOi2GOoeMKsdV/Wq0TptLeRG0hmfI0E=";
    passthru = {
      comfyui.installPaths = ["vae"];
    };
  };

  OpenKolors-v24-multiple-style-general = fetchair {
    name = "openkolors-v24--multiple-style-general.safetensors";
    air = "urn:air:kolors:checkpoint:civitai:602580@673560";
    sha256 = "sha256-3r/R2BjHUrIT2w63ZfLTJ//om1/Y6LHEzm6HfP1ckm4=";
    passthru = {
      comfyui.installPaths = ["checpoint"];
    };
  };

  TTPLANET_Controlnet_Tile_realistic_v1_fp16 = fetchResource {
    name = "TTPLANET_Controlnet_Tile_realistic_v1_fp16.safetensors";
    url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic/resolve/main/TTPLANET_Controlnet_Tile_realistic_v1_fp16.safetensors";
    hash = "sha256-+ipfL+yBSBnINUA8d4viwkN9FHkxkhMEVp/M7CtFFzw=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  TTPLANET_Controlnet_Tile_realistic_v1_fp32 = fetchResource {
    name = "TTPLANET_Controlnet_Tile_realistic_v1_fp32.safetensors";
    url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic/resolve/main/TTPLANET_Controlnet_Tile_realistic_v1_fp32.safetensors";
    hash = "sha256-8zASy6xYOYhfFDqirMsuQDQUx9rRGTZLvhjeN+SmX2c=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  TTPLANET_Controlnet_Tile_realistic_v2_fp16 = fetchResource {
    name = "TTPLANET_Controlnet_Tile_realistic_v2_fp16.safetensors";
    url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic/resolve/main/TTPLANET_Controlnet_Tile_realistic_v2_fp16.safetensors";
    hash = "sha256-8zASy6xYOYhfFDqirMsuQDQUx9rRGTZLvhjeN+SmX2c=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  TTPLANET_Controlnet_Tile_realistic_v2_rank256 = fetchResource {
    name = "TTPLANET_Controlnet_Tile_realistic_v2_rank256.safetensors";
    url = "https://huggingface.co/TTPlanet/TTPLanet_SDXL_Controlnet_Tile_Realistic/resolve/main/TTPLANET_Controlnet_Tile_realistic_v2_rank256.safetensors";
    hash = "sha256-CT1bHFAFXlf4Xufb8BBOborn+d1YmmUCxBMUa1Fsb8s=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  chatglm3-4bit = fetchResource {
    name = "chatglm3-4bit";
    url = "https://huggingface.co/Kijai/ChatGLM3-safetensors/resolve/main/chatglm3-4bit.safetensors";
    hash = "sha256-wz25Fn5kfT47f0lDUYvtzHKqZdiDD2mQqP6YF2ktXGs=";
    passthru = {
      comfyui.installPaths = ["LLM"];
    };
  };

  chatglm3-8bit = fetchResource {
    name = "chatglm3-8bit";
    url = "https://huggingface.co/Kijai/ChatGLM3-safetensors/resolve/main/chatglm3-8bit.safetensors";
    hash = "sha256-T29kDYhBf/yjK0bWw1YPQIsU0BmQ/m5OxUW9kCwCqFU=";
    passthru = {
      comfyui.installPaths = ["LLM"];
    };
  };

  chatglm3-fp16 = fetchResource {
    name = "chatglm3-fp16";
    url = "https://huggingface.co/Kijai/ChatGLM3-safetensors/resolve/main/chatglm3-fp16.safetensors";
    hash = "sha256-m2Jt20vUhcPGKts4WLn7yrsW3Be0Ja5oD4gf5yIP+OQ=";
    passthru = {
      comfyui.installPaths = ["LLM"];
    };
  };

  clip_vision_vit_h-upscaler = fetchResource {
    name = "CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors";
    url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors";
    hash = "sha256-bKlmfaHKngsPdeRrsDD34BH0T4bL+41aNlkPzXUHsDA=";
    passthru = {
      comfyui.installPaths = ["clip_vision"];
    };
  };

  control-lora-rank128-v11f1e-sd15-tile-fp16-controlnet = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11f1e_sd15_tile_fp16.safetensors";
    hash = "sha256-zsADaemc/tHOyX4RJM8yIN96meRTVOqh4zUMSF5lFU8=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  control-v11p-sd15-inpaint-fp16-controlnet = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_v11p_sd15_inpaint_fp16.safetensors";
    hash = "sha256-Z3pP41Ht7NQM0NfMIQqGhrWdTlUgcxfxIxnvdGp6Wok=";
    passthru = {
      comfyui.installPaths = ["controlnet"];
    };
  };

  control-lora-rank128-v11p-sd15-canny-fp16 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/comfyanonymous/ControlNet-v1-1_fp16_safetensors/resolve/main/control_lora_rank128_v11p_sd15_canny_fp16.safetensors";
    sha256 = "0srwfsvidbxqia4chpiag0g4485k13y3h51hmmcqavf338s3s1a5";
    passthru = {
      comfyui.installPaths = [ "controlnet" ];
    };
  };

  depth_anything_v2_metric_hypersim_vitl_fp32 = fetchResource {
    name = "depth_anything_v2_metric_hypersim_vitl_fp32.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_metric_hypersim_vitl_fp32.safetensors";
    hash = "sha256-drwS9H9PxUPWfUw7aV0JrlOZqi8hI4KiBJZamspNyL0=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_metric_vkitti_vitl_fp32 = fetchResource {
    name = "depth_anything_v2_metric_vkitti_vitl_fp32.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_metric_vkitti_vitl_fp32.safetensors";
    hash = "sha256-7rxMJ6gGe/kEwmxR5kjdF9R8rafP9hJnOT7aBs2LZJs=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_vitb_fp16 = fetchResource {
    name = "depth_anything_v2_vitb_fp16.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_vitb_fp16.safetensors";
    hash = "sha256-OGdYy9KiysYspiKG07qBBzRWGzCX2GpYXdPaw1cVOUE=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_vitb_fp32 = fetchResource {
    name = "depth_anything_v2_vitb_fp32.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_vitb_fp32.safetensors";
    hash = "sha256-+vH1ZzUR+4l1JXgaF3xQAfx5DCZs/1GLleUW9JEsxCs=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_vitl_fp16 = fetchResource {
    name = "depth_anything_v2_vitl_fp16.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_vitl_fp16.safetensors";
    hash = "sha256-8HWpCZ+UuuVKW/4hoUIzRkKTCbrkCruFuZNZhbHzWgk=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_vitl_fp32 = fetchResource {
    name = "depth_anything_v2_vitl_fp32.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_vitl_fp32.safetensors";
    hash = "sha256-IDq6ahtVGqahgYZSuSrJpDpQ/cfa75eA6yZeTunHUh4=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_vits_fp16 = fetchResource {
    name = "depth_anything_v2_vits_fp16.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_vits_fp16.safetensors";
    hash = "sha256-p8GoyM3XiF+4ORBpzR7ueJEmyNiW995nUEmbEJf4F+o=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  depth_anything_v2_vits_fp32 = fetchResource {
    name = "depth_anything_v2_vits_fp32.safetensors";
    url = "https://huggingface.co/Kijai/DepthAnythingV2-safetensors/resolve/main/depth_anything_v2_vits_fp32.safetensors";
    hash = "sha256-yy1TftbkWSHyf2HwtgXc+vtrl8fRoV5VEoC92GdgXIY=";
    passthru = {
      comfyui.installPaths = ["depthanything"];
    };
  };

  dreamshaper-8-pruned-checkpoints = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors";
    hash = "sha256-h521I8MNO5AXFD1WcFAV4VostWKHYsEdCG/tlTir1/0=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  flat2danimerge-v45sharp-checkpoints = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/Acly/SD-Checkpoints/resolve/main/flat2DAnimerge_v45Sharp.safetensors";
    hash = "sha256-/pUGO6YLySmNYOslL5jQVwOdmoghWK/gQvJmvcGx5Sg=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  fooocus-inpaint-head-inpaint = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/fooocus_inpaint_head.pth";
    hash = "sha256-Mvf4OODG2PE0N7qEEed6RojXei4034hX5O9NUfa5dpI=";
    passthru = {
      comfyui.installPaths = ["inpaint"];
    };
  };

  hyper-sd15-8steps-cfg-loras = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SD15-8steps-CFG-lora.safetensors";
    hash = "sha256-9hI9W5UNUlCrbDNgDif03PcbMJnr+IhoXgHp6BF85II=";
    passthru = {
      comfyui.installPaths = ["loras"];
    };
  };

  hyper-sdxl-8steps-cfg-lora = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SDXL-8steps-CFG-lora.safetensors";
    hash = "sha256-VbUTNMhQYa//Xv98VQthljyLhgelhou+TybbSTdHGbE=";
    passthru = {
      comfyui.installPaths = ["loras"];
    };
  };

  inpaint-v26-fooocus-inpaint = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/lllyasviel/fooocus_inpaint/resolve/main/inpaint_v26.fooocus.patch";
    hash = "sha256-+GV6AlEE4i1w+cBgY12OjCGW9DOHGi9o3ECr0hcfDVk=";
    passthru = {
      comfyui.installPaths = ["inpaint"];
    };
  };

  ip-adapter-sd15-inpaint = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors";
    hash = "sha256-KJtF8W0EPQv1QuRYMflx3Nqr4YtlbxHobZ37p+nuM2k=";
    passthru = {
      comfyui.installPaths = ["inpaint"];
    };
  };

  ip-adapter-sdxl-vit-h-ipadapter = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors";
    hash = "sha256-6/BdkYNIrsersCpens73fgquppFKXE6hP1DUXrFoGDE=";
    passthru = {
      comfyui.installPaths = ["ipadapter"];
    };
  };

  ip-adapter-plus-sd15 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/h94/IP-Adapter/resolve/018e402774aeeddd60609b4ecdb7e298259dc729/models/ip-adapter-plus_sd15.safetensors";
    sha256 = "a1c250be40455cc61a43da1201ec3f1edaea71214865fb47f57927e06cbe4996";
    passthru = {
      comfyui.installPaths = ["ipadapter"];
    };
  };

  juggernautxl-version6rundiffusion-checkpoints = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/juggernautXL_version6Rundiffusion.safetensors";
    hash = "sha256-H+bH7FTHhgQM2rx7TolyAGnZcJaSLiDQHxPndkQStH8=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  mat-places512-g-fp16-inpaint = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/Acly/MAT/resolve/main/MAT_Places512_G_fp16.safetensors";
    hash = "sha256-MJ3Wzm4EA03EtrFce9KkhE0VjgPrKhOeDsprNm5AwN4=";
    passthru = {
      comfyui.installPaths = ["inpaint"];
    };
  };

  omnisr-x2-div2k-upscaler = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X2_DIV2K.safetensors";
    hash = "sha256-eUCPwjIDvxYfqpV8SmAsxAUh7SI1py2Xa9nTdeZkRhE=";
    passthru = {
      comfyui.installPaths = ["upscale_models"];
    };
  };

  omnisr-x3-div2k-upscaler = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X3_DIV2K.safetensors";
    hash = "sha256-T7C2j8MU95jS3c8fPSJTBFuj2VnYua4nDFqZufhi7hI=";
    passthru = {
      comfyui.installPaths = ["upscale_models"];
    };
  };

  omnisr-x4-div2k-upscaler = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/Acly/Omni-SR/resolve/main/OmniSR_X4_DIV2K.safetensors";
    hash = "sha256-3/JeTtOSy1y+U02SDikgY6BVXfkoHFTF7DIUkKKlmDI=";
    passthru = {
      comfyui.installPaths = ["upscale_models"];
    };
  };

  realisticvisionv51-v51vae-checkpoints = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/realisticVisionV51_v51VAE.safetensors";
    hash = "sha256-FQEsU49QPOLr/CyFR7Jox1zNr/eigdtVOZlA/x1w4h0=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  zavychromaxl-v80-checkpoints = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/misri/zavychromaxl_v80/resolve/main/zavychromaxl_v80.safetensors";
    hash = "sha256-Ha2znkA6gYxmOKjD44RDfbi66f5KN3CVWStjnZPMgQY=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  svdq-int4_r32-sdxl = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/nunchaku-tech/nunchaku-sdxl/resolve/main/svdq-int4_r32-sdxl.safetensors";
    hash = "sha256-90rlmelfPBvQ3eJ4QvCdDEbY0XWO/j1/sh6HC6s2SIQ=";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  sdxl-lightning-1step-x0 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/ByteDance/SDXL-Lightning/resolve/main/sdxl_lightning_1step_x0.safetensors";
    sha256 = "180rmrhyg994apq1kdywsr36y6pasimphdc12y4bxnqw6hmlr3fx";
    passthru = {
      comfyui.installPaths = ["checkpoints"];
    };
  };

  sdxl-lightning-2step-lora = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/ByteDance/SDXL-Lightning/resolve/main/sdxl_lightning_2step_lora.safetensors";
    sha256 = "sha256-BPr8d4OFskFESYqCR0mK5Pt6afcC6gVmvc4oRaMfzEM=";
    passthru = {
      comfyui.installPaths = ["loras"];
    };
  };

  face-yolov8m = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/face_yolov8m.pt";
    sha256 = "17sc5spp5bbxx11ipzpy1hg7qxnvji040xfcnqv73461qn93m2g3";
    passthru = {
      comfyui.installPaths = ["ultralytics_bbox"];
    };
  };

  hand-yolov8s = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/hand_yolov8s.pt";
    sha256 = "30878cea9870964d4a238339e9dcff002078bbbaa1a058b07e11c167f67eca1c";
    passthru = {
      comfyui.installPaths = ["ultralytics_bbox"];
    };
  };
}
