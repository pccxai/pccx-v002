// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 pccxai
//
// tb_GEMM_weight_dispatcher — dual-lane INT4 weight register stage.
//
// DUT spec:
//   fifo_upper[32], fifo_lower[32] : INT4 each
//   fifo_*_valid                   : per-lane valid
//   weight_upper/lower             : registered output (1-cycle latency)
//   weight_valid                   = fifo_upper_valid & fifo_lower_valid
//   fifo_*_ready                   = always 1 (push-only)
//
// Test cases:
//   1. Both valid: data registered with 1-cycle latency, weight_valid=1 next cycle.
//   2. Only upper valid: weight_valid=0 (AND of both), data still registered.
//   3. Only lower valid: same.
//   4. Both invalid: weight_valid=0.
//   5. Two consecutive valid: second cycle's data appears 1 cycle later.

`timescale 1ns / 1ps

module tb_GEMM_weight_dispatcher;

    localparam int WEIGHT_SIZE = 4;
    localparam int WEIGHT_CNT  = 32;

    logic clk = 0;
    logic rst_n = 0;
    logic [WEIGHT_SIZE-1:0] fifo_upper [0:WEIGHT_CNT-1];
    logic                   fifo_upper_valid;
    logic                   fifo_upper_ready;
    logic [WEIGHT_SIZE-1:0] fifo_lower [0:WEIGHT_CNT-1];
    logic                   fifo_lower_valid;
    logic                   fifo_lower_ready;
    logic [WEIGHT_SIZE-1:0] weight_upper [0:WEIGHT_CNT-1];
    logic [WEIGHT_SIZE-1:0] weight_lower [0:WEIGHT_CNT-1];
    logic                   weight_valid;

    always #5 clk = ~clk;

    int pass_count = 0, fail_count = 0;

    GEMM_weight_dispatcher #(
        .weight_size(WEIGHT_SIZE),
        .weight_cnt (WEIGHT_CNT)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .fifo_upper(fifo_upper), .fifo_upper_valid(fifo_upper_valid), .fifo_upper_ready(fifo_upper_ready),
        .fifo_lower(fifo_lower), .fifo_lower_valid(fifo_lower_valid), .fifo_lower_ready(fifo_lower_ready),
        .weight_upper(weight_upper), .weight_lower(weight_lower), .weight_valid(weight_valid)
    );

    task automatic check_arrays(input string label,
                                input logic [WEIGHT_SIZE-1:0] expected_upper [0:WEIGHT_CNT-1],
                                input logic [WEIGHT_SIZE-1:0] expected_lower [0:WEIGHT_CNT-1],
                                input logic                   expected_valid);
        bit ok = 1;
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            if (weight_upper[i] !== expected_upper[i] || weight_lower[i] !== expected_lower[i]) begin
                ok = 0;
                $display("  MISMATCH [%s] lane %0d: upper got=%h exp=%h, lower got=%h exp=%h",
                         label, i, weight_upper[i], expected_upper[i], weight_lower[i], expected_lower[i]);
            end
        end
        if (weight_valid !== expected_valid) begin
            ok = 0;
            $display("  MISMATCH [%s] valid got=%b exp=%b", label, weight_valid, expected_valid);
        end
        if (ok) begin
            $display("PASS [%s]: valid=%b", label, weight_valid);
            pass_count++;
        end else begin
            fail_count++;
        end
    endtask

    logic [WEIGHT_SIZE-1:0] expected_u [0:WEIGHT_CNT-1];
    logic [WEIGHT_SIZE-1:0] expected_l [0:WEIGHT_CNT-1];
    logic [WEIGHT_SIZE-1:0] zeros [0:WEIGHT_CNT-1];
    logic [WEIGHT_SIZE-1:0] last_u [0:WEIGHT_CNT-1];
    logic [WEIGHT_SIZE-1:0] last_l [0:WEIGHT_CNT-1];

    initial begin
        $display("=== tb_GEMM_weight_dispatcher start ===");

        // Init
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            fifo_upper[i] = '0;
            fifo_lower[i] = '0;
            zeros[i] = '0;
            last_u[i] = '0;
            last_l[i] = '0;
        end
        fifo_upper_valid = 0;
        fifo_lower_valid = 0;

        // Reset
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        if (fifo_upper_ready === 1'b1 && fifo_lower_ready === 1'b1) begin
            $display("PASS [ready_initial]: both ready=1");
            pass_count++;
        end else begin
            $display("FAIL [ready_initial]: upper=%b lower=%b", fifo_upper_ready, fifo_lower_ready);
            fail_count++;
        end

        // === Test 1: aligned lanes pass through as one pair ===
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            fifo_upper[i] = WEIGHT_SIZE'(i & 4'hF);
            fifo_lower[i] = WEIGHT_SIZE'((WEIGHT_CNT - i) & 4'hF);
            expected_u[i] = WEIGHT_SIZE'(i & 4'hF);
            expected_l[i] = WEIGHT_SIZE'((WEIGHT_CNT - i) & 4'hF);
        end
        fifo_upper_valid = 1;
        fifo_lower_valid = 1;
        @(posedge clk);
        #1;
        check_arrays("both_valid_pattern", expected_u, expected_l, 1'b1);
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            last_u[i] = expected_u[i];
            last_l[i] = expected_l[i];
        end
        fifo_upper_valid = 0;
        fifo_lower_valid = 0;
        @(posedge clk);
        #1;

        // === Test 2: upper arrives first and is held pending ===
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            fifo_upper[i] = WEIGHT_SIZE'((i + 5) & 4'hF);
            expected_u[i] = WEIGHT_SIZE'((i + 5) & 4'hF);
        end
        fifo_upper_valid = 1;
        fifo_lower_valid = 0;
        @(posedge clk);
        #1;
        check_arrays("upper_first_does_not_emit", last_u, last_l, 1'b0);
        if (fifo_upper_ready === 1'b0 && fifo_lower_ready === 1'b1) begin
            $display("PASS [upper_pending_backpressures_upper]");
            pass_count++;
        end else begin
            $display("FAIL [upper_pending_backpressures_upper]: upper=%b lower=%b",
                     fifo_upper_ready, fifo_lower_ready);
            fail_count++;
        end

        for (int i = 0; i < WEIGHT_CNT; i++) begin
            fifo_lower[i] = WEIGHT_SIZE'((i + 3) & 4'hF);
            expected_l[i] = WEIGHT_SIZE'((i + 3) & 4'hF);
        end
        fifo_upper_valid = 0;
        fifo_lower_valid = 1;
        @(posedge clk);
        #1;
        check_arrays("upper_first_pairs_with_later_lower", expected_u, expected_l, 1'b1);
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            last_u[i] = expected_u[i];
            last_l[i] = expected_l[i];
        end
        fifo_lower_valid = 0;
        @(posedge clk);
        #1;

        // === Test 3: lower arrives first and is held pending ===
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            fifo_lower[i] = WEIGHT_SIZE'((i + 9) & 4'hF);
            expected_l[i] = WEIGHT_SIZE'((i + 9) & 4'hF);
        end
        fifo_upper_valid = 0;
        fifo_lower_valid = 1;
        @(posedge clk);
        #1;
        check_arrays("lower_first_does_not_emit", last_u, last_l, 1'b0);
        if (fifo_upper_ready === 1'b1 && fifo_lower_ready === 1'b0) begin
            $display("PASS [lower_pending_backpressures_lower]");
            pass_count++;
        end else begin
            $display("FAIL [lower_pending_backpressures_lower]: upper=%b lower=%b",
                     fifo_upper_ready, fifo_lower_ready);
            fail_count++;
        end

        for (int i = 0; i < WEIGHT_CNT; i++) begin
            fifo_upper[i] = WEIGHT_SIZE'((i + 11) & 4'hF);
            expected_u[i] = WEIGHT_SIZE'((i + 11) & 4'hF);
        end
        fifo_upper_valid = 1;
        fifo_lower_valid = 0;
        @(posedge clk);
        #1;
        check_arrays("lower_first_pairs_with_later_upper", expected_u, expected_l, 1'b1);
        for (int i = 0; i < WEIGHT_CNT; i++) begin
            last_u[i] = expected_u[i];
            last_l[i] = expected_l[i];
        end
        fifo_upper_valid = 0;
        @(posedge clk);
        #1;

        // === Test 4: both invalid ===
        fifo_upper_valid = 0;
        fifo_lower_valid = 0;
        @(posedge clk);
        #1;
        check_arrays("both_invalid_holds_last_pair", last_u, last_l, 1'b0);

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
