{ inputs, ... }:
{
  flake = {
    herculesCI.ciSystems = [ "x86_64-linux" ];
    effects = let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      hci-effects = inputs.hercules-ci-effects.lib.withPkgs pkgs;
    in { branch, rev, ... }: {
      macos-repeatability-test = hci-effects.mkEffect {
        secretsMap."ipfsBasicAuth" = "ipfsBasicAuth";
        buildInputs = with pkgs; [ libwebp gnutar curl nix jq coreutils-full ];
        effectScript = ''
          readSecretString ipfsBasicAuth .basicauth > .basicauth
          export NIX_CONFIG="experimental-features = nix-command flakes"

          # How many times to build macOS
          max_iterations=1
          iteration=0

          function build {
            { nix build ${inputs.self}#macos-ventura-image --timeout 5000 --keep-failed -L 2>&1 >&3 | tee >(grep -oP "keeping build directory '.*?'" | awk -F"'" '{print $2}') >&2; } 3>&1
          }
          function rebuild {
            { nix build ${inputs.self}#macos-ventura-image --rebuild --timeout 5000 --keep-failed -L 2>&1 >&3 | tee >(grep -oP "keeping build directory '.*?'" | awk -F"'" '{print $2}') >&2; } 3>&1
          }

          function upload_failure {
            export TMPDIR="/hostTmp"
            export DRVNAME=$(basename $1)
            export IMAGESPATH="$TMPDIR/$DRVNAME"
            mkdir images
            for i in $TMPDIR/$DRVNAME/tmp*/*.png
            do
              echo converting "$i" into webp
              ( cwebp -q 10 $i -o images/$(basename $i).webp ) &
            done
            wait
            tar -cf nixtheplanet-macos-debug.tar images
            export RESPONSE=$(curl -H @.basicauth -F file=@nixtheplanet-macos-debug.tar https://ipfs-api.croughan.sh/api/v0/add)
            export CID=$(echo "$RESPONSE" | jq -r .Hash)
            export ADDRESS="https://ipfs.croughan.sh/ipfs/$CID"

            echo NixThePlanet: Failure screen capture is available at: "$ADDRESS"
            exit 254
          }

          echo 'Running Nix for the first time'
          set +e
          nix_output=$(build)
          set -e
          if [[ "$nix_output" == *"/tmp"* ]]
          then
            upload_failure $nix_output
            echo NixThePlanet: first nix build failed, but this should have been cached!? Something weird is going on.
            exit 1
          fi

          while [ $iteration -lt $max_iterations ]
          do
            echo Running Nix iteration "$iteration"
            set +e
            nix_output=$(rebuild)
            set -e
            if [[ "$nix_output" == *"/tmp"* ]]
            then
              upload_failure $nix_output
              echo NixThePlanet: iteration "$iteration" failed
              exit 1
            fi
            echo NixThePlanet: iteration "$iteration" succeeded
            ((iteration++))
          done
        '';
      };
    };
  };
}
