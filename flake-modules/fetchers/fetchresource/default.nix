{ fetchurl }:
{
  url,
  name,
  hash ? "",
  sha256 ? "",
  ...
}@args:
fetchurl (
  args
  // {
    name = "model";
    passthru = (
      {
        inherit name;
      }
      // args.passthru
    );
    curlOpts = "-H @/build/ACTIVE_TOKEN";
    netrcImpureEnvVars = [
      "HF_TOKEN"
      "CIVITAI_API_TOKEN"
    ];
    netrcPhase = ''
      # Workaround for newer curl versions to prevent crashing due to non-existent netrc file
      touch /build/netrc

      # Warn if HF_TOKEN or CIVITAI_API_TOKEN are not set or didn't work, in
      # the case of failure to fetch
      warnEmptyTokensHook() {
        if [ -z "$HF_TOKEN" ]; then
          echo "Warning: HF_TOKEN is not set. Please set it to access gated Hugging Face models."
        elif [ -n "$HF_TOKEN" ]; then
          echo "Warning: HF_TOKEN is set, but fetching didn't seem to work, check your token!"
        fi
        if [ -z "$CIVITAI_API_TOKEN" ]; then
          echo "Warning: CIVITAI_API_TOKEN is not set. Please set it to access gated CivitAI resources."
        elif [ -n "$CIVITAI_API_TOKEN" ]; then
          echo "Warning: CIVITAI_API_TOKEN is set, but fetching didn't seem to work, check your token!"
        fi
      }
      failureHooks+=(warnEmptyTokensHook)

      # echo is a bash internal and doesn't create a process in /proc/*/cmdline
      if [[ '${url}' == *huggingface* ]] && [[ -n "$HF_TOKEN" ]];  then
        echo "adding Authorization: Bearer HF_TOKEN"
        echo "Authorization: Bearer $HF_TOKEN" > /build/ACTIVE_TOKEN
      elif [[ '${url}' == *civitai* ]] && [[ -n "$CIVITAI_API_TOKEN" ]];  then
        echo "adding Authorization: Bearer CIVITAI_API_TOKEN"
        echo "Authorization: Bearer $CIVITAI_API_TOKEN" > /build/ACTIVE_TOKEN
      else
        echo "No Authorization token to add!"
        > /build/ACTIVE_TOKEN
      fi
    '';
    inherit url hash sha256;
  }
)
