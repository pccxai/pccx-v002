#!/usr/bin/env bash
# PCCX(TM) — reusable AI accelerator project.
# SPDX-FileCopyrightText: 2026 Hyun Woo Kim
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

pattern='gemma|gemma3n|gemma4|llama|qwen|mistral|e4b|kv260|kria|zcu104|alveo|versal'
scan_paths=(
    LLM/rtl
    Vision/rtl
    Voice/rtl
    common/rtl
    compatibility
)

hits="$(
    grep -RInEi -- "$pattern" "${scan_paths[@]}" \
        | awk '
            /^compatibility\/v002-contract.yaml:[0-9]+:  - pccx-FPGA-NPU-LLM-kv260      # LLM package, Gemma 3N E4B target$/ {
                next
            }
            { print }
        ' || true
)"

if [[ -n "$hits" ]]; then
    printf 'Boundary token hits:\n%s\n' "$hits" >&2
    exit 1
fi

exit 0
