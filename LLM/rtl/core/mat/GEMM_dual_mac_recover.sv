// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 pccxai
`timescale 1ns / 1ps

`include "GLOBAL_CONST.svh"

// ===| Module: GEMM_dual_mac_recover |==========================================
// Recover the two packed W4A8 MAC lanes from one DSP48E2 P value and combine
// them into the single signed sum consumed by the current 32-column result path.
//
// GEMM_dsp_packer packs lower and upper INT4 weights into one DSP A operand.
// GEMM_sign_recovery reverses the packed product and fixes the lower-lane
// borrow into the upper slice. This wrapper sign-extends both recovered lane
// sums and adds them before normalisation.
// =============================================================================
module GEMM_dual_mac_recover #(
    parameter int P_PORT_W    = `DEVICE_DSP_P_WIDTH,
    parameter int UPPER_SHIFT = 21,
    parameter int LOWER_W     = UPPER_SHIFT,
    parameter int UPPER_W     = 21
) (
    input  logic signed [P_PORT_W-1:0] in_p_accum,
    output logic signed [P_PORT_W-1:0] out_sum
);

  logic signed [LOWER_W-1:0] lower_sum;
  logic signed [UPPER_W-1:0] upper_sum;
  logic signed [P_PORT_W-1:0] lower_ext;
  logic signed [P_PORT_W-1:0] upper_ext;

  GEMM_sign_recovery #(
      .P_PORT_W   (P_PORT_W),
      .UPPER_SHIFT(UPPER_SHIFT),
      .LOWER_W    (LOWER_W),
      .UPPER_W    (UPPER_W)
  ) u_sign_recovery (
      .in_p_accum   (in_p_accum),
      .out_lower_sum(lower_sum),
      .out_upper_sum(upper_sum)
  );

  assign lower_ext = {{(P_PORT_W-LOWER_W){lower_sum[LOWER_W-1]}}, lower_sum};
  assign upper_ext = {{(P_PORT_W-UPPER_W){upper_sum[UPPER_W-1]}}, upper_sum};
  assign out_sum   = lower_ext + upper_ext;

endmodule
