# pccx-v002

Reusable PCCX v002 IP-core package. Board- and model-agnostic.

## Purpose

This repository contains reusable PCCX v002 IP-core package sources and
contracts.

## Non-purpose

Not a board integration repo. Not a model app repo.

## Domain layout

- `LLM`: LLM-domain IP-core sources, testbench scaffolds, formal
  scaffolds, simulation scaffolds, scripts, and docs.
- `Vision`: vision-domain IP-core sources, testbench scaffolds, and docs.
- `Voice`: voice-domain IP-core sources, testbench scaffolds, and docs.
- `common`: reusable interfaces, packages, wrappers, testbench scaffolds,
  and docs shared across domains.

## Boundary rule

The model and the board consume the IP core. The IP core never references
a specific model name or board name in `rtl/` or `compatibility/`.

## Initial consumers

- `pccx-FPGA-NPU-LLM-kv260`: LLM package, Gemma 3N E4B target.

## Compatibility version

The compatibility version source is
`compatibility/v002-contract.yaml`.
