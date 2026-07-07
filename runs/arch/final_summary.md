# ARCH Repair Final Summary

- Source first-pass accounting: `runs/arch/first_pass_accounting.json`
- Pre-repair archive: `archives/20260705-233728-arch-before-repair-max4`
- ARCH compiler: `/Users/shuqingzhao/github/arch-com-latest/target/release/arch` (`0.70.6`)
- Runtime: `osvb-docker`
- Repair scope: only problems marked failed in first-pass accounting
- Max repair attempts per failed problem: 4

## Totals

- First-pass result before repair: 35/50 passed; 15 failed
- Failed problems selected for repair: 15
- Successfully repaired: 12
- Still unrepaired after repair limit: 3
- Final effective pass count: 47/50

## Per-Problem Results

| Problem ID | Top Module | Attempts | Result | Passing Attempt |
|---|---|---:|---|---:|
| cvdp_copilot_axi_stream_upscale_0001 | axis_upscale | 1 | repaired | 1 |
| cvdp_copilot_clock_jitter_detection_module_0003 | clock_jitter_detection_module | 2 | repaired | 2 |
| cvdp_copilot_convolutional_encoder_0001 | convolutional_encoder | 1 | repaired | 1 |
| cvdp_copilot_data_bus_controller_0001 | data_bus_controller | 1 | repaired | 1 |
| cvdp_copilot_decode_firstbit_0001 | cvdp_copilot_decode_firstbit | 2 | repaired | 2 |
| cvdp_copilot_digital_dice_roller_0001 | digital_dice_roller | 2 | repaired | 2 |
| cvdp_copilot_digital_stopwatch_0001 | dig_stopwatch | 4 | unrepaired |  |
| cvdp_copilot_fibonacci_series_0001 | fibonacci_series | 3 | repaired | 3 |
| cvdp_copilot_packet_controller_0001 | packet_controller | 4 | unrepaired |  |
| cvdp_copilot_perf_counters_0001 | cvdp_copilot_perf_counters | 4 | repaired | 4 |
| cvdp_copilot_prbs_gen_0003 | cvdp_prbs_gen | 1 | repaired | 1 |
| cvdp_copilot_restoring_division_0001 | restoring_division | 2 | repaired | 2 |
| cvdp_copilot_static_branch_predict_0001 | static_branch_predict | 3 | repaired | 3 |
| cvdp_copilot_ttc_lite_0001 | ttc_counter_lite | 2 | repaired | 2 |
| cvdp_copilot_vending_machine_0001 | vending_machine | 4 | unrepaired |  |

## Repaired Successfully

- cvdp_copilot_axi_stream_upscale_0001: attempt 1
- cvdp_copilot_clock_jitter_detection_module_0003: attempt 2
- cvdp_copilot_convolutional_encoder_0001: attempt 1
- cvdp_copilot_data_bus_controller_0001: attempt 1
- cvdp_copilot_decode_firstbit_0001: attempt 2
- cvdp_copilot_digital_dice_roller_0001: attempt 2
- cvdp_copilot_fibonacci_series_0001: attempt 3
- cvdp_copilot_perf_counters_0001: attempt 4
- cvdp_copilot_prbs_gen_0003: attempt 1
- cvdp_copilot_restoring_division_0001: attempt 2
- cvdp_copilot_static_branch_predict_0001: attempt 3
- cvdp_copilot_ttc_lite_0001: attempt 2

## Unrepaired After 4 Attempts

- cvdp_copilot_digital_stopwatch_0001
- cvdp_copilot_packet_controller_0001
- cvdp_copilot_vending_machine_0001

## Fresh Four-Problem Repair Run

- cvdp_copilot_digital_stopwatch_0001: unrepaired after 4 fresh attempts; final public failures remain CLK_FREQ = 3, 50, 63.
- cvdp_copilot_packet_controller_0001: unrepaired after 4 fresh attempts; final public failures remain invalid checksum/header cases.
- cvdp_copilot_restoring_division_0001: repaired on fresh attempt 2; active candidate passes public OSVB evaluation.
- cvdp_copilot_vending_machine_0001: unrepaired after 4 fresh attempts; final public suite still fails all 10 parameter cases.

## Accounting Artifacts

- `runs/arch/repair_accounting.csv` records every repair attempt summary.
- `runs/arch/repair_accounting.json` records aggregate totals, per-problem summaries, and attempt records.
