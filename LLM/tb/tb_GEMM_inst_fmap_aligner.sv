// PCCX(TM) - reusable AI accelerator project.
// SPDX-FileCopyrightText: 2026 Hyun Woo Kim
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps

// Checks the Stage 1 GEMM instruction timing contract:
//   - GEMM op-valid comes one cycle before scheduler-registered flags.
//   - The aligned instruction-valid waits until fmap_valid rises.
//   - The aligned instruction-valid pulses once per GEMM.
module tb_GEMM_inst_fmap_aligner;

  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic i_clear = 1'b0;

  logic       i_gemm_op_valid;
  logic [2:0] i_gemm_inst_registered;
  logic       i_fmap_valid;
  logic [2:0] o_global_inst;
  logic       o_global_inst_valid;

  int pass_count = 0;
  int fail_count = 0;
  int pulse_count = 0;
  int expected_pulse_count = 0;
  logic [2:0] expected_inst[0:3];

  always #5 clk = ~clk;

  GEMM_inst_fmap_aligner dut (
      .clk                   (clk),
      .rst_n                 (rst_n),
      .i_clear               (i_clear),
      .i_gemm_op_valid       (i_gemm_op_valid),
      .i_gemm_inst_registered(i_gemm_inst_registered),
      .i_fmap_valid          (i_fmap_valid),
      .o_global_inst         (o_global_inst),
      .o_global_inst_valid   (o_global_inst_valid)
  );

  always @(posedge clk) begin
    if (o_global_inst_valid) begin
      if (!i_fmap_valid) begin
        $display("FAIL: output valid without fmap_valid");
        fail_count++;
      end else if (pulse_count >= expected_pulse_count) begin
        $display("FAIL: unexpected output pulse %0d inst=%0b", pulse_count, o_global_inst);
        fail_count++;
      end else if (o_global_inst !== expected_inst[pulse_count]) begin
        $display(
            "FAIL: pulse %0d inst mismatch got=%0b expected=%0b",
            pulse_count, o_global_inst, expected_inst[pulse_count]
        );
        fail_count++;
      end else begin
        $display("PASS: pulse %0d inst=%0b", pulse_count, o_global_inst);
        pass_count++;
      end
      pulse_count++;
    end
  end

  task automatic tick;
    @(negedge clk);
  endtask

  task automatic expect_idle(input int cycles, input string label);
    for (int i = 0; i < cycles; i++) begin
      @(posedge clk);
      if (o_global_inst_valid) begin
        $display("FAIL: %s saw unexpected valid at idle cycle %0d", label, i);
        fail_count++;
      end else begin
        pass_count++;
      end
    end
  endtask

  task automatic issue_gemm_then_fmap(
      input logic [2:0] old_inst,
      input logic [2:0] new_inst,
      input int gap_cycles
  );
    tick();
    i_gemm_inst_registered = old_inst;
    i_gemm_op_valid = 1'b1;

    tick();
    i_gemm_op_valid = 1'b0;
    i_gemm_inst_registered = new_inst;

    expect_idle(gap_cycles, "before fmap");

    expected_inst[expected_pulse_count] = new_inst;
    expected_pulse_count++;
    tick();
    i_fmap_valid = 1'b1;

    @(posedge clk);
    if (!o_global_inst_valid) begin
      $display("FAIL: missing aligned valid on fmap rise for inst=%0b", new_inst);
      fail_count++;
    end

    tick();
    i_fmap_valid = 1'b1;
    @(posedge clk);
    if (o_global_inst_valid) begin
      $display("FAIL: duplicate valid while fmap stayed high");
      fail_count++;
    end else begin
      pass_count++;
    end

    tick();
    i_fmap_valid = 1'b0;
  endtask

  initial begin
    $display("=== tb_GEMM_inst_fmap_aligner start ===");

    i_gemm_op_valid = 1'b0;
    i_gemm_inst_registered = 3'b000;
    i_fmap_valid = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    expect_idle(2, "after reset");

    issue_gemm_then_fmap(3'b000, 3'b101, 5);
    expect_idle(3, "between commands");

    issue_gemm_then_fmap(3'b101, 3'b001, 2);

    tick();
    i_clear = 1'b1;
    tick();
    i_clear = 1'b0;
    expect_idle(2, "after clear");

    if (pulse_count != expected_pulse_count) begin
      $display("FAIL: pulse_count=%0d expected=%0d", pulse_count, expected_pulse_count);
      fail_count++;
    end else begin
      pass_count++;
    end

    $display("");
    $display("=== Summary ===");
    $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
    $display("FAIL: %0d", fail_count);
    if (fail_count == 0)
      $display("OVERALL: PASS");
    else
      $display("OVERALL: FAIL");
    $finish;
  end

endmodule
