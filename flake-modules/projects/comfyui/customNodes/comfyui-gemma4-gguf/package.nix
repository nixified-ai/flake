{
  python3Packages,
  ...
}:
{
  propagatedBuildInputs = with python3Packages; [
    llama-cpp-python
    numpy
    pillow
  ];

  postPatch = ''
    substituteInPlace gemma4_nodes.py \
      --replace-fail 'def get_model_file_list():' 'def get_model_file_list():
        try:
            files = folder_paths.get_filename_list("LLM/Gemma4-GGUF")
            if files: return [f for f in files if f.endswith(".gguf")]
        except: pass' \
      --replace-fail 'def get_mmproj_file_list():' 'def get_mmproj_file_list():
        try:
            files = folder_paths.get_filename_list("LLM/Gemma4-GGUF")
            if files: return [f for f in files if "mmproj" in f.lower() and f.endswith(".gguf")]
        except: pass' \
      --replace-fail 'full_model_path = os.path.join(folder_paths.models_dir, rel_model_dir, model_file)' 'full_model_path = folder_paths.get_full_path("LLM/Gemma4-GGUF", model_file) or os.path.join(folder_paths.models_dir, rel_model_dir, model_file)' \
      --replace-fail 'full_mmproj_path = os.path.join(folder_paths.models_dir, rel_model_dir, mmproj_file)' 'full_mmproj_path = folder_paths.get_full_path("LLM/Gemma4-GGUF", mmproj_file) or os.path.join(folder_paths.models_dir, rel_model_dir, mmproj_file)'
      
    substituteInPlace gemma4_engine.py \
      --replace-fail '"present_penalty": present_penalty,' '"presence_penalty": present_penalty,'

    sed -i '/FUNCTION = "load_model"/a \ \ \ \ @classmethod\n\ \ \ \ def IS_CHANGED(cls, **kwargs):\n\ \ \ \ \ \ \ \ if not kwargs.get("keep_model_loaded", True):\n\ \ \ \ \ \ \ \ \ \ \ \ import time\n\ \ \ \ \ \ \ \ \ \ \ \ return time.time()\n\ \ \ \ \ \ \ \ return ""\n' gemma4_nodes.py

  '';
}
