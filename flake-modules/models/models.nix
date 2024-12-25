{ fetchResource, fetchair }:
{
  flux1-dev-q4_0 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_0.gguf";
    sha256 = "143fqhqjazxcgv1pnqrll1vfc2adk9ji0l7nrg5hrn20arbyjrr8";
    passthru = {
      comfyui.installPaths = [ "diffusion_models" ];
    };
  };

  flux-ae = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors";
    sha256 = "0f4ya8isiyyhbr6jrcbcx4ifvhg9ij8vdkds34wxn5fdfa1f5j5g";
    passthru = {
      comfyui.installPaths = [ "vae" ];
    };
  };

  flux-text-encoder-1 = fetchResource {
    name = "text_encoder-1.safetensors";
    url = "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/text_encoder/model.safetensors";
    sha256 = "10nhkq7lgda6iai0vi09jvspqwiyzvbvlk5brm1fv4s67yi6fgc9";
    passthru = {
      comfyui.installPaths = [ "text_encoders" ];
    };
  };

  t5-v1_1-xxl-encoder = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q4_K_M.gguf";
    sha256 = "1x0svg0mh6f9rqqk3ia6rsbsj0x10aw8rj20jf8z4z6ywavv1qkb";
    passthru = {
      comfyui.installPaths = [ "text_encoders" ];
    };
  };

  stable-diffusion-v1-5 = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors";
    sha256 = "sha256-GhifC+adYQakhUjnYmIH3d1wQqQY2/Nyzv0F4M26YbY=";
    passthru = {
      comfyui.installPaths = [ "checkpoints" ];
    };
  };

  sams = fetchResource rec {
    name = baseNameOf url;
    url = "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth";
    sha256 = "0bi6dz13iwyr8sg6gfvk64yw7md2v4vzcgwip9x2dwgbyc13pgx7";
    passthru = {
      comfyui.installPaths = [ "sams" ];
    };
  };

  ltx-video = fetchResource {
    name = "ltx-video-2b-v0.9.1.safetensors";
    url = "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.1.safetensors";
    sha256 = "sha256-ojIAiWxe3fIVx8uVF4IMV2OisFTrYrqGy85rhxpFd+M=";
    passthru = {
      comfyui.installPaths = [ "checkpoints" ];
    };
  };

  t5xxl_fp16 = fetchResource {
    name = "t5xxl_fp16.safetensors";
    url = "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/t5xxl_fp16.safetensors";
    sha256 = "sha256-bkgLCfrgSactKoxfvMuNPpL+vrIzu+nf5yVpWKkWdjU=";
    passthru = {
      comfyui.installPaths = [ "clip" ];
    };
  };

  hyper-sd15-1step-lora = fetchResource rec {
    name = baseNameOf url;
    url = "https://huggingface.co/ByteDance/Hyper-SD/resolve/main/Hyper-SD15-1step-lora.safetensors";
    sha256 = "sha256-oE/ZpTXB5W0491kO5yoT/VygQJhTtP/wIeWpSCzxyjs=";
    passthru = {
      comfyui.installPaths = [ "loras" ];
    };
  };

  christmas-couture-lora = fetchair {
    name = "christmas-couture.safetensors";
    air = "urn:air:flux1:lora:civitai:1016234@1139381";
    sha256 = "07A336BFBE072C44EF2FBE0ECB69B7CD880FD3F096984ED87AD27919208FD207";
    passthru = {
      comfyui.installPaths = [ "loras" ];
    };
  };

  ultrarealistic-lora = fetchResource {
    name = "ultrarealistic.safetensors";
    url = "https://civitai.com/api/download/models/1026423?type=Model&format=SafeTensor";
    sha256 = "B1C4DDF95671E6B51817B4F3802865E544040C232C467E76B1CB0C251BD6B634";
    passthru = {
      comfyui.installPaths = [ "loras" ];
    };
  };
}
