{ python3Packages }:
{
  propagatedBuildInputs = with python3Packages; [
    aiohttp
    aiohttp-socks
    aiosqlite
    beautifulsoup4
    brotli
    gitpython
    jinja2
    natsort
    numpy
    olefile
    piexif
    pillow
    platformdirs
    pyyaml
    safetensors
    toml
  ];
}
