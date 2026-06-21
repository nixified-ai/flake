{ ... }:
{
  postPatch = ''
    sed -i '/with open/,$d' __init__.py
    echo 'WEB_DIRECTORY = "./web/"' >> __init__.py
    mkdir -p web/js
    echo "const extension_base_path = 'comfyui-asyncpause';" > web/js/path.js
    echo "export{ extension_base_path };" >> web/js/path.js
  '';
}
