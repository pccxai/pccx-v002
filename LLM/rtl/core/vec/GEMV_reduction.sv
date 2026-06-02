// PCCX(TM) — reusable AI accelerator project.
// SPDX-FileCopyrightText: 2026 Hyun Woo Kim
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps

`include "GEMV_Vec_Matrix_MUL.svh"
`include "GLOBAL_CONST.svh"

// ===| Module: GEMV_reduction — 32 → 1 LUT-indexed signed adder tree |==========
// Purpose      : For one lane and one cycle, look up
//                  fmap_LUT[lane][weight[lane]]  (32 lookups)
//                and sum them with a 5-stage adder tree to produce one
//                per-lane partial sum.
// Spec ref     : pccx v002 §2.3.3 (reduction tree).
// Clock        : clk @ 400 MHz.
// Reset        : rst_n active-low.
// Topology     : Five registered signed adder stages: 32 → 16 → 8 → 4 → 2 → 1.
// Latency      : REDUCTION_LATENCY = 6 cycles (LUT capture + five reduction
//                stages).
// Throughput   : 1 reduction per cycle in steady state.
// Handshake    : Push-only; IN_valid is OR'd with IN_is_lane_active to
//                gate the pipeline.
// Reset state  : valid_pipe = 0; OUT_reduction_result = 0.
// Counters     : none.
// Protected    : Arithmetic internals remain unchanged in this extraction.
// ===============================================================================
module GEMV_reduction
  import vec_core_pkg::*;
#(
    parameter gemv_cfg_t param = VecCoreDefaultCfg,
    parameter int REDUCTION_LATENCY = 6
) (
    input logic clk,
    input logic rst_n,
    input logic IN_is_lane_active,
    input logic IN_valid,
    input logic signed [param.fixed_mant_width+2:0] IN_fmap_LUT[0:param.fmap_cache_out_cnt-1][0:(1<<param.weight_width)-1],
    input logic [param.weight_width - 1:0] IN_weight[0:param.weight_cnt -1],

    output logic [param.fixed_mant_width+2:0] OUT_reduction_result,
    output logic OUT_reduction_res_valid
);
  // ===| pipeline Valid sync REG |===
  // REDUCTION_LATENCY shift register. The first cycle captures the LUT-indexed
  // lane values before the five-stage reduction tree can consume them.
  logic [REDUCTION_LATENCY-1:0] valid_pipe;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid_pipe <= '0;
    end else begin
      // Push the valid status into the LSB and shift every cycle
      //(Active only when IN_valid and IN_is_lane_active are both 1).
      valid_pipe <= {valid_pipe[REDUCTION_LATENCY-2:0], (IN_valid & IN_is_lane_active)};
    end
  end

  assign OUT_reduction_res_valid = valid_pipe[REDUCTION_LATENCY-1];

  //2^5
  logic signed [param.fixed_mant_width+2:0] reduction_32_fmap_wire[0:31];
  //2^4
  logic signed [param.fixed_mant_width+2:0] reduction_16_fmap_wire[0:15];
  //2^3
  logic signed [param.fixed_mant_width+2:0] reduction_8_fmap_wire [ 0:7];
  //2^2
  logic signed [param.fixed_mant_width+2:0] reduction_4_fmap_wire [ 0:3];
  //2^1
  logic signed [param.fixed_mant_width+2:0] reduction_2_fmap_wire [ 0:1];

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int lane = 0; lane < param.fmap_cache_out_cnt; lane++) begin
        //stage1_emax_q1[i] <= 0
      end
    end else begin
      if (IN_valid & IN_is_lane_active) begin
        for (int lane = 0; lane < param.fmap_cache_out_cnt; lane++) begin
          reduction_32_fmap_wire[lane] <= IN_fmap_LUT[lane][IN_weight[lane]];
        end
      end
    end
  end

  // ===| Stage 1: Reduction 32 -> 16 |==========================================
  // Latency: 1 Clock Cycle
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < 16; i++) begin
        reduction_16_fmap_wire[i] <= '0;
      end
    end else begin
      for (int i = 0; i < 16; i++) begin
        reduction_16_fmap_wire[i] <= reduction_32_fmap_wire[2*i] + reduction_32_fmap_wire[2*i+1];
      end
    end
  end

  // ===| REDUCTION TREE: LUT-based Pipelined Adders (Optimized for 400MHz) |====
  // UltraScale+ CARRY8 primitives combined with immediate FDRE (Registers)
  // provide better routing and timing than forcing DSPs for simple additions.
  // ============================================================================

  // ===| Stage 2: Reduction 16 -> 8 |===========================================
  // Latency: 1 Clock Cycle
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < 8; i++) begin
        reduction_8_fmap_wire[i] <= '0;
      end
    end else begin
      for (int i = 0; i < 8; i++) begin
        // Simple addition. Vivado will infer CARRY8 + FF in the same slice.
        reduction_8_fmap_wire[i] <= reduction_16_fmap_wire[2*i] + reduction_16_fmap_wire[2*i+1];
      end
    end
  end

  // ===| Stage 3: Reduction 8 -> 4 |============================================
  // Latency: 1 Clock Cycle
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < 4; i++) begin
        reduction_4_fmap_wire[i] <= '0;
      end
    end else begin
      for (int i = 0; i < 4; i++) begin
        reduction_4_fmap_wire[i] <= reduction_8_fmap_wire[2*i] + reduction_8_fmap_wire[2*i+1];
      end
    end
  end

  // ===| Stage 4: Reduction 4 -> 2 |============================================
  // Latency: 1 Clock Cycle
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < 2; i++) begin
        reduction_2_fmap_wire[i] <= '0;
      end
    end else begin
      for (int i = 0; i < 2; i++) begin
        reduction_2_fmap_wire[i] <= reduction_4_fmap_wire[2*i] + reduction_4_fmap_wire[2*i+1];
      end
    end
  end

  // ===| Stage 5: Reduction 2 -> 1 (Final Sum) |================================
  // Latency: 1 Clock Cycle
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      OUT_reduction_result <= '0;
    end else begin
      OUT_reduction_result <= reduction_2_fmap_wire[0] + reduction_2_fmap_wire[1];
    end
  end

  // ============================================================================
  // Total Pipeline Latency for Reduction Tree:
  // LUT capture              : 1 Cycle
  // Stage 1 (32->16)       : 1 Cycle
  // Stage 2 (LUT: 16->8)  : 1 Cycle
  // Stage 3 (LUT: 8->4)   : 1 Cycle
  // Stage 4 (LUT: 4->2)   : 1 Cycle
  // Stage 5 (LUT: 2->1)   : 1 Cycle
  // ----------------------------------------
  // Total latency after FMap/Weight input: 6 Cycles
  // ============================================================================

endmodule
