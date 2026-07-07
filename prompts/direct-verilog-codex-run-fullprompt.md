You are running the CVDP pure spec-to-RTL direct-Verilog benchmark lane.

Repository: /Users/shuqingzhao/github/arch-hdl-lang/cvdp-spec-rtl-eval
Lane: direct-verilog
Selected subset: manifests/cvdp_spec_icarus.json
Prompt export: prompts/direct-verilog.jsonl

Benchmark rules:
- Generate SystemVerilog directly from each prompt in prompts/direct-verilog.jsonl.
- Do not inspect CVDP output.response, output.context, reference RTL, archived prior runs, or the ARCH lane.
- Do not inspect harness internals before first-pass generation; use the evaluator only as a black-box pass/fail oracle.
- Use the pinned CVDP simulator runtime: run `./scripts/setup_cocotb_192.sh` if needed, export `CVDP_SIM_PYTHON="$PWD/.venv-cvdp-cocotb192/bin/python"`, and do not override the evaluator's cocotb version guard.
- Do not wrap evaluator calls in a separate 30-second timeout; the evaluator owns the simulation timeout.
- Preserve first-pass generated files and accounting before any repair.
- Repair is required after first-pass failures; do not use resampling as the repair method.
- Maximum repair attempts per failed problem: 4.
- Each problem should be treated independently. Do not use another problem's generated solution as context.

First pass:
1. Run ./scripts/check_setup.sh.
2. Run ./scripts/export_prompts.py --lane direct-verilog.
3. Run ./scripts/materialize_fullprompts.py --lane direct-verilog.
4. For each record in prompts/direct-verilog.jsonl, read only that prompt and write the candidate to:
   runs/direct-verilog/<problem_id>/<top_module>.sv
5. Also write the raw model response to:
   runs/direct-verilog/<problem_id>/<problem_id>_response.txt
6. Evaluate with:
   ./scripts/evaluate_candidate.py --lane direct-verilog --problem <problem_id>
7. Record first-pass accounting before repair.

Repair:
1. For failed first-pass problems only, diagnose using the candidate and the black-box evaluator result/log.
2. Make targeted changes based on an explicit hypothesis.
3. Save each repair attempt as:
   runs/direct-verilog/<problem_id>/repair_attempt_01.sv
   runs/direct-verilog/<problem_id>/repair_attempt_02.sv
   runs/direct-verilog/<problem_id>/repair_attempt_03.sv
   runs/direct-verilog/<problem_id>/repair_attempt_04.sv
4. For evaluation, copy the current repair attempt to runs/direct-verilog/<problem_id>/<top_module>.sv, then run the evaluator.
5. Stop repairing a problem after the first passing attempt or after 4 failed attempts.

Final output:
- Produce first_pass_accounting.csv/json and repair_accounting.csv/json under runs/direct-verilog.
- Summarize first pass, repair attempts per failed problem, final pass count, and unrepaired problems.
