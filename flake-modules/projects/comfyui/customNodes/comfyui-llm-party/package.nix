{
  python3Packages,
}:

finalAttrs: previousAttrs: {
  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    docx2txt
    langchain
    langchain-community
    langchain-text-splitters
    openai
    openpyxl
    pandas
    pytz
    requests
    xlrd
    faiss
    websocket-client
    streamlit
    virtualenv
    tiktoken
    transformers
    optimum
    pdfplumber
    wikipedia
    arxiv
    bitsandbytes
    accelerate
    fastapi
    py-cpuinfo
    diskcache
    requests-toolbelt
    tabulate
    charset-normalizer
    tenacity
    pydub
    keyboard
    sounddevice
    neo4j
    soundfile
    langchain-openai
    sentence-transformers
    uvicorn
    llama-index
    html2image
    markdown
    selenium
    librosa
    ffmpeg-python
    moviepy
    html5lib
    easyocr
    feedparser
    psutil
    markdownify
    srt
    peft
    scipy
    json-repair
    redis
    fish-audio-sdk
    httpx
    mcp
    attrdict
    docstring-parser
    langchain-ollama
    timm
  ];

  dontBuild = true;
  dontConfigure = true;

  postPatch = ''
    sed -i -e 's/install_portaudio()/pass/g' \
           -e 's/install_llama(system_info)/pass/g' \
           -e 's/check_and_uninstall_websocket()/pass/g' \
           -e 's/def install_playwright_browsers():/def install_playwright_browsers():\n    return/g' \
           __init__.py

    find . -type f -name "*.py" -exec sed -i \
      -e 's|os\.path\.join(current_dir_path, "config\.ini")|__import__("os").path.join(__import__("os").getenv("LLM_PARTY_PATH", __import__("os").path.join(__import__("folder_paths").base_path, "custom_nodes_data", "comfyui_llm_party")), "config.ini")|g' \
      -e 's|os\.path\.join(current_dir, "config\.ini")|__import__("os").path.join(__import__("os").getenv("LLM_PARTY_PATH", __import__("os").path.join(__import__("folder_paths").base_path, "custom_nodes_data", "comfyui_llm_party")), "config.ini")|g' \
      -e 's|os\.path\.join(os\.path\.dirname(__file__), .\?config\.ini.\?)|__import__("os").path.join(__import__("os").getenv("LLM_PARTY_PATH", __import__("os").path.join(__import__("folder_paths").base_path, "custom_nodes_data", "comfyui_llm_party")), "config.ini")|g' \
      {} +

    sed -i 's|def copy_config():|def copy_config():\n    __import__("os").makedirs(__import__("os").getenv("LLM_PARTY_PATH", __import__("os").path.join(__import__("folder_paths").base_path, "custom_nodes_data", "comfyui_llm_party")), exist_ok=True)|g' install.py
  '';
}
