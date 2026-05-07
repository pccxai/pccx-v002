# pccx v002 LLM package compile filelist
#
# Ordering matters: packages and interfaces before modules that import them.
# Invoke from the package root with:
#   xvlog -sv -f LLM/scripts/filelist.f
#
# Tool flows should add these include directories before compiling:
#   common/rtl/packages/legacy
#   common/rtl/packages
#   common/rtl/interfaces
#   LLM/rtl/packages/isa
#   LLM/rtl/packages/controller
#   LLM/rtl/core/mat
#   LLM/rtl/core/vec
#   LLM/rtl/interfaces

# ===| Header references (included via include directories) |=================
# common/rtl/packages/NUMBERS.svh
# common/rtl/packages/device_profile.svh
# common/rtl/packages/npu_arch.svh
# common/rtl/packages/legacy/GLOBAL_CONST.svh
# common/rtl/interfaces/npu_interfaces.svh
# LLM/rtl/core/mat/GEMM_Array.svh
# LLM/rtl/core/vec/GEMV_Vec_Matrix_MUL.svh
# LLM/rtl/interfaces/mem_IO.svh

# ===| Common packages and interfaces |=======================================
common/rtl/packages/device_pkg.sv
common/rtl/packages/dtype_pkg.sv
common/rtl/packages/mem_pkg.sv
common/rtl/packages/vec_core_pkg.sv
common/rtl/packages/perf_counter_pkg.sv
common/rtl/packages/BF16_math.sv
common/rtl/packages/Algorithms.sv
common/rtl/interfaces/IF_queue.sv

# ===| ISA package |===========================================================
LLM/rtl/packages/isa/isa_pkg.sv

# ===| Constant memory |=======================================================
LLM/rtl/core/memory/Constant_Memory/shape_const_ram.sv

# ===| MAT core |==============================================================
LLM/rtl/core/mat/GEMM_dsp_packer.sv
LLM/rtl/core/mat/GEMM_sign_recovery.sv
LLM/rtl/core/mat/GEMM_dsp_unit.sv
LLM/rtl/core/mat/GEMM_dsp_unit_last_ROW.sv
LLM/rtl/core/mat/GEMM_accumulator.sv
LLM/rtl/core/mat/GEMM_fmap_staggered_delay.sv
LLM/rtl/core/mat/GEMM_weight_dispatcher.sv
LLM/rtl/core/mat/GEMM_systolic_array.sv
LLM/rtl/core/mat/GEMM_systolic_top.sv
LLM/rtl/core/mat/FROM_mat_result_packer.sv
LLM/rtl/core/mat/mat_result_normalizer.sv

# ===| VEC core |==============================================================
LLM/rtl/core/vec/GEMV_accumulate.sv
LLM/rtl/core/vec/GEMV_generate_lut.sv
LLM/rtl/core/vec/GEMV_reduction.sv
LLM/rtl/core/vec/GEMV_reduction_branch.sv
LLM/rtl/core/vec/GEMV_top.sv

# ===| CVO core |==============================================================
LLM/rtl/core/cvo/CVO_cordic_unit.sv
LLM/rtl/core/cvo/CVO_sfu_unit.sv
LLM/rtl/core/cvo/CVO_top.sv

# ===| Preprocess |============================================================
LLM/rtl/core/preprocess/preprocess_bf16_fixed_pipeline.sv
LLM/rtl/core/preprocess/fmap_cache.sv
LLM/rtl/core/preprocess/preprocess_fmap.sv

# ===| Memory control |========================================================
LLM/rtl/core/memory/mem_BUFFER.sv
LLM/rtl/core/memory/mem_GLOBAL_cache.sv
LLM/rtl/core/memory/mem_u_operation_queue.sv
LLM/rtl/core/memory/mem_HP_buffer.sv
LLM/rtl/core/memory/mem_CVO_stream_bridge.sv
LLM/rtl/core/memory/mem_L2_cache_fmap.sv
LLM/rtl/core/memory/mem_dispatcher.sv

# ===| Controller |============================================================
LLM/rtl/core/controller/ctrl_npu_decoder.sv
LLM/rtl/core/controller/AXIL_CMD_IN.sv
LLM/rtl/core/controller/AXIL_STAT_OUT.sv
LLM/rtl/core/controller/ctrl_npu_frontend.sv
LLM/rtl/core/controller/Global_Scheduler.sv
LLM/rtl/core/controller/npu_controller_top.sv

# ===| Common wrappers |=======================================================
common/rtl/wrappers/QUEUE.sv
common/rtl/wrappers/barrel_shifter_BF16.sv

# ===| Top level |=============================================================
LLM/rtl/top/pccx_npu_top.sv
