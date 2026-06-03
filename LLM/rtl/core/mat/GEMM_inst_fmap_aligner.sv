// PCCX(TM) - reusable AI accelerator project.
// SPDX-FileCopyrightText: 2026 Hyun Woo Kim
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps

// ===| Module: GEMM_inst_fmap_aligner |=========================================
// Align the scheduler-registered GEMM instruction flags with the first fmap
// broadcast cycle that reaches the systolic stagger line.
//
// Global_Scheduler registers OUT_GEMM_uop one clock after IN_GEMM_op_x64_valid.
// The fmap broadcast starts later, after preprocess_fmap receives and caches
// the L2 stream. Driving GEMM_op_x64_valid directly into GEMM_systolic_top can
// present stale flags and a valid pulse before fmap_valid is high.
// =============================================================================
module GEMM_inst_fmap_aligner (
    input logic clk,
    input logic rst_n,
    input logic i_clear,

    input logic       i_gemm_op_valid,
    input logic [2:0] i_gemm_inst_registered,
    input logic       i_fmap_valid,

    output logic [2:0] o_global_inst,
    output logic       o_global_inst_valid
);

  logic       capture_pending;
  logic       inst_pending;
  logic [2:0] inst_latched;
  logic       fmap_valid_d;
  logic       fmap_start;

  assign fmap_start          = i_fmap_valid & ~fmap_valid_d;
  assign o_global_inst       = inst_latched;
  assign o_global_inst_valid = inst_pending & fmap_start;

  always_ff @(posedge clk) begin
    if (!rst_n || i_clear) begin
      capture_pending <= 1'b0;
      inst_pending    <= 1'b0;
      inst_latched    <= 3'b000;
      fmap_valid_d    <= 1'b0;
    end else begin
      fmap_valid_d <= i_fmap_valid;

      if (i_gemm_op_valid) begin
        capture_pending <= 1'b1;
      end else if (capture_pending) begin
        capture_pending <= 1'b0;
      end

      if (capture_pending) begin
        inst_latched <= i_gemm_inst_registered;
        inst_pending <= 1'b1;
      end else if (inst_pending && fmap_start) begin
        inst_pending <= 1'b0;
      end
    end
  end

endmodule
