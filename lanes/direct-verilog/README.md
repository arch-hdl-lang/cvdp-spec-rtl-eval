# Direct-Verilog Lane

Use prompts exported by:

```sh
./scripts/export_prompts.py --lane direct-verilog
```

For each prompt, write one candidate SystemVerilog file:

```text
runs/direct-verilog/<problem_id>/<top_module>.sv
```

Rules:

- Use only the prompt text.
- Do not inspect `output.response`, `output.context`, reference RTL, or the ARCH lane.
- Do not inspect CVDP harness internals before generation.
- Use Icarus/cocotb only as a black-box evaluator through `scripts/evaluate_candidate.py`.

