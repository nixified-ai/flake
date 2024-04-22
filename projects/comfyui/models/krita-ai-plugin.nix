# reference managed server: https://github.com/Acly/krita-ai-diffusion/blob/main/ai_diffusion/cloud_client.py
# model urls: https://github.com/Acly/krita-ai-diffusion/blob/main/ai_diffusion/resources.py
models: let
  minimal = {
    inherit
      (models)
      DreamShaper_8_pruned
      flat2DAnimerge_v45Sharp
      flux1-schnell-fp8
      juggernautXL_version6Rundiffusion
      zavy-chroma-xl
      realisticVisionV51_v51VAE
      fooocus_inpaint_head
      inpaint_v26-fooocus
      MAT_Places512_G_fp16
      clip_vision-sd15
      control_lora_rank128_v11f1e_sd15_tile_fp16
      control_v11p_sd15_inpaint_fp16
      ip-adapter_sd15
      ip-adapter_sdxl_vit-h
      hyper-sd15-8steps-cfg
      hyper-sdxl-8steps-cfg
      OmniSR_X2_DIV2K
      OmniSR_X3_DIV2K
      OmniSR_X4_DIV2K
      "4x_NMKD-Superscale-SP_178000_G"
      ;
  };

  optional = {
    inherit
      (models)
      # these are part of the default managed server used as reference
      
      control_v11p_sd15_inpaint_fp16
      xinsir-controlnet-union-sdxl-promax
      control_lora_rank128_v11p_sd15_scribble_fp16
      control_v11p_sd15_lineart_fp16
      control_v11p_sd15_softedge_fp16
      control_v11p_sd15_canny_fp16
      control_lora_rank128_v11f1p_sd15_depth_fp16
      control_lora_rank128_v11p_sd15_openpose_fp16
      control_lora_rank128_v11f1e_sd15_tile_fp16
      control_v1p_sd15_qrcode_monster
      ip-adapter_sd15
      ip-adapter_sdxl_vit-h
      # These are extra
      
      control_lora_rank128_v11p_sd15_normalbae_fp16
      control_lora_rank128_v11p_sd15_seg_fp16
      control_sd15_inpaint_depth_hand_fp16
      control_v1p_sdxl_qrcode_monster
      ip-adapter-faceid-plusv2_sd15
      ip-adapter-faceid-plusv2_sdxl
      ip-adapter-faceid-plusv2_sd15_lora
      ip-adapter-faceid-plusv2_sdxl_lora
      ;
  };
in {
  inherit minimal optional;
  full = minimal // optional;
}
