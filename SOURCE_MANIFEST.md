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
