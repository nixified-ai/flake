#!/usr/bin/env bash

exec nix flake check \
  --override-input enable-container-tests path:./flags/container-tests/enabled \
  --no-write-lock-file \
  "${@}"
