# ARCH First-Pass Summary

- Lane: arch
- Selected subset: manifests/cvdp_spec_icarus.json
- Prompt export: prompts/arch.jsonl
- ARCH compiler: arch 0.70.6
- Runtime: osvb-docker
- First-pass evaluations: exactly one per problem
- Repairs performed: none
- Rerun note: selected current failures were archived, regenerated from prompts only, and evaluated once after prompt updates.

## Totals

- Total problems: 50
- Passed: 35
- Failed/unrepaired: 15

## Failed Problems

| Problem ID | Top Module | Check | Build | Eval | Failure summary |
|---|---|---:|---:|---:|---|
| cvdp_copilot_axi_stream_upscale_0001 | axis_upscale | PASS | PASS | FAIL | Protocol/timing mismatch: evaluator expected s_axis_ready to be 0 but observed 1 at 250 ns; check/build/lint passed. |
| cvdp_copilot_clock_jitter_detection_module_0003 | clock_jitter_detection_module | PASS | PASS | FAIL | Algorithmic/timing mismatch: jitter detection cocotb parameterizations failed after Icarus simulation; check/build/lint passed. |
| cvdp_copilot_convolutional_encoder_0001 | convolutional_encoder | PASS | PASS | FAIL | Protocol/timing mismatch: reset-focused cocotb test failed while other encoder tests passed; check/build/lint passed. |
| cvdp_copilot_data_bus_controller_0001 | data_bus_controller | PASS | PASS | FAIL | Interface mismatch: evaluator expected DUT child port s_ready, but generated module did not expose it; check/build/lint passed. |
| cvdp_copilot_decode_firstbit_0001 | cvdp_copilot_decode_firstbit | PASS | PASS | FAIL | Algorithmic mismatch: evaluator reported Out_Found signal mismatch; check/build/lint passed. |
| cvdp_copilot_digital_dice_roller_0001 | digital_dice_roller | PASS | PASS | FAIL | Interface mismatch: evaluator expected DUT child port reset, but generated module did not expose it; check/build/lint passed. |
| cvdp_copilot_digital_stopwatch_0001 | dig_stopwatch | PASS | PASS | FAIL | Protocol/timing mismatch: stopwatch cocotb parameterizations failed after simulation; check/build/lint passed. |
| cvdp_copilot_fibonacci_series_0001 | fibonacci_series | PASS | PASS | FAIL | Algorithmic mismatch: evaluator expected 0 but observed 3 from DUT; check/build/lint passed. |
| cvdp_copilot_packet_controller_0001 | packet_controller | PASS | PASS | FAIL | Algorithmic/protocol mismatch: packet controller failed invalid checksum/header cocotb cases; check/build/lint passed. |
| cvdp_copilot_perf_counters_0001 | cvdp_copilot_perf_counters | PASS | PASS | FAIL | Algorithmic mismatch: performance counter cocotb tests failed, including overflow behavior; check/build/lint passed. |
| cvdp_copilot_prbs_gen_0003 | cvdp_prbs_gen | PASS | PASS | FAIL | Build/lint/simulation mismatch: evaluator failed multiple PRBS parameterizations via subprocess failure; ARCH check/build/lint passed with a comb-SCC warning. |
| cvdp_copilot_restoring_division_0001 | restoring_division | PASS | PASS | FAIL | Algorithmic mismatch: restoring division failed parameterized WIDTH tests after simulation; check/build/lint passed. |
| cvdp_copilot_static_branch_predict_0001 | static_branch_predict | PASS | PASS | FAIL | Interface mismatch: evaluator expected DUT child port register_addr_i, but generated module did not expose it; check/build/lint passed. |
| cvdp_copilot_ttc_lite_0001 | ttc_counter_lite | PASS | PASS | FAIL | Interface mismatch: evaluator expected DUT child port enable, but generated module did not expose it; check/build/lint passed. |
| cvdp_copilot_vending_machine_0001 | vending_machine | PASS | PASS | FAIL | Protocol/timing mismatch: vending machine failed all parameterized cocotb cases after simulation; check/build/lint passed. |

