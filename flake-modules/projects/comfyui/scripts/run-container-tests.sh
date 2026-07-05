#!/usr/bin/env bash

enable_flag=0
run_args=()

for arg in "$@"; do
    if [[ "$arg" == "--enable" ]]; then
        enable_flag=1
    else
        run_args+=("$arg")
    fi
done

if [[ "$enable_flag" -eq 1 ]]; then
    nix flake check --override-input enable-container-tests path:./flags/container-tests/enabled --no-write-lock-file "${run_args[@]}"
else
    nix flake check "${run_args[@]}"
fi
