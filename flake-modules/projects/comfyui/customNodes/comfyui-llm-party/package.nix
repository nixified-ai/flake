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
    aisuite
  ];

  dontBuild = true;
  dontConfigure = true;

  patches = [
    ./llm-party-path.patch
  ];
}