## Passing Problems

| Problem ID | Top Module | Check | Build | Eval |
|---|---|---:|---:|---:|
| cvdp_copilot_16qam_mapper_0001 | qam16_mapper_interpolated | PASS | PASS | PASS |
| cvdp_copilot_16qam_mapper_0006 | qam16_demapper_interpolated | PASS | PASS | PASS |
| cvdp_copilot_64b66b_encoder_0001 | encoder_64b66b | PASS | PASS | PASS |
| cvdp_copilot_8x3_priority_encoder_0001 | priority_encoder_8x3 | PASS | PASS | PASS |
| cvdp_copilot_Carry_Lookahead_Adder_0001 | GP | PASS | PASS | PASS |
| cvdp_copilot_GFCM_0001 | glitch_free_mux | PASS | PASS | PASS |
| cvdp_copilot_axis_joiner_0001 | axis_joiner | PASS | PASS | PASS |
| cvdp_copilot_bcd_counter_0001 | bcd_counter | PASS | PASS | PASS |
| cvdp_copilot_binary_to_one_hot_decoder_0001 | binary_to_one_hot_decoder | PASS | PASS | PASS |
| cvdp_copilot_bus_arbiter_0001 | cvdp_copilot_bus_arbiter | PASS | PASS | PASS |
| cvdp_copilot_caesar_cipher_0001 | caesar_cipher | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_car_parking_management_0001 | car_parking_system | PASS | PASS | PASS |
| cvdp_copilot_cascaded_adder_0001 | cascaded_adder | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_clock_divider_0003 | clock_divider | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_comparator_0001 | signed_unsigned_comparator | PASS | PASS | PASS |
| cvdp_copilot_complex_multiplier_0001 | complex_multiplier | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_data_width_converter_0003 | data_width_converter | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_dbi_0001 | dbi_enc | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_edge_detector_0001 | sync_pos_neg_edge_detector | PASS | UNKNOWN | PASS |
| cvdp_copilot_factorial_0001 | factorial | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_gf_multiplier_0001 | gf_multiplier | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_hebbian_rule_0017 | hebb_gates | PASS | PASS | PASS |
| cvdp_copilot_load_store_unit_0001 | load_store_unit | PASS | PASS | PASS |
| cvdp_copilot_matrix_multiplier_0001 | matrix_multiplier | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_morse_code_0001 | morse_encoder | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_moving_average_0001 | moving_average | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_nbit_swizzling_0001 | nbit_swizzling | PASS | PASS | PASS |
| cvdp_copilot_palindrome_3b_0002 | palindrome_detect | PASS | PASS | PASS |
| cvdp_copilot_perceptron_0001 | perceptron_gates | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_perfect_squares_0001 | perfect_squares_generator | PASS | PASS | PASS |
| cvdp_copilot_reverse_bits_0001 | reverse_bits | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_sequencial_binary_to_one_hot_decoder_0001 | binary_to_one_hot_decoder_sequential | UNKNOWN | UNKNOWN | PASS |
| cvdp_copilot_sync_lifo_0001 | sync_lifo | PASS | PASS | PASS |
| cvdp_copilot_thermostat_0001 | thermostat | PASS | PASS | PASS |
| cvdp_copilot_unpacker_one_hot_0001 | unpack_one_hot | UNKNOWN | UNKNOWN | PASS |

## Repair Results

- Pre-repair first-pass result: 35/50 passed; 15 failed.
- Failed problems selected for repair: 15.
- Successfully repaired: 6.
- Unrepaired after 4 attempts: 9.
- Final effective pass count after repair: 41/50.
- Detailed repair accounting: `runs/arch/repair_accounting.csv` and `runs/arch/repair_accounting.json`.
