{
  comfyuiNpins,
  lib,
  buildPythonPackage,
  fetchurl,
  python,
}: let
  # NOTE: this must match your npins key exactly
  npin = comfyuiNpins.comfyui-workflow-templates-core;
in
  buildPythonPackage rec {
    pname = "comfyui_workflow_templates_core";
    inherit (npin) version;

    src = fetchurl {
      inherit (npin) url;
      sha256 = npin.hash;
    };

    # Use the PEP 517/pyproject builder
    format = "pyproject";

    # Match [build-system.requires] in pyproject.toml / setup.cfg
    nativeBuildInputs = with python.pkgs; [
      setuptools
      wheel
    ];

    pythonImportsCheck = [pname];

    meta = with lib; {
      description = "Core module for ComfyUI workflow templates.";
      homepage = "https://github.com/Comfy-Org/workflow_templates";
      license = licenses.gpl3;
    };
  }
