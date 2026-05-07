# v002 IP-core extraction plan
Source: pccx-FPGA-NPU-LLM-kv260 @ 18d4631f54721684ef6747bc37cf8538653a7a9e

Scope: tracked files under `hw/`, `sw/`, `scripts/`, `formal/`,
`configs/`, `evidence/`, `tools/`, and `docs/` at the source SHA above.
Build and simulator output directories observed on disk are excluded because
they are not part of the source SHA.

## Counts

ipcore-LLM:    66
ipcore-common: 14
board-kv260:   8 (stays in source repo)
app-llm:       9 (stays in source repo)
evidence:      17 (stays in source repo)
unclear:       2 (needs my decision)
out-of-scope:  8

## ipcore-LLM

| source path | source SHA | proposed dest | rename? | notes |
| --- | --- | --- | --- | --- |
| `formal/sail/Makefile` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/Makefile` | no | reusable ISA formal harness |
| `formal/sail/README.md` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/README.md` | no | reusable ISA formal docs |
| `formal/sail/pccx.sail_project` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/pccx.sail_project` | no | reusable ISA project file |
| `formal/sail/src/pccx_decode.sail` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/src/pccx_decode.sail` | no | reusable decode semantics |
| `formal/sail/src/pccx_execute.sail` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/src/pccx_execute.sail` | no | reusable execute semantics |
| `formal/sail/src/pccx_regs.sail` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/src/pccx_regs.sail` | no | remove model-specific comment before copy |
| `formal/sail/src/pccx_types.sail` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/src/pccx_types.sail` | no | reusable type semantics |
| `formal/sail/src/prelude.sail` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/src/prelude.sail` | no | reusable prelude |
| `formal/sail/tests/smoke_decode.sail` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/formal/sail/tests/smoke_decode.sail` | no | reusable smoke test |
| `hw/rtl/CVO_CORE/CVO_cordic_unit.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/cvo/CVO_cordic_unit.sv` | no | reusable SFU arithmetic block |
| `hw/rtl/CVO_CORE/CVO_sfu_unit.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/cvo/CVO_sfu_unit.sv` | no | reusable SFU block |
| `hw/rtl/CVO_CORE/CVO_top.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/cvo/CVO_top.sv` | no | reusable SFU top |
| `hw/rtl/MAT_CORE/FROM_mat_result_packer.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/FROM_mat_result_packer.sv` | no | reusable GEMM result path |
| `hw/rtl/MAT_CORE/GEMM_Array.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_Array.svh` | no | reusable GEMM header |
| `hw/rtl/MAT_CORE/GEMM_accumulator.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_accumulator.sv` | no | reusable GEMM accumulator |
| `hw/rtl/MAT_CORE/GEMM_dsp_packer.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_dsp_packer.sv` | no | reusable W4A8 packer |
| `hw/rtl/MAT_CORE/GEMM_dsp_unit.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_dsp_unit.sv` | no | reusable DSP unit |
| `hw/rtl/MAT_CORE/GEMM_dsp_unit_last_ROW.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_dsp_unit_last_ROW.sv` | no | reusable DSP row variant |
| `hw/rtl/MAT_CORE/GEMM_fmap_staggered_delay.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_fmap_staggered_delay.sv` | no | reusable GEMM alignment block |
| `hw/rtl/MAT_CORE/GEMM_sign_recovery.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_sign_recovery.sv` | no | reusable W4A8 sign recovery |
| `hw/rtl/MAT_CORE/GEMM_systolic_array.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_systolic_array.sv` | no | reusable systolic array |
| `hw/rtl/MAT_CORE/GEMM_systolic_top.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_systolic_top.sv` | no | remove board-specific comment before copy |
| `hw/rtl/MAT_CORE/GEMM_weight_dispatcher.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/GEMM_weight_dispatcher.sv` | no | reusable GEMM weight dispatcher |
| `hw/rtl/MAT_CORE/mat_result_normalizer.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/mat/mat_result_normalizer.sv` | no | reusable result normalizer |
| `hw/rtl/MEM_control/IO/mem_IO.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/interfaces/mem_IO.svh` | no | LLM memory uop interface header |
| `hw/rtl/MEM_control/IO/mem_u_operation_queue.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_u_operation_queue.sv` | no | reusable memory queue |
| `hw/rtl/MEM_control/memory/Constant_Memory/shape_const_ram.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/Constant_Memory/shape_const_ram.sv` | no | reusable shape constant RAM |
| `hw/rtl/MEM_control/memory/mem_BUFFER.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_BUFFER.sv` | no | remove board-specific comment before copy |
| `hw/rtl/MEM_control/memory/mem_GLOBAL_cache.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_GLOBAL_cache.sv` | no | reusable L2 cache block |
| `hw/rtl/MEM_control/top/mem_CVO_stream_bridge.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_CVO_stream_bridge.sv` | no | reusable CVO stream bridge |
| `hw/rtl/MEM_control/top/mem_HP_buffer.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_HP_buffer.sv` | no | remove board-specific comment before copy |
| `hw/rtl/MEM_control/top/mem_L2_cache_fmap.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_L2_cache_fmap.sv` | no | reusable L2 fmap path |
| `hw/rtl/MEM_control/top/mem_dispatcher.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/memory/mem_dispatcher.sv` | no | reusable memory dispatcher |
| `hw/rtl/NPU_Controller/Global_Scheduler.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/controller/Global_Scheduler.sv` | no | reusable scheduler |
| `hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_memctrl.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/packages/isa/isa_memctrl.svh` | no | reusable ISA header |
| `hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_pkg.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/packages/isa/isa_pkg.sv` | no | reusable ISA package |
| `hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_x32.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/packages/isa/isa_x32.svh` | no | reusable ISA header |
| `hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_x64.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/packages/isa/isa_x64.svh` | no | reusable ISA header |
| `hw/rtl/NPU_Controller/NPU_Control_Unit/ctrl_decode_const.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/packages/controller/ctrl_decode_const.svh` | no | reusable decoder constants |
| `hw/rtl/NPU_Controller/NPU_Control_Unit/ctrl_npu_decoder.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/controller/ctrl_npu_decoder.sv` | no | reusable decoder |
| `hw/rtl/NPU_Controller/NPU_frontend/AXIL_CMD_IN.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/controller/AXIL_CMD_IN.sv` | no | reusable AXI-Lite command frontend |
| `hw/rtl/NPU_Controller/NPU_frontend/AXIL_STAT_OUT.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/controller/AXIL_STAT_OUT.sv` | no | reusable AXI-Lite status frontend |
| `hw/rtl/NPU_Controller/NPU_frontend/ctrl_npu_frontend.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/controller/ctrl_npu_frontend.sv` | no | reusable frontend wrapper |
| `hw/rtl/NPU_Controller/npu_controller_top.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/controller/npu_controller_top.sv` | no | reusable controller top |
| `hw/rtl/NPU_top.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/top/pccx_npu_top.sv` | yes | package top rename; remove board refs and non-source doc reference before copy |
| `hw/rtl/PREPROCESS/fmap_cache.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/preprocess/fmap_cache.sv` | no | remove model-specific comment before copy |
| `hw/rtl/PREPROCESS/preprocess_bf16_fixed_pipeline.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/preprocess/preprocess_bf16_fixed_pipeline.sv` | no | reusable preprocess pipeline |
| `hw/rtl/PREPROCESS/preprocess_fmap.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/preprocess/preprocess_fmap.sv` | no | reusable preprocess wrapper |
| `hw/rtl/VEC_CORE/GEMV_Vec_Matrix_MUL.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/vec/GEMV_Vec_Matrix_MUL.svh` | no | reusable GEMV header |
| `hw/rtl/VEC_CORE/GEMV_accumulate.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/vec/GEMV_accumulate.sv` | no | reusable GEMV accumulator |
| `hw/rtl/VEC_CORE/GEMV_generate_lut.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/vec/GEMV_generate_lut.sv` | no | reusable GEMV LUT helper |
| `hw/rtl/VEC_CORE/GEMV_reduction.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/vec/GEMV_reduction.sv` | no | reusable GEMV reduction |
| `hw/rtl/VEC_CORE/GEMV_reduction_branch.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/vec/GEMV_reduction_branch.sv` | no | reusable GEMV reduction branch |
| `hw/rtl/VEC_CORE/GEMV_top.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/rtl/core/vec/GEMV_top.sv` | no | reusable GEMV top |
| `hw/sim/run_verification.sh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/sim/run_verification.sh` | no | reusable xsim runner; review external trace-tool path before copy |
| `hw/tb/tb_FROM_mat_result_packer.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_FROM_mat_result_packer.sv` | no | reusable testbench |
| `hw/tb/tb_GEMM_dsp_packer_sign_recovery.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_GEMM_dsp_packer_sign_recovery.sv` | no | reusable testbench |
| `hw/tb/tb_GEMM_fmap_staggered_delay.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_GEMM_fmap_staggered_delay.sv` | no | reusable testbench |
| `hw/tb/tb_GEMM_weight_dispatcher.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_GEMM_weight_dispatcher.sv` | no | reusable testbench |
| `hw/tb/tb_barrel_shifter_BF16.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_barrel_shifter_BF16.sv` | no | reusable common-utility testbench kept with LLM suite initially |
| `hw/tb/tb_ctrl_npu_decoder.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_ctrl_npu_decoder.sv` | no | reusable decoder testbench |
| `hw/tb/tb_mat_result_normalizer.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_mat_result_normalizer.sv` | no | reusable testbench |
| `hw/tb/tb_mem_dispatcher_shape_lookup.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_mem_dispatcher_shape_lookup.sv` | no | reusable memory dispatcher testbench |
| `hw/tb/tb_mem_u_operation_queue.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_mem_u_operation_queue.sv` | no | reusable memory queue testbench |
| `hw/tb/tb_shape_const_ram.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_shape_const_ram.sv` | no | reusable RAM testbench |
| `hw/tb/tb_v002_runtime_smoke_program.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `LLM/tb/tb_v002_runtime_smoke_program.sv` | no | reusable ISA/runtime smoke testbench |

