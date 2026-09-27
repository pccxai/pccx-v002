# pccx-v002

PCCX is an open-source semiconductor project initiated and operated by
**Altifigence**. [Start here](https://github.com/pccxai/pccx/blob/main/START_HERE.md)
· [Website](https://pccx.ai/) · [Roadmap](https://github.com/orgs/pccxai/projects/1)
· [Transparency](https://pccx.ai/en/legal/transparency/).
The repository license and file-level notices define usage rights; project
participation does not transfer contributor ownership or require a paid tool.


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

## Trademark

`PCCX™` is a mark used by the PCCX project. Korean trademark
applications are pending for PCCX in Classes 09 and 42. Registration
has not been granted; do not use `PCCX®` until the central trademark
policy is updated. See
[`pccx/TRADEMARKS.md`](https://github.com/pccxai/pccx/blob/main/TRADEMARKS.md).

## First local check

From a Bash environment with Git and standard Unix tools:

```bash
bash scripts/check_repo_boundary.sh
git rev-parse HEAD
```

This checks repository separation, not RTL correctness. The xsim verification
entrypoint is `LLM/sim/run_verification.sh`; it needs Vivado tools and the legacy
lab trace bridge. See the [start guide](https://github.com/pccxai/pccx/blob/main/START_HERE.md)
for that dependency and the current evidence boundary.

## License

Apache License 2.0; see [LICENSE](LICENSE) and any narrower file notices.
Brand use is governed separately by the linked trademark policy.
