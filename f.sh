nix build .#macOS-ventura-image
mkdir test-logs
while true; do
  if ! nix build --timeout 5000 .#macOS-ventura-image --rebuild; then
    nix log .#macOS-ventura-image > test-logs/log-$(date +%s)-$RANDOM.txt
  fi
done
