# Source manifest

| source repo | source SHA | source path | dest path | rename reason |
| --- | --- | --- | --- | --- |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/A_const_svh/GLOBAL_CONST.svh | common/rtl/packages/legacy/GLOBAL_CONST.svh | include updated for device profile rename |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/A_const_svh/NUMBERS.svh | common/rtl/packages/NUMBERS.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/A_const_svh/npu_arch.svh | common/rtl/packages/npu_arch.svh | board reference removed from copied comment |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/B_device_pkg/device_pkg.sv | common/rtl/packages/device_pkg.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/C_type_pkg/dtype_pkg.sv | common/rtl/packages/dtype_pkg.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/C_type_pkg/mem_pkg.sv | common/rtl/packages/mem_pkg.sv | include updated for device profile rename |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/D_pipeline_pkg/vec_core_pkg.sv | common/rtl/packages/vec_core_pkg.sv | target-specific comment removed |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/E_obs_pkg/perf_counter_pkg.sv | common/rtl/packages/perf_counter_pkg.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Library/Algorithms/Algorithms.sv | common/rtl/packages/Algorithms.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Library/Algorithms/BF16_math.sv | common/rtl/packages/BF16_math.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Library/Algorithms/QUEUE/IF_queue.sv | common/rtl/interfaces/IF_queue.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Library/Algorithms/QUEUE/QUEUE.sv | common/rtl/wrappers/QUEUE.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/npu_interfaces.svh | common/rtl/interfaces/npu_interfaces.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/barrel_shifter_BF16.sv | common/rtl/wrappers/barrel_shifter_BF16.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/Constants/compilePriority_Order/A_const_svh/kv260_device.svh | common/rtl/packages/device_profile.svh | board-named device profile generalized |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/CVO_CORE/CVO_cordic_unit.sv | LLM/rtl/core/cvo/CVO_cordic_unit.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/CVO_CORE/CVO_sfu_unit.sv | LLM/rtl/core/cvo/CVO_sfu_unit.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/CVO_CORE/CVO_top.sv | LLM/rtl/core/cvo/CVO_top.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/FROM_mat_result_packer.sv | LLM/rtl/core/mat/FROM_mat_result_packer.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_Array.svh | LLM/rtl/core/mat/GEMM_Array.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_accumulator.sv | LLM/rtl/core/mat/GEMM_accumulator.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_dsp_packer.sv | LLM/rtl/core/mat/GEMM_dsp_packer.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_dsp_unit.sv | LLM/rtl/core/mat/GEMM_dsp_unit.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_dsp_unit_last_ROW.sv | LLM/rtl/core/mat/GEMM_dsp_unit_last_ROW.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_fmap_staggered_delay.sv | LLM/rtl/core/mat/GEMM_fmap_staggered_delay.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_sign_recovery.sv | LLM/rtl/core/mat/GEMM_sign_recovery.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_systolic_array.sv | LLM/rtl/core/mat/GEMM_systolic_array.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_systolic_top.sv | LLM/rtl/core/mat/GEMM_systolic_top.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/GEMM_weight_dispatcher.sv | LLM/rtl/core/mat/GEMM_weight_dispatcher.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MAT_CORE/mat_result_normalizer.sv | LLM/rtl/core/mat/mat_result_normalizer.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/IO/mem_IO.svh | LLM/rtl/interfaces/mem_IO.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/IO/mem_u_operation_queue.sv | LLM/rtl/core/memory/mem_u_operation_queue.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/memory/Constant_Memory/shape_const_ram.sv | LLM/rtl/core/memory/Constant_Memory/shape_const_ram.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/memory/mem_BUFFER.sv | LLM/rtl/core/memory/mem_BUFFER.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/memory/mem_GLOBAL_cache.sv | LLM/rtl/core/memory/mem_GLOBAL_cache.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/top/mem_CVO_stream_bridge.sv | LLM/rtl/core/memory/mem_CVO_stream_bridge.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/top/mem_HP_buffer.sv | LLM/rtl/core/memory/mem_HP_buffer.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/top/mem_L2_cache_fmap.sv | LLM/rtl/core/memory/mem_L2_cache_fmap.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/MEM_control/top/mem_dispatcher.sv | LLM/rtl/core/memory/mem_dispatcher.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/Global_Scheduler.sv | LLM/rtl/core/controller/Global_Scheduler.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_memctrl.svh | LLM/rtl/packages/isa/isa_memctrl.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_pkg.sv | LLM/rtl/packages/isa/isa_pkg.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_x32.svh | LLM/rtl/packages/isa/isa_x32.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_Control_Unit/ISA_PACKAGE/isa_x64.svh | LLM/rtl/packages/isa/isa_x64.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_Control_Unit/ctrl_decode_const.svh | LLM/rtl/packages/controller/ctrl_decode_const.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_Control_Unit/ctrl_npu_decoder.sv | LLM/rtl/core/controller/ctrl_npu_decoder.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_frontend/AXIL_CMD_IN.sv | LLM/rtl/core/controller/AXIL_CMD_IN.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_frontend/AXIL_STAT_OUT.sv | LLM/rtl/core/controller/AXIL_STAT_OUT.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/NPU_frontend/ctrl_npu_frontend.sv | LLM/rtl/core/controller/ctrl_npu_frontend.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_Controller/npu_controller_top.sv | LLM/rtl/core/controller/npu_controller_top.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/NPU_top.sv | LLM/rtl/top/pccx_npu_top.sv | package top rename |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/PREPROCESS/fmap_cache.sv | LLM/rtl/core/preprocess/fmap_cache.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/PREPROCESS/preprocess_bf16_fixed_pipeline.sv | LLM/rtl/core/preprocess/preprocess_bf16_fixed_pipeline.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/PREPROCESS/preprocess_fmap.sv | LLM/rtl/core/preprocess/preprocess_fmap.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/VEC_CORE/GEMV_Vec_Matrix_MUL.svh | LLM/rtl/core/vec/GEMV_Vec_Matrix_MUL.svh | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/VEC_CORE/GEMV_accumulate.sv | LLM/rtl/core/vec/GEMV_accumulate.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/VEC_CORE/GEMV_generate_lut.sv | LLM/rtl/core/vec/GEMV_generate_lut.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/VEC_CORE/GEMV_reduction.sv | LLM/rtl/core/vec/GEMV_reduction.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/VEC_CORE/GEMV_reduction_branch.sv | LLM/rtl/core/vec/GEMV_reduction_branch.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/rtl/VEC_CORE/GEMV_top.sv | LLM/rtl/core/vec/GEMV_top.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/sim/run_verification.sh | LLM/sim/run_verification.sh | simulation paths updated for package layout |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_FROM_mat_result_packer.sv | LLM/tb/tb_FROM_mat_result_packer.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_GEMM_dsp_packer_sign_recovery.sv | LLM/tb/tb_GEMM_dsp_packer_sign_recovery.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_GEMM_fmap_staggered_delay.sv | LLM/tb/tb_GEMM_fmap_staggered_delay.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_GEMM_weight_dispatcher.sv | LLM/tb/tb_GEMM_weight_dispatcher.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_barrel_shifter_BF16.sv | LLM/tb/tb_barrel_shifter_BF16.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_ctrl_npu_decoder.sv | LLM/tb/tb_ctrl_npu_decoder.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_mat_result_normalizer.sv | LLM/tb/tb_mat_result_normalizer.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_mem_dispatcher_shape_lookup.sv | LLM/tb/tb_mem_dispatcher_shape_lookup.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_mem_u_operation_queue.sv | LLM/tb/tb_mem_u_operation_queue.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_shape_const_ram.sv | LLM/tb/tb_shape_const_ram.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/tb/tb_v002_runtime_smoke_program.sv | LLM/tb/tb_v002_runtime_smoke_program.sv | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/Makefile | LLM/formal/sail/Makefile | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/README.md | LLM/formal/sail/README.md | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/pccx.sail_project | LLM/formal/sail/pccx.sail_project | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/src/pccx_decode.sail | LLM/formal/sail/src/pccx_decode.sail | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/src/pccx_execute.sail | LLM/formal/sail/src/pccx_execute.sail | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/src/pccx_regs.sail | LLM/formal/sail/src/pccx_regs.sail | target-model example removed from copied comment |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/src/pccx_types.sail | LLM/formal/sail/src/pccx_types.sail | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/src/prelude.sail | LLM/formal/sail/src/prelude.sail | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | formal/sail/tests/smoke_decode.sail | LLM/formal/sail/tests/smoke_decode.sail | none |
| pccx-FPGA-NPU-LLM-kv260 | 18d4631f54721684ef6747bc37cf8538653a7a9e | hw/vivado/filelist.f | LLM/scripts/filelist.f | package compile list path with BD shim removed |
