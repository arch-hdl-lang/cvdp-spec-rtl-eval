# ARCH Lane

This lane is pinned to ARCH `0.70.6` for clean CVDP first-pass and repair
runs. Use an `arch-com` checkout at:

```text
e0f89d9b17a30fef5b49d822a2dc80e8388357b5
```

Before running the lane, build and export the compiler:

```sh
cd ~/github/arch-com-latest
git fetch origin main
cargo build --release --locked
export ARCH_BIN="$HOME/github/arch-com-latest/target/release/arch"
$ARCH_BIN --version
```

The version check must report `arch 0.70.6`. The Codex profile used for
generation must expose an `arch-hdl-release-v0706` MCP server backed by the same
checkout and binary.

Use prompts exported by:

```sh
./scripts/export_prompts.py --lane arch
```

For each prompt, write one candidate ARCH file:

```text
runs/arch/<problem_id>/<top_module>.arch
```

Rules:

- Use only the prompt text.
- Do not inspect `output.response`, `output.context`, reference RTL, or the direct-Verilog lane.
- Do not inspect CVDP harness internals before generation.
- Use the ARCH MCP/skill workflow when generating or repairing `.arch` files.
- Use Icarus/cocotb only as a black-box evaluator through `scripts/evaluate_candidate.py`.
- Prefer the simplest ARCH structure that directly matches the prompt. Use one module/FSM, helper functions, plain loops, and direct packed assignments before generated submodules, deeply nested `Vec` intermediates, or added buffering.
- Prioritize first-class `fsm` for stateful control, protocol sequencing, arbitration, request/response handshakes, ready/valid control, and multi-cycle datapath control. Include a `///` transition table before the FSM with current state, input condition, next state, and externally visible outputs. Preserve state-derived/combinational outputs when same-cycle visibility is implied; avoid replacing FSM control with ad-hoc phase registers or `pipe_reg` outputs unless the prompt explicitly requires registered outputs.
- Preserve prompt-implied timing; do not add skid buffers, extra registered stages, or backpressure state unless the specification requires them.
- Keep candidates Icarus-compatible: avoid DUT `assert`/`cover`, do not use `.reverse(...)`, prefer explicit loops/concats for bit swizzling, and use wrapping arithmetic instead of slicing arithmetic expressions.
- Do not use ARCH `inside` set-membership expressions for Icarus-targeted candidates.
