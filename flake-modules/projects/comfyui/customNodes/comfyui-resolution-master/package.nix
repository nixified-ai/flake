{ }:
{
  postPatch = ''
    substituteInPlace core/log_system/logger.py \
      --replace-fail '"log_dir": "logs",' '"log_dir": __import__("os").getenv("AZLOGS_LOG_DIR", __import__("os").path.join(__import__("folder_paths").base_path, "custom_nodes_data", "comfyui-resolution-master")),'
  '';
}
