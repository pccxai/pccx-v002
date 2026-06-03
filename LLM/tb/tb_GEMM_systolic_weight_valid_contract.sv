// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 pccxai
//
// tb_GEMM_systolic_weight_valid_contract
//
// Checks that GEMM_systolic_top drives the PE array weight latch from the
// registered dual-lane dispatcher valid, not directly from a single HP lane.

`timescale 1ns / 1ps
`include "GLOBAL_CONST.svh"
`include "GEMM_Array.svh"

module tb_GEMM_systolic_weight_valid_contract;

  localparam int WEIGHT_CNT = `HP_SINGLE_WIDTH / `INT4_WIDTH;
  localparam int ARRAY_H    = `ARRAY_SIZE_H;
  localparam int FMAP_W     = `FIXED_MANT_WIDTH;
  localparam int P_W        = `DSP48E2_POUT_SIZE;

  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic i_clear = 1'b0;

  logic global_weight_valid;
  logic [2:0] global_inst;
  logic global_inst_valid;

  logic [FMAP_W-1:0] IN_fmap_broadcast [0:ARRAY_H-1];
  logic IN_fmap_broadcast_valid;
  logic [`BF16_EXP_WIDTH-1:0] IN_cached_emax_out [0:ARRAY_H-1];

  logic [`INT4_WIDTH-1:0] IN_weight_upper [0:WEIGHT_CNT-1];
  logic IN_weight_upper_valid;
  logic IN_weight_upper_ready;
  logic [`INT4_WIDTH-1:0] IN_weight_lower [0:WEIGHT_CNT-1];
  logic IN_weight_lower_valid;
  logic IN_weight_lower_ready;

  logic [P_W-1:0] raw_res_sum [0:ARRAY_H-1];
  logic raw_res_sum_valid [0:ARRAY_H-1];
  logic [`BF16_EXP_WIDTH-1:0] delayed_emax_32 [0:ARRAY_H-1];

  int pass_count = 0;
  int fail_count = 0;

  always #5 clk = ~clk;

  GEMM_systolic_top dut (
      .clk(clk),
      .rst_n(rst_n),
      .i_clear(i_clear),
      .global_weight_valid(global_weight_valid),
      .global_inst(global_inst),
      .global_inst_valid(global_inst_valid),
      .IN_fmap_broadcast(IN_fmap_broadcast),
      .IN_fmap_broadcast_valid(IN_fmap_broadcast_valid),
      .IN_cached_emax_out(IN_cached_emax_out),
      .IN_weight_upper(IN_weight_upper),
      .IN_weight_upper_valid(IN_weight_upper_valid),
      .IN_weight_upper_ready(IN_weight_upper_ready),
      .IN_weight_lower(IN_weight_lower),
      .IN_weight_lower_valid(IN_weight_lower_valid),
      .IN_weight_lower_ready(IN_weight_lower_ready),
      .raw_res_sum(raw_res_sum),
      .raw_res_sum_valid(raw_res_sum_valid),
      .delayed_emax_32(delayed_emax_32)
  );

  task automatic set_weight_vectors(input logic [`INT4_WIDTH-1:0] upper0,
                                    input logic [`INT4_WIDTH-1:0] lower0);
    for (int i = 0; i < WEIGHT_CNT; i++) begin
      IN_weight_upper[i] = (upper0 + i) & 4'hf;
      IN_weight_lower[i] = (lower0 - i) & 4'hf;
    end
  endtask

  task automatic check_pe0_weights(input string label,
                                   input logic [`INT4_WIDTH-1:0] exp_upper,
                                   input logic [`INT4_WIDTH-1:0] exp_lower);
    logic [`INT4_WIDTH-1:0] got_upper;
    logic [`INT4_WIDTH-1:0] got_lower;
    got_upper = dut.u_compute_core.gemm_row_loop[0].gemm_col_loop[0].normal_row.dsp_unit.w_upper_reg;
    got_lower = dut.u_compute_core.gemm_row_loop[0].gemm_col_loop[0].normal_row.dsp_unit.w_lower_reg;
    if (got_upper === exp_upper && got_lower === exp_lower) begin
      $display("PASS [%s]: pe0 weights upper=%h lower=%h", label, got_upper, got_lower);
      pass_count++;
    end else begin
      $display("FAIL [%s]: pe0 upper got=%h exp=%h, lower got=%h exp=%h",
               label, got_upper, exp_upper, got_lower, exp_lower);
      fail_count++;
    end
  endtask

  initial begin
    $display("=== tb_GEMM_systolic_weight_valid_contract start ===");

    global_weight_valid = 1'b0;
    global_inst = 3'b000;
    global_inst_valid = 1'b0;
    IN_fmap_broadcast_valid = 1'b0;
    IN_weight_upper_valid = 1'b0;
    IN_weight_lower_valid = 1'b0;

    for (int i = 0; i < ARRAY_H; i++) begin
      IN_fmap_broadcast[i] = '0;
      IN_cached_emax_out[i] = '0;
    end
    set_weight_vectors(4'h0, 4'h0);

    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    repeat (10) @(posedge clk);
    #1;
    check_pe0_weights("reset_clears_weight_latch", 4'h0, 4'h0);

    // A single-lane HP0-valid pulse must not latch a PE weight, even if
    // global_weight_valid is high for the legacy HP0-valid shape.
    set_weight_vectors(4'ha, 4'h5);
    IN_weight_upper_valid = 1'b1;
    IN_weight_lower_valid = 1'b0;
    global_weight_valid = 1'b1;
    repeat (2) @(posedge clk);
    #1;
    IN_weight_upper_valid = 1'b0;
    global_weight_valid = 1'b0;
    @(posedge clk);
    #1;
    check_pe0_weights("upper_only_does_not_latch", 4'h0, 4'h0);

    if (IN_weight_upper_ready === 1'b0 && IN_weight_lower_ready === 1'b1) begin
      $display("PASS [initial_upper_pending_ready_contract]: upper_ready=0 lower_ready=1");
      pass_count++;
    end else begin
      $display("FAIL [initial_upper_pending_ready_contract]: upper_ready=%b lower_ready=%b",
               IN_weight_upper_ready, IN_weight_lower_ready);
      fail_count++;
    end

    IN_weight_lower_valid = 1'b1;
    @(posedge clk);
    #1;
    IN_weight_lower_valid = 1'b0;
    @(posedge clk);
    #1;
    check_pe0_weights("initial_upper_pending_pairs_with_later_lower", 4'ha, 4'h5);

    // One paired beat should be captured by the dispatcher and then latched by
    // the PE on the following cycle, even after the raw HP0 valid has dropped.
    set_weight_vectors(4'h3, 4'hc);
    IN_weight_upper_valid = 1'b1;
    IN_weight_lower_valid = 1'b1;
    global_weight_valid = 1'b1;
    @(posedge clk);
    #1;
    IN_weight_upper_valid = 1'b0;
    IN_weight_lower_valid = 1'b0;
    global_weight_valid = 1'b0;
    @(posedge clk);
    #1;
    check_pe0_weights("paired_one_beat_latches_after_registered_valid", 4'h3, 4'hc);

    // A later one-lane beat must not overwrite the paired weight already held
    // in the PE latch.
    set_weight_vectors(4'he, 4'h1);
    IN_weight_upper_valid = 1'b1;
    IN_weight_lower_valid = 1'b0;
    global_weight_valid = 1'b1;
    repeat (2) @(posedge clk);
    #1;
    IN_weight_upper_valid = 1'b0;
    global_weight_valid = 1'b0;
    @(posedge clk);
    #1;
    check_pe0_weights("upper_only_does_not_overwrite", 4'h3, 4'hc);

    if (IN_weight_upper_ready === 1'b0 && IN_weight_lower_ready === 1'b1) begin
      $display("PASS [upper_pending_ready_contract]: upper_ready=0 lower_ready=1");
      pass_count++;
    end else begin
      $display("FAIL [upper_pending_ready_contract]: upper_ready=%b lower_ready=%b",
               IN_weight_upper_ready, IN_weight_lower_ready);
      fail_count++;
    end

    IN_weight_lower_valid = 1'b1;
    @(posedge clk);
    #1;
    IN_weight_lower_valid = 1'b0;
    @(posedge clk);
    #1;
    check_pe0_weights("upper_pending_pairs_with_later_lower", 4'he, 4'h1);

    if (IN_weight_upper_ready === 1'b1 && IN_weight_lower_ready === 1'b1) begin
      $display("PASS [dispatcher_ready_contract]: upper_ready=1 lower_ready=1");
      pass_count++;
    end else begin
      $display("FAIL [dispatcher_ready_contract]: upper_ready=%b lower_ready=%b",
               IN_weight_upper_ready, IN_weight_lower_ready);
      fail_count++;
    end

    $display("");
    $display("=== Summary ===");
    $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
    $display("FAIL: %0d", fail_count);
    if (fail_count == 0) $display("OVERALL: PASS");
    else                 $display("OVERALL: FAIL");
    $finish;
  end

endmodule
