{ fetchResource, fetchair }:
{
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
}