## ipcore-common

| source path | source SHA | proposed dest | rename? | notes |
| --- | --- | --- | --- | --- |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/GLOBAL_CONST.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/legacy/GLOBAL_CONST.svh` | no | legacy include aggregator; update board-specific include before copy |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/NUMBERS.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/NUMBERS.svh` | no | reusable numeric constants |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/npu_arch.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/npu_arch.svh` | no | reusable architecture constants; remove board-specific comment |
| `hw/rtl/Constants/compilePriority_Order/B_device_pkg/device_pkg.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/device_pkg.sv` | no | reusable data-width and pipeline policy |
| `hw/rtl/Constants/compilePriority_Order/C_type_pkg/dtype_pkg.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/dtype_pkg.sv` | no | reusable dtype package |
| `hw/rtl/Constants/compilePriority_Order/C_type_pkg/mem_pkg.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/mem_pkg.sv` | no | update device include before copy |
| `hw/rtl/Constants/compilePriority_Order/D_pipeline_pkg/vec_core_pkg.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/vec_core_pkg.sv` | no | remove board/model-specific comment before copy |
| `hw/rtl/Constants/compilePriority_Order/E_obs_pkg/perf_counter_pkg.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/perf_counter_pkg.sv` | no | reusable counter vocabulary |
| `hw/rtl/Library/Algorithms/Algorithms.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/Algorithms.sv` | no | reusable algorithm package |
| `hw/rtl/Library/Algorithms/BF16_math.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/packages/BF16_math.sv` | no | reusable BF16 math package |
| `hw/rtl/Library/Algorithms/QUEUE/IF_queue.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/interfaces/IF_queue.sv` | no | reusable queue interface |
| `hw/rtl/Library/Algorithms/QUEUE/QUEUE.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/wrappers/QUEUE.sv` | no | reusable queue module |
| `hw/rtl/NPU_Controller/npu_interfaces.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/interfaces/npu_interfaces.svh` | no | reusable AXI interface definitions |
| `hw/rtl/barrel_shifter_BF16.sv` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `common/rtl/wrappers/barrel_shifter_BF16.sv` | no | reusable BF16 utility |

## unclear

| source path | source SHA | best-guess category | reason | proposed action |
| --- | --- | --- | --- | --- |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/kv260_device.svh` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `ipcore-common` | It contains physical device constants needed by reusable packages, but the file name and comments are board-specific. | Decide whether Phase C should generalize it as `common/rtl/packages/device_profile.svh` or leave the board profile in the source repo and parameterize the IP core. |
| `hw/vivado/filelist.f` | `18d4631f54721684ef6747bc37cf8538653a7a9e` | `ipcore-LLM` | It is the useful compile-order list, but it lives under Vivado project ownership and currently includes the BD packaging shim. | Decide whether Phase C should copy a package-owned `LLM/scripts/filelist.f` with the BD shim removed. |

