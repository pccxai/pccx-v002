// PCCX(TM) — reusable AI accelerator project.
// SPDX-FileCopyrightText: 2026 Hyun Woo Kim
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps

// ===| Module: GEMM_weight_dispatcher — dual-lane INT4 weight register stage |==
// Purpose      : Final pipeline flop for the dual-lane (upper/lower) INT4
//                weight bus before it enters the systolic array. Decouples
//                the HP CDC FIFOs from the 32×32 PE grid timing.
// Spec ref     : pccx v002 §2.2.2 (weight stationary fan-out).
// Phase        : pccx v002 (W4A8, 1 DSP = 2 MAC).
// Clock        : clk @ 400 MHz.
// Reset        : rst_n active-low.
// Width        : weight_size (= INT4 = 4) × weight_cnt (= 32).
// Latency      : 1 register stage (input → weight_upper/lower / weight_valid).
// Throughput   : 1 dual-INT4 vector per cycle while both lanes valid.
// Handshake    : One pending beat per lane. If HP0/HP1 arrive skewed, the
//                early lane is buffered and backpressured until the matching
//                lane arrives. Aligned streams still run at 1 pair/cycle.
// Reset state  : weight_upper/lower zeroed; weight_valid = 0.
// Counters     : none.
// Migration    : v001 had a single 32 × INT4 stream; v002 needs two
//                streams (upper + lower) because each DSP MAC processes
//                two weights per cycle (GEMM_dsp_packer pairs them).
// ===============================================================================

`include "GLOBAL_CONST.svh"
`include "GEMM_Array.svh"

module GEMM_weight_dispatcher #(
  parameter int weight_size = `INT4_WIDTH,                         // 4
  parameter int weight_cnt  = `HP_SINGLE_WIDTH / `INT4_WIDTH  // 32 = 128/4
) (
  input  logic clk,
  input  logic rst_n,

  // ===| Upper-channel input (e.g. HP0 lane, already unpacked) |================
  input  logic [weight_size-1:0] fifo_upper     [0:weight_cnt-1],
  input  logic                   fifo_upper_valid,
  output logic                   fifo_upper_ready,

  // ===| Lower-channel input (e.g. HP1 lane, already unpacked) |================
  input  logic [weight_size-1:0] fifo_lower     [0:weight_cnt-1],
  input  logic                   fifo_lower_valid,
  output logic                   fifo_lower_ready,

  // ===| Registered outputs to the systolic array |=============================
  output logic [weight_size-1:0] weight_upper [0:weight_cnt-1],
  output logic [weight_size-1:0] weight_lower [0:weight_cnt-1],
  (* max_fanout = 32 *) output logic weight_valid
);

  // ===| One-beat lane pairer |==================================================
  logic [weight_size-1:0] pending_upper[0:weight_cnt-1];
  logic [weight_size-1:0] pending_lower[0:weight_cnt-1];
  logic                   pending_upper_valid;
  logic                   pending_lower_valid;
  logic                   upper_accept;
  logic                   lower_accept;
  logic                   have_upper;
  logic                   have_lower;
  logic                   pair_fire;

  assign fifo_upper_ready = !pending_upper_valid;
  assign fifo_lower_ready = !pending_lower_valid;
  assign upper_accept     = fifo_upper_valid & fifo_upper_ready;
  assign lower_accept     = fifo_lower_valid & fifo_lower_ready;
  assign have_upper       = pending_upper_valid | upper_accept;
  assign have_lower       = pending_lower_valid | lower_accept;
  assign pair_fire        = have_upper & have_lower;

  // ===| Pipeline register stage |==============================================
  //   Fires when both channels have a beat, either from the current inputs or
  //   from a pending early beat. This keeps the downstream PE array paired even
  //   when the independent HP FIFOs expose a small valid skew.
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      weight_valid <= 1'b0;
      pending_upper_valid <= 1'b0;
      pending_lower_valid <= 1'b0;
      for (int i = 0; i < weight_cnt; i++) begin
        weight_upper[i] <= '0;
        weight_lower[i] <= '0;
        pending_upper[i] <= '0;
        pending_lower[i] <= '0;
      end
    end else begin
      weight_valid <= pair_fire;

      if (pair_fire) begin
        pending_upper_valid <= 1'b0;
        pending_lower_valid <= 1'b0;
        for (int i = 0; i < weight_cnt; i++) begin
          weight_upper[i] <= pending_upper_valid ? pending_upper[i] : fifo_upper[i];
          weight_lower[i] <= pending_lower_valid ? pending_lower[i] : fifo_lower[i];
        end
      end else begin
        if (upper_accept) begin
          pending_upper_valid <= 1'b1;
          for (int i = 0; i < weight_cnt; i++) begin
            pending_upper[i] <= fifo_upper[i];
          end
        end
        if (lower_accept) begin
          pending_lower_valid <= 1'b1;
          for (int i = 0; i < weight_cnt; i++) begin
            pending_lower[i] <= fifo_lower[i];
          end
        end
      end
    end
  end

endmodule
