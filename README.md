# CVDP Pure Spec-to-RTL Eval Setup

This repository prepares an independent CVDP comparison setup with two lanes:

- `direct-verilog`: generate SystemVerilog directly from a natural-language spec.
- `arch`: generate ARCH HDL from the same spec, build it to SystemVerilog, then evaluate the generated SystemVerilog.

The subset is intentionally conservative:

- Use CVDP v1.0.4 non-agentic, non-commercial code-generation data.
- Include only prompts that are pure natural-language spec-to-RTL.
- Exclude prompts with input RTL/context files.
- Exclude prompts whose intent is code completion, bug fixing, repair, modification, or partial-code filling.
- Include only harnesses whose `.env` requests `SIM=icarus`.
- Do not copy `output.response` or reference RTL into this setup.

The current filter selects 50 CVDP tasks.

## Source Dataset

Expected local dataset:

```sh
~/github/cvdp_benchmark/full_dataset/cvdp_v1.0.4_nonagentic_code_generation_no_commercial.jsonl
```

The source CVDP checkout used when this setup was created was:

```text
5399ab3e5cf512c1147b45dc75cbca11d489c229
```

## AI Agent Pin

The published artifacts were generated with Codex CLI `0.142.5` using OpenAI
model `gpt-5.5`.

Local run logs that were not committed because they are bulky scratch logs
confirm the following headers:

```text
OpenAI Codex v0.142.5
model: gpt-5.5
provider: openai
```

To reproduce new Codex CLI runs with the same model, invoke Codex with:

```sh
codex exec -m gpt-5.5 "<prompt>"
```

## Generate The Manifest

```sh
./scripts/select_subset.py
```

This writes `manifests/cvdp_spec_icarus.json`. The manifest contains IDs and harness metadata only, not solution text.

## Export Prompts

```sh
./scripts/export_prompts.py --lane direct-verilog
./scripts/export_prompts.py --lane arch
```

Prompt exports are written under `prompts/` and committed here so the exact
benchmark inputs used for the published run are reproducible.

## Candidate Output Layout

Direct Verilog lane:

```text
runs/direct-verilog/<problem_id>/<top_module>.sv
```

ARCH lane:

```text
runs/arch/<problem_id>/<top_module>.arch
```

The evaluator builds ARCH to SystemVerilog before running the same CVDP cocotb/Icarus harness.

## ARCH Lane Pin

Use ARCH compiler and ARCH MCP/skill instructions from `arch-com` release `0.70.6`
or an exact checkout of the merge commit below:

```text
arch-com main: e0f89d9b17a30fef5b49d822a2dc80e8388357b5
```

Recommended local checkout and binary for this eval:

```sh
cd ~/github/arch-com-latest
git fetch origin main
cargo build --release --locked
~/github/arch-com-latest/target/release/arch --version
```

The version check must report `arch 0.70.6`. For ARCH-lane evaluation, export:

```sh
export ARCH_BIN="$HOME/github/arch-com-latest/target/release/arch"
```

The Codex profile used for ARCH generation should expose the `arch-hdl-release-v0706`
MCP server backed by the same checkout:

```text
command: ~/github/arch-com/mcp/.venv/bin/python3
args:    ~/github/arch-com-latest/mcp/arch_mcp_server.py
env:
  ARCH_MCP_WORKSPACE_ROOTS=<this repo>:~/github/arch-com-latest
  ARCH_BIN=~/github/arch-com-latest/target/release/arch
```

## Evaluate

Set up and use the benchmark-era cocotb runtime before evaluating:

```sh
./scripts/setup_cocotb_192.sh
export CVDP_SIM_PYTHON="$PWD/.venv-cvdp-cocotb192/bin/python"
```

CVDP does not pin cocotb in its repo-level Python requirements, because harnesses
normally run inside the configured simulator Docker image. The selected harnesses
are compatible with cocotb 1.x APIs such as `cocotb.coroutine`; this setup pins
`cocotb==1.9.2`, matching the version used by CVDP dataset Dockerfiles that do
pin cocotb explicitly. The evaluator rejects cocotb 2.x by default because it has
API-breaking changes that can turn valid benchmark harnesses into tooling
failures.

Evaluate one problem:

```sh
./scripts/evaluate_candidate.py --lane direct-verilog --problem cvdp_copilot_bus_arbiter_0001
./scripts/evaluate_candidate.py --lane arch --problem cvdp_copilot_bus_arbiter_0001
```

Evaluate all selected problems:

```sh
./scripts/evaluate_candidate.py --lane direct-verilog --all
./scripts/evaluate_candidate.py --lane arch --all
```

Useful environment variables:

- `CVDP_JSONL`: override the dataset path.
- `CVDP_SIM_PYTHON`: Python with `cocotb==1.9.2`.
- `CVDP_SKIP_COCOTB_VERSION_CHECK=1`: bypass the cocotb version guard for debugging only.
- `ARCH_BIN`: ARCH compiler binary for the ARCH lane; pin this to ARCH `0.70.6`.

## Documented Compatibility Shims

The evaluator keeps candidate source files intact, but may apply narrow,
documented transformations to the generated SystemVerilog copied into the
temporary simulator workdir when a CVDP harness observes implementation-visible
names that are not part of the public RTL interface.

- `cvdp_copilot_digital_dice_roller_0001`, ARCH lane only: the spec names an
  internal 3-bit register `counter` and the harness observes that signal.
  `counter` is a reserved ARCH construct keyword, so ARCH candidates cannot
  declare a register with that exact source name. The evaluator renames the
  generated SV register used for the dice value history, currently
  `shown_value` or `count_value`, to `counter` before running cocotb/Icarus.
  This shim is name-only: it does not change dice behavior, reset behavior,
  parameters, clocking, or public ports.

## Benchmark Boundary

Generation agents should read only the prompt exports and should write only into their lane under `runs/`. They should not inspect the full JSONL dataset, `output.response`, reference RTL, archived prior runs, or generated outputs from the other lane.
