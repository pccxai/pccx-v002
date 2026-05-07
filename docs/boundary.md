# Boundary

This repository uses a four-way classification rule.

## Classification

- `contract`: architecture-level interfaces that downstream consumers
  depend on. These live in `compatibility/` and related docs.
- `arch-generation`: reusable PCCX v002 implementation sources,
  reusable verification scaffolds, and package-level helper scripts.
  These live under the relevant domain directory or `common/`.
- `board`: board platform files, constraints, project scripts, board
  top wrappers, clocks, resets, and PS/PL wiring. These stay in the
  board integration repository.
- `model`: model routing, runtime, weights, application code, and
  model-specific scheduling. These stay in the model application
  repository.

The model and board consume the IP core. The IP core does not take a
dependency on model-specific or board-specific naming inside `rtl/` or
`compatibility/` paths.

## Naming Red Flags

The following names are red flags inside `LLM/rtl/`, `Vision/rtl/`,
`Voice/rtl/`, `common/rtl/`, and `compatibility/`:

```text
gemma  gemma3n  gemma4  llama  qwen  mistral  e4b
kv260  kria  zcu104  alveo  versal
```

These names are allowed only in README files, docs compatibility
sections, and the required `known_application_repos` entry in
`compatibility/v002-contract.yaml`.
