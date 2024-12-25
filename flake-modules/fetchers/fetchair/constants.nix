{lib}: let
  findSingleAttr = p: none: more: attrs: lib.lists.findSingle (set: p set.name set.value) none more (lib.attrsToList attrs);
in rec {
  modelTypeFromName = name:
    lib.lists.findSingle (k: v: v.name == name)
    null
    (lib.throw "modelTypeFromName: more than one modelType with the name ${name}")
    (builtins.attrValues modelTypes);
  # following Civitai's idea of model type taxonomy
  # why is there no text encoder type?
  modelTypes = {
    ag = {
      name = "Aesthetic Gradient";
      urn = "ag";
    };
    checkpoint = {
      name = "Checkpoint";
      urn = "checkpoint";
    };
    controlnet = {
      name = "Controlnet";
      urn = "controlnet";
    };
    dora = {
      name = "DoRA";
      urn = "dora";
    };
    embedding = {
      name = "Textual Inversion";
      urn = "embedding";
    };
    hypernet = {
      name = "Hypernetwork";
      urn = "hypernet";
    };
    lora = {
      name = "LORA";
      urn = "lora";
    };
    lycoris = {
      name = "LoCon";
      urn = "lycoris";
    };
    motion = {
      name = "Motion Module";
      urn = "motion";
    };
    upscaler = {
      name = "Upscaler";
      urn = "upscaler";
    };
    vae = {
      name = "VAE";
      urn = "vae";
    };
  };

  baseModels = {
    flux1-d = "Flux.1 D";
    flux1-s = "Flux.1 S";
    hunyuan1 = "Hunyuan 1";
    kolors = "Kolors";
    lumina = "Lumina";
    odor = "ODOR";
    pixart-a = "PixArt a";
    pixart-e = "PixArt E";
    pony = "Pony";
    sd14 = "SD 1.4";
    sd15-hyper = "SD 1.5 Hyper";
    sd15-lcm = "SD 1.5 LCM";
    sd15 = "SD 1.5";
    sd2-768 = "SD 2.0 768";
    sd2 = "SD 2.0";
    sd21-768 = "SD 2.1 768";
    sd21-unclip = "SD 2.1 Unclip";
    sd21 = "SD 2.1";
    sd3 = "SD 3";
    sdxl-distilled = "SDXL Distilled";
    sdxl-hyper = "SDXL Hyper";
    sdxl-lightning = "SDXL Lightning";
    sdxl-turbo = "SDXL Turbo";
    sdxl09 = "SDXL 0.9";
    sdxl1-lcm = "SDXL 1.0 LCM";
    sdxl1 = "SDXL 1.0";
    stablecascade = "Stable Cascade";
  };

  ecosystemFromName = name:
    findSingleAttr (k: v: v.name == name)
    null
    (lib.throw "ecosystemFromName: more than one ecosystem with the name ${name}")
    ecosystems;
  # following Civitai's idea of how base models should be divided into "ecosystems"
  ecosystems = with baseModels; {
    flux1 = {
      name = "Flux1";
      urn = "flux1";
      models = [flux1-d flux1-s];
    };
    hydit1 = {
      name = "HyDit1";
      urn = "hydit1";
      models = [hunyuan1];
    };
    kolors = {
      name = "Kolors";
      urn = "kolors";
      models = [kolors];
    };
    lumina = {
      name = "Lumina";
      urn = "lumina";
      models = [lumina];
    };
    odor = {
      name = "ODOR";
      urn = "odor";
      models = [odor];
    };
    pixarta = {
      name = "PixArt a";
      urn = "pixarta";
      models = [pixart-a];
    };
    pixarte = {
      name = "PixArt E";
      urn = "pixarte";
      models = [pixart-e];
    };
    pony = {
      name = "Pony";
      urn = "pony";
      models = [pony];
    };
    scascade = {
      name = "Stable Cascade";
      urn = "scascade";
      models = [stablecascade];
    };
    sd1 = {
      name = "SD1";
      urn = "sd1";
      models = [sd14 sd15 sd15-hyper sd15-lcm];
    };
    sd2 = {
      name = "SD2";
      urn = "sd2";
      models = [sd2 sd2-768 sd21 sd21-768 sd21-unclip];
    };
    sd3 = {
      name = "SD3";
      urn = "sd3";
      models = [sd3];
    };
    sdxl = {
      name = "SDXL";
      urn = "sdxl";
      models = [sdxl-hyper sdxl-lightning sdxl-turbo sdxl09 sdxl1 sdxl1-lcm];
    };
    sdxldistilled = {
      name = "SDXL Distilled";
      urn = "sdxldistilled";
      models = [sdxl-distilled];
    };
  };

  ecosystemOf = model: let
    base = model.base.name or model.base or model.name or model;
    default = {
      name = "Unknown";
      urn = "unknown";
      models = [base];
    };
  in
    if isNull base
    then default
    else
      lib.lists.findSingle (ecosystem: lib.lists.elem base ecosystem.models)
      default
      (lib.throw "base model ${base} belongs to more than one ecosystem")
      (builtins.attrValues ecosystems);

  # Civitai constants unrelated to AIR, but kept around anyway for now:
  # baseModelTypes = ["Standard" "Inpainting" "Refiner" "Pix2Pix"];
  # modelFileSizes = ["full" "pruned"];
  # modelFileFp = ["fp16" "fp8" "nf4" "fp32" "bf16"];
  # modelFileTypes = ["Model" "Text Encoder" "Pruned Model" "Negative" "Training Data" "VAE" "Config" "Archive"];
  # modelFileFormats = ["SafeTensor" "PickleTensor" "Diffusers" "Core ML" "ONNX" "Other"];
  # trainingModelTypes = ["Character" "Style" "Concept"];
}