## Files that hardcode KV260 / Gemma3N inside otherwise-reusable RTL

Decision needed before Phase C can copy them.

| source path | category | issue | proposed action |
| --- | --- | --- | --- |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/GLOBAL_CONST.svh` | `ipcore-common` | Includes the board-named device header. | Replace include after the device-profile decision. |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/kv260_device.svh` | `unclear` | Board name in file path, guard, comments, and constants. | Generalize or keep as source-repo board profile. |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/npu_arch.svh` | `ipcore-common` | Comment references board-specific values. | Keep constants; remove board reference. |
| `hw/rtl/Constants/compilePriority_Order/C_type_pkg/mem_pkg.sv` | `ipcore-common` | Includes the board-named device header. | Update include after the device-profile decision. |
| `hw/rtl/Constants/compilePriority_Order/D_pipeline_pkg/vec_core_pkg.sv` | `ipcore-common` | Default-configuration comment names a board and model target. | Keep values as TBD-derived package defaults; remove target names. |
| `hw/rtl/MAT_CORE/GEMM_systolic_top.sv` | `ipcore-LLM` | Header comment names the board target. | Keep RTL; remove target comment. |
| `hw/rtl/MEM_control/memory/mem_BUFFER.sv` | `ipcore-LLM` | Header comment references board SoC section. | Keep RTL; make comment architecture-only. |
| `hw/rtl/MEM_control/top/mem_HP_buffer.sv` | `ipcore-LLM` | Header comment references board SoC section. | Keep RTL; make comment architecture-only. |
| `hw/rtl/NPU_top.sv` | `ipcore-LLM` | Header comments name the board target and contain a non-source doc reference. | Rename on copy and make header architecture-only. |
| `hw/rtl/PREPROCESS/fmap_cache.sv` | `ipcore-LLM` | Header comment names the target model. | Keep RTL; make comment model-agnostic. |
| `formal/sail/src/pccx_regs.sail` | `ipcore-LLM` | Reusable formal source has a model-specific sizing comment. | Keep semantics; remove target-model example. |

## Non-trivial rename proposals

| source path | proposed dest | reason |
| --- | --- | --- |
| `hw/rtl/NPU_top.sv` | `LLM/rtl/top/pccx_npu_top.sv` | Package-owned top should not inherit board-integration naming context. |
| `hw/rtl/Constants/compilePriority_Order/A_const_svh/kv260_device.svh` | `common/rtl/packages/device_profile.svh` | Board token cannot remain under `common/rtl/` if this file is copied. |
| `hw/vivado/filelist.f` | `LLM/scripts/filelist.f` | Compile-order list should be package-owned and should exclude the BD packaging shim if copied. |

## board-kv260, app-llm, evidence

Listed for completeness; these remain in `pccx-FPGA-NPU-LLM-kv260`.

| source path | category | notes |
| --- | --- | --- |
| `hw/constraints/pccx_timing.xdc` | `board-kv260` | board timing constraints |
| `hw/vivado/README.md` | `board-kv260` | board Vivado flow docs |
| `hw/vivado/build.sh` | `board-kv260` | board Vivado launcher |
| `hw/vivado/create_project.tcl` | `board-kv260` | board Vivado project creation |
| `hw/vivado/impl.tcl` | `board-kv260` | board implementation flow |
| `hw/vivado/npu_core_wrapper.sv` | `board-kv260` | BD packaging shim for Zynq/Vivado integration |
| `hw/vivado/synth.tcl` | `board-kv260` | board synthesis flow |
| `scripts/kv260/run_gemma3n_e4b_smoke.sh` | `board-kv260` | board smoke-run handoff script |
| `configs/v002/gemma3n_e4b_manifest.example.json` | `app-llm` | target model and board manifest example |
| `docs/GEMMA3N_HANDOFF.md` | `app-llm` | target model handoff boundary |
| `docs/README.md` | `app-llm` | source repo docs index |
| `docs/index.html` | `app-llm` | source repo docs landing page |
| `sw/driver/uCA_v1_api.c` | `app-llm` | runtime driver source |
| `sw/driver/uCA_v1_api.h` | `app-llm` | runtime driver API header |
| `sw/driver/uCA_v1_hal.c` | `app-llm` | board-tied HAL source |
| `sw/driver/uCA_v1_hal.h` | `app-llm` | board-tied HAL header |
| `tools/v002/generate_smoke_program.py` | `app-llm` | runtime smoke-program tool |
| `docs/KV260_BRINGUP.md` | `evidence` | board bring-up evidence checklist |
| `docs/RELEASE_EVIDENCE_CHECKLIST.md` | `evidence` | release evidence checklist |
| `docs/SIMULATION.md` | `evidence` | xsim evidence workflow |
| `docs/TIMING_EVIDENCE.md` | `evidence` | timing evidence checklist |
| `docs/W4A8_GOLDEN_VECTOR_GATE.md` | `evidence` | golden-vector evidence gate |
| `docs/evidence/kv260-gemma3n-e4b/20260502T054224Z-5c69049cf7ba/blocker.txt` | `evidence` | board-run blocker record |
| `docs/evidence/kv260-gemma3n-e4b/20260502T054224Z-5c69049cf7ba/summary.txt` | `evidence` | board-run summary record |
| `docs/evidence/kv260-gemma3n-e4b/20260502T142200Z-b1b0dee-blocked-board/blocker.txt` | `evidence` | board-run blocker record |
| `docs/evidence/kv260-gemma3n-e4b/20260502T142200Z-b1b0dee-blocked-board/summary.txt` | `evidence` | board-run summary record |
| `docs/evidence/kv260-gemma3n-e4b/MANIFEST_TEMPLATE.md` | `evidence` | external manifest evidence template |
| `evidence/v002/FINAL_CANDIDATE_SUMMARY.md` | `evidence` | candidate evidence summary |
| `scripts/v002/artifact-safety-check.sh` | `evidence` | candidate artifact guard |
| `scripts/v002/claim-scan.sh` | `evidence` | claim scanner |
| `scripts/v002/run-local-candidate.sh` | `evidence` | local candidate evidence runner |
| `scripts/v002/run-throughput-report.sh` | `evidence` | throughput evidence report wrapper |
| `scripts/v002/run-timing-evidence.sh` | `evidence` | timing evidence runner |
| `tools/v002/estimate_tokens_per_second.py` | `evidence` | evidence parser/report helper |

## out-of-scope

| source path | reason |
| --- | --- |
| `docs/internal/counter_mvp_notes.md` | internal planning note; not an IP-core source contract |
| `docs/internal/dead_module_inventory.md` | internal historical inventory; not an IP-core source contract |
| `docs/internal/global_const_migration_plan.md` | internal migration note; useful background only |
| `docs/internal/kv260_gemma3n_e4b_hardware_handoff.md` | source-repo handoff note; remains outside pccx-v002 |
| `docs/internal/rtl_interface_readability_plan.md` | internal planning note; not part of the package skeleton |
| `docs/internal/stage_c_completion_notes.md` | internal historical completion note |
| `docs/internal/sva_assertion_candidates.md` | internal assertion planning note; not copied in Phase C |
| `docs/releases/v0.1.0-alpha.md` | source-repo release note; remains with the integration repo |
