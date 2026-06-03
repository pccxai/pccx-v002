// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 pccxai
//
// tb_GEMM_dsp_unit_mac_ce_contract
//
// Checks the W4A8 DSP PE control contract used by the full Stage1 GEMM path:
// a latched MAC instruction must not keep the DSP P register advancing when
// the activation-valid wave is low. Otherwise a one-shot GEMM instruction can
// repeatedly accumulate the last held multiplier value after fmap valid drops.

`timescale 1ns / 1ps
`include "GLOBAL_CONST.svh"
`include "GEMM_Array.svh"

module tb_GEMM_dsp_unit_mac_ce_contract;

  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic i_clear = 1'b0;

  logic i_valid = 1'b0;
  logic i_weight_valid = 1'b0;
  logic o_valid;
  logic last_o_valid;

  logic [`INT4_WIDTH-1:0] in_H_upper = 4'h1;
  logic [`INT4_WIDTH-1:0] out_H_upper;
  logic [`INT4_WIDTH-1:0] last_out_H_upper;
  logic [`INT4_WIDTH-1:0] in_H_lower = 4'h1;
  logic [`INT4_WIDTH-1:0] out_H_lower;
  logic [`INT4_WIDTH-1:0] last_out_H_lower;

  logic [7:0] in_V = 8'h01;
  logic [`DEVICE_DSP_B_WIDTH-1:0] BCIN_in = '0;
  logic [`DEVICE_DSP_B_WIDTH-1:0] BCOUT_out;
  logic [`DEVICE_DSP_B_WIDTH-1:0] last_BCOUT_out;

  logic [2:0] instruction_in_V = 3'b000;
  logic [2:0] instruction_out_V;
  logic [2:0] last_instruction_out_V;
  logic inst_valid_in_V = 1'b0;
  logic inst_valid_out_V;
  logic last_inst_valid_out_V;

  logic [`DSP48E2_POUT_SIZE-1:0] V_result_in = '0;
  logic [`DSP48E2_POUT_SIZE-1:0] V_result_out;
  logic [`DSP48E2_POUT_SIZE-1:0] P_fabric_out;
  logic [`DSP48E2_POUT_SIZE-1:0] last_V_result_out;
  logic [`DSP48E2_POUT_SIZE-1:0] last_gemm_unit_results;

  int pass_count = 0;
  int fail_count = 0;

  always #5 clk = ~clk;

  GEMM_dsp_unit #(
      .IS_TOP_ROW(1),
      .BREAK_CASCADE(0)
  ) dut_mid (
      .clk(clk),
      .rst_n(rst_n),
      .i_clear(i_clear),
      .i_valid(i_valid),
      .i_weight_valid(i_weight_valid),
      .o_valid(o_valid),
      .in_H_upper(in_H_upper),
      .out_H_upper(out_H_upper),
      .in_H_lower(in_H_lower),
      .out_H_lower(out_H_lower),
      .in_V(in_V),
      .BCIN_in(BCIN_in),
      .BCOUT_out(BCOUT_out),
      .instruction_in_V(instruction_in_V),
      .instruction_out_V(instruction_out_V),
      .inst_valid_in_V(inst_valid_in_V),
      .inst_valid_out_V(inst_valid_out_V),
      .V_result_in(V_result_in),
      .V_result_out(V_result_out),
      .P_fabric_out(P_fabric_out)
  );

  GEMM_dsp_unit_last_ROW #(
      .IS_TOP_ROW(1)
  ) dut_last (
      .clk(clk),
      .rst_n(rst_n),
      .i_clear(i_clear),
      .i_valid(i_valid),
      .i_weight_valid(i_weight_valid),
      .inst_valid_in_V(inst_valid_in_V),
      .o_valid(last_o_valid),
      .in_H_upper(in_H_upper),
      .out_H_upper(last_out_H_upper),
      .in_H_lower(in_H_lower),
      .out_H_lower(last_out_H_lower),
      .in_V(in_V),
      .BCIN_in(BCIN_in),
      .BCOUT_out(last_BCOUT_out),
      .instruction_in_V(instruction_in_V),
      .instruction_out_V(last_instruction_out_V),
      .inst_valid_out_V(last_inst_valid_out_V),
      .V_result_in(V_result_in),
      .V_result_out(last_V_result_out),
      .gemm_unit_results(last_gemm_unit_results)
  );

  task automatic tick;
    begin
      @(posedge clk);
      #1;
    end
  endtask

  task automatic check(input string label, input bit ok);
    begin
      if (ok) begin
        $display("PASS [%s]", label);
        pass_count++;
      end else begin
        $display("FAIL [%s]", label);
        fail_count++;
      end
    end
  endtask

  initial begin
    $display("=== tb_GEMM_dsp_unit_mac_ce_contract start ===");

    repeat (6) tick();
    rst_n = 1'b1;
    repeat (3) tick();

    check("reset_mid_ce_low", dut_mid.dsp_ce_p === 1'b0);
    check("reset_last_ce_low", dut_last.dsp_ce_p === 1'b0);

    instruction_in_V = 3'b001;
    inst_valid_in_V = 1'b1;
    i_valid = 1'b0;
    tick();
    inst_valid_in_V = 1'b0;
    #1;

    check("mac_inst_latches_mid", dut_mid.current_inst === 3'b001);
    check("mac_inst_latches_last", dut_last.current_inst === 3'b001);
    check("mac_inst_without_valid_mid_ce_low", dut_mid.dsp_ce_p === 1'b0);
    check("mac_inst_without_valid_last_ce_low", dut_last.dsp_ce_p === 1'b0);

    i_valid = 1'b1;
    tick();
    check("valid_mac_mid_ce_high", dut_mid.dsp_ce_p === 1'b1);
    check("valid_mac_last_ce_high", dut_last.dsp_ce_p === 1'b1);

    i_valid = 1'b0;
    tick();
    check("valid_drop_mid_ce_low", dut_mid.dsp_ce_p === 1'b0);
    check("valid_drop_last_ce_low", dut_last.dsp_ce_p === 1'b0);

    instruction_in_V = 3'b100;
    inst_valid_in_V = 1'b1;
    tick();
    inst_valid_in_V = 1'b0;
    tick();
    check("flush_mid_ce_high_without_valid", dut_mid.dsp_ce_p === 1'b1);
    check("flush_last_ce_high_without_valid", dut_last.dsp_ce_p === 1'b1);

    $display("");
    $display("=== Summary ===");
    $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
    $display("FAIL: %0d", fail_count);
    if (fail_count == 0) $display("OVERALL: PASS");
    else                 $display("OVERALL: FAIL");
    $finish;
  end

endmodule
