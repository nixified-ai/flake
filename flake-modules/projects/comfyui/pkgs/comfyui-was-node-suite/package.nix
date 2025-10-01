{
  comfyuiPackages,
  fetchFromGitHub,
  python3Packages,
  ffmpeg,
}:
let
  pilgram = python3Packages.callPackage ../../../../packages/pilgram/default.nix { };
in
comfyuiPackages.comfyui.mkComfyUICustomNode rec {
  pname = "was-node-suite-comfyui";
  version = "f864477";

  dontConfigure = true;
  dontBuild = true;

  src = fetchFromGitHub {
    owner = "ltdrdata";
    repo = "was-node-suite-comfyui";
    rev = "f86447721c18758d7b3b6ae5769f52344a3d764a";
    hash = "sha256-2dKPon6D7RyjOzd/FCO/KGE4Zw8DwLBbH4TwIKdaK0M=";
  };

  was_suite_config = builtins.toJSON {
    "run_requirements" = true;
    "suppress_uncomfy_warnings" = true;
    "show_startup_junk" = true;
    "show_inspiration_quote" = true;
    "text_nodes_type" = "STRING";
    "webui_styles" = null;
    "webui_styles_persistent_update" = true;
    "sam_model_vith_url" = "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth";
    "sam_model_vitl_url" = "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_l_0b3195.pth";
    "sam_model_vitb_url" = "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth";
    "history_display_limit" = 36;
    "use_legacy_ascii_text" = false;
    "ffmpeg_bin_path" = "${ffmpeg}/bin/ffmpeg";
    "ffmpeg_extra_codecs" = {
      "avc1" = ".mp4";
      "h264" = ".mkv";
    };
    "wildcards_path" = "$out/${python3Packages.python.sitePackages}/custom_nodes/${pname}/wildcards";
    "wildcard_api" = true;
  };

  postInstall = ''
    echo $was_suite_config > $out/${python3Packages.python.sitePackages}/custom_nodes/${pname}/was_suite_config.json
  '';

  propagatedBuildInputs = with python3Packages; [
    cmake
    fairscale
    #git+https://github.com/ltdrdata/img2texture.git
    #git+https://github.com/ltdrdata/cstr
    gitpython
    imageio
    joblib
    matplotlib
    numba
    numpy
    opencv4
    pilgram
    ffmpy
    rembg
    scikit-image
    scikit-learn
    scipy
    timm
    tqdm
    transformers
  ];
}
