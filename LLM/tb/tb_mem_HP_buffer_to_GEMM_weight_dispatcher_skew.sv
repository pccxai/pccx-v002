`timescale 1ns / 1ps
`include "GLOBAL_CONST.svh"
`include "npu_interfaces.svh"

module tb_mem_HP_buffer_to_GEMM_weight_dispatcher_skew;
  localparam int WORD_W = 128;
  localparam int LANES  = 32;
  localparam int NIB_W  = 4;

  logic clk_core = 1'b0;
  logic clk_axi = 1'b0;
  logic rst_n_core = 1'b0;
  logic rst_axi_n = 1'b0;

  axis_if #(.DATA_WIDTH(WORD_W)) S_AXI_HP0_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) S_AXI_HP1_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) S_AXI_HP2_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) S_AXI_HP3_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) M_CORE_HP0_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) M_CORE_HP1_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) M_CORE_HP2_WEIGHT ();
  axis_if #(.DATA_WIDTH(WORD_W)) M_CORE_HP3_WEIGHT ();

  logic [NIB_W-1:0] fifo_upper [0:LANES-1];
  logic [NIB_W-1:0] fifo_lower [0:LANES-1];
  logic             fifo_upper_ready;
  logic             fifo_lower_ready;
  logic [NIB_W-1:0] weight_upper [0:LANES-1];
  logic [NIB_W-1:0] weight_lower [0:LANES-1];
  logic             weight_valid;

  int pass_count = 0;
  int fail_count = 0;

  always #2.5 clk_core = ~clk_core;
  always #4 clk_axi = ~clk_axi;

  mem_HP_buffer u_hp (
      .clk_core(clk_core),
      .rst_n_core(rst_n_core),
      .clk_axi(clk_axi),
      .rst_axi_n(rst_axi_n),
      .S_AXI_HP0_WEIGHT(S_AXI_HP0_WEIGHT),
      .S_AXI_HP1_WEIGHT(S_AXI_HP1_WEIGHT),
      .S_AXI_HP2_WEIGHT(S_AXI_HP2_WEIGHT),
      .S_AXI_HP3_WEIGHT(S_AXI_HP3_WEIGHT),
      .M_CORE_HP0_WEIGHT(M_CORE_HP0_WEIGHT),
      .M_CORE_HP1_WEIGHT(M_CORE_HP1_WEIGHT),
      .M_CORE_HP2_WEIGHT(M_CORE_HP2_WEIGHT),
      .M_CORE_HP3_WEIGHT(M_CORE_HP3_WEIGHT)
  );

  GEMM_weight_dispatcher #(
      .weight_size(NIB_W),
      .weight_cnt(LANES)
  ) u_pairer (
      .clk(clk_core),
      .rst_n(rst_n_core),
      .fifo_upper(fifo_upper),
      .fifo_upper_valid(M_CORE_HP0_WEIGHT.tvalid),
      .fifo_upper_ready(fifo_upper_ready),
      .fifo_lower(fifo_lower),
      .fifo_lower_valid(M_CORE_HP1_WEIGHT.tvalid),
      .fifo_lower_ready(fifo_lower_ready),
      .weight_upper(weight_upper),
      .weight_lower(weight_lower),
      .weight_valid(weight_valid)
  );

  assign M_CORE_HP0_WEIGHT.tready = fifo_upper_ready;
  assign M_CORE_HP1_WEIGHT.tready = fifo_lower_ready;
  assign M_CORE_HP2_WEIGHT.tready = 1'b1;
  assign M_CORE_HP3_WEIGHT.tready = 1'b1;

  genvar gi;
  generate
    for (gi = 0; gi < LANES; gi++) begin : g_unpack
      assign fifo_upper[gi] = M_CORE_HP0_WEIGHT.tdata[gi*NIB_W +: NIB_W];
      assign fifo_lower[gi] = M_CORE_HP1_WEIGHT.tdata[gi*NIB_W +: NIB_W];
    end
  endgenerate

  task automatic tick_axi;
    begin
      @(posedge clk_axi);
      #1;
    end
  endtask

  task automatic tick_core;
    begin
      @(posedge clk_core);
      #1;
    end
  endtask

  task automatic check(input string name, input bit ok);
    begin
      if (ok) begin
        $display("PASS [%s]", name);
        pass_count++;
      end else begin
        $display("FAIL [%s]", name);
        fail_count++;
      end
    end
  endtask

  function automatic logic [WORD_W-1:0] make_word(input logic [3:0] seed);
    logic [WORD_W-1:0] word;
    begin
      word = '0;
      for (int i = 0; i < LANES; i++) begin
        word[i*NIB_W +: NIB_W] = seed + i[3:0];
      end
      return word;
    end
  endfunction

  function automatic bit pair_matches(
      input logic [WORD_W-1:0] exp_upper,
      input logic [WORD_W-1:0] exp_lower
  );
    bit ok;
    begin
      ok = 1'b1;
      for (int i = 0; i < LANES; i++) begin
        if (weight_upper[i] !== exp_upper[i*NIB_W +: NIB_W]) begin
          $display("  upper lane[%0d] expected=%0h actual=%0h",
                   i, exp_upper[i*NIB_W +: NIB_W], weight_upper[i]);
          ok = 1'b0;
        end
        if (weight_lower[i] !== exp_lower[i*NIB_W +: NIB_W]) begin
          $display("  lower lane[%0d] expected=%0h actual=%0h",
                   i, exp_lower[i*NIB_W +: NIB_W], weight_lower[i]);
          ok = 1'b0;
        end
      end
      return ok;
    end
  endfunction

  task automatic init_axis;
    begin
      S_AXI_HP0_WEIGHT.tdata = '0;
      S_AXI_HP0_WEIGHT.tvalid = 1'b0;
      S_AXI_HP0_WEIGHT.tkeep = 16'hffff;
      S_AXI_HP0_WEIGHT.tlast = 1'b0;
      S_AXI_HP1_WEIGHT.tdata = '0;
      S_AXI_HP1_WEIGHT.tvalid = 1'b0;
      S_AXI_HP1_WEIGHT.tkeep = 16'hffff;
      S_AXI_HP1_WEIGHT.tlast = 1'b0;
      S_AXI_HP2_WEIGHT.tdata = '0;
      S_AXI_HP2_WEIGHT.tvalid = 1'b0;
      S_AXI_HP2_WEIGHT.tkeep = 16'hffff;
      S_AXI_HP2_WEIGHT.tlast = 1'b0;
      S_AXI_HP3_WEIGHT.tdata = '0;
      S_AXI_HP3_WEIGHT.tvalid = 1'b0;
      S_AXI_HP3_WEIGHT.tkeep = 16'hffff;
      S_AXI_HP3_WEIGHT.tlast = 1'b0;
    end
  endtask

  task automatic send_hp0(input logic [WORD_W-1:0] data, input string label);
    int guard;
    begin
      S_AXI_HP0_WEIGHT.tdata = data;
      S_AXI_HP0_WEIGHT.tkeep = 16'hffff;
      S_AXI_HP0_WEIGHT.tlast = 1'b0;
      S_AXI_HP0_WEIGHT.tvalid = 1'b1;
      guard = 0;
      do begin
        tick_axi();
        guard++;
      end while (S_AXI_HP0_WEIGHT.tready !== 1'b1 && guard < 200);
      check({label, " hp0 input handshake"}, guard < 200);
      S_AXI_HP0_WEIGHT.tvalid = 1'b0;
      S_AXI_HP0_WEIGHT.tdata = '0;
    end
  endtask

  task automatic send_hp1(input logic [WORD_W-1:0] data, input string label);
    int guard;
    begin
      S_AXI_HP1_WEIGHT.tdata = data;
      S_AXI_HP1_WEIGHT.tkeep = 16'hffff;
      S_AXI_HP1_WEIGHT.tlast = 1'b0;
      S_AXI_HP1_WEIGHT.tvalid = 1'b1;
      guard = 0;
      do begin
        tick_axi();
        guard++;
      end while (S_AXI_HP1_WEIGHT.tready !== 1'b1 && guard < 200);
      check({label, " hp1 input handshake"}, guard < 200);
      S_AXI_HP1_WEIGHT.tvalid = 1'b0;
      S_AXI_HP1_WEIGHT.tdata = '0;
    end
  endtask

  task automatic check_no_pair(input string label, input int cycles);
    bit saw_valid;
    begin
      saw_valid = 1'b0;
      for (int i = 0; i < cycles; i++) begin
        tick_core();
        if (weight_valid) saw_valid = 1'b1;
      end
      check(label, !saw_valid);
    end
  endtask

  task automatic wait_ready_state(
      input string label,
      input bit exp_upper_ready,
      input bit exp_lower_ready,
      input int guard_limit
  );
    int guard;
    bit seen;
    begin
      guard = 0;
      seen = 1'b0;
      do begin
        tick_core();
        seen = (M_CORE_HP0_WEIGHT.tready === exp_upper_ready) &&
               (M_CORE_HP1_WEIGHT.tready === exp_lower_ready);
        guard++;
      end while (!seen && guard < guard_limit);
      check(label, seen);
    end
  endtask

  task automatic wait_pair(
      input string label,
      input logic [WORD_W-1:0] exp_upper,
      input logic [WORD_W-1:0] exp_lower,
      input int guard_limit
  );
    int guard;
    bit seen;
    begin
      guard = 0;
      seen = 1'b0;
      do begin
        tick_core();
        if (weight_valid) begin
          seen = 1'b1;
          check({label, " pair data"}, pair_matches(exp_upper, exp_lower));
        end
        guard++;
      end while (!seen && guard < guard_limit);
      check({label, " pair valid"}, seen);
    end
  endtask

  task automatic wait_three_pairs(
      input string label,
      input logic [WORD_W-1:0] exp_u0,
      input logic [WORD_W-1:0] exp_l0,
      input logic [WORD_W-1:0] exp_u1,
      input logic [WORD_W-1:0] exp_l1,
      input logic [WORD_W-1:0] exp_u2,
      input logic [WORD_W-1:0] exp_l2,
      input int guard_limit
  );
    logic [WORD_W-1:0] exp_u[0:2];
    logic [WORD_W-1:0] exp_l[0:2];
    int guard;
    int seen;
    begin
      exp_u[0] = exp_u0;
      exp_l[0] = exp_l0;
      exp_u[1] = exp_u1;
      exp_l[1] = exp_l1;
      exp_u[2] = exp_u2;
      exp_l[2] = exp_l2;
      seen = 0;
      guard = 0;
      while (seen < 3 && guard < guard_limit) begin
        tick_core();
        if (weight_valid) begin
          check($sformatf("%s pair[%0d] data", label, seen),
                pair_matches(exp_u[seen], exp_l[seen]));
          seen++;
        end
        guard++;
      end
      check($sformatf("%s observed 3 ordered pairs", label), seen == 3);
    end
  endtask

  initial begin
    logic [WORD_W-1:0] u0;
    logic [WORD_W-1:0] u1;
    logic [WORD_W-1:0] u2;
    logic [WORD_W-1:0] l0;
    logic [WORD_W-1:0] l1;
    logic [WORD_W-1:0] l2;

    $display("=== tb_mem_HP_buffer_to_GEMM_weight_dispatcher_skew start ===");

    init_axis();
    repeat (12) tick_axi();
    repeat (16) tick_core();
    rst_axi_n = 1'b1;
    rst_n_core = 1'b1;
    repeat (120) tick_core();

    check("reset leaves pairer invalid", weight_valid === 1'b0);
    check("initial pairer ready", M_CORE_HP0_WEIGHT.tready === 1'b1 &&
                                  M_CORE_HP1_WEIGHT.tready === 1'b1);

    u0 = make_word(4'h1);
    l0 = make_word(4'h8);
    send_hp0(u0, "upper-first single");
    wait_ready_state("upper-first pending backpressures hp0 only", 1'b0, 1'b1, 260);
    check_no_pair("upper-first no pair before lower", 12);
    fork
      wait_pair("upper-first single", u0, l0, 500);
      begin
        repeat (3) tick_axi();
        send_hp1(l0, "upper-first single");
      end
    join
    wait_ready_state("upper-first ready restored", 1'b1, 1'b1, 260);
    check_no_pair("upper-first no duplicate pair", 12);

    u0 = make_word(4'h2);
    l0 = make_word(4'h9);
    send_hp1(l0, "lower-first single");
    wait_ready_state("lower-first pending backpressures hp1 only", 1'b1, 1'b0, 260);
    check_no_pair("lower-first no pair before upper", 12);
    fork
      wait_pair("lower-first single", u0, l0, 500);
      begin
        repeat (3) tick_axi();
        send_hp0(u0, "lower-first single");
      end
    join
    wait_ready_state("lower-first ready restored", 1'b1, 1'b1, 260);
    check_no_pair("lower-first no duplicate pair", 12);

    u0 = make_word(4'h3);
    u1 = make_word(4'h4);
    u2 = make_word(4'h5);
    l0 = make_word(4'ha);
    l1 = make_word(4'hb);
    l2 = make_word(4'hc);
    send_hp0(u0, "upper-burst skew");
    send_hp0(u1, "upper-burst skew");
    send_hp0(u2, "upper-burst skew");
    wait_ready_state("upper-burst leaves hp0 backpressured", 1'b0, 1'b1, 260);
    check_no_pair("upper-burst no pair before lower burst", 12);
    fork
      wait_three_pairs("upper-burst skew", u0, l0, u1, l1, u2, l2, 1200);
      begin
        repeat (3) tick_axi();
        send_hp1(l0, "upper-burst skew");
        send_hp1(l1, "upper-burst skew");
        send_hp1(l2, "upper-burst skew");
      end
    join
    wait_ready_state("upper-burst ready restored", 1'b1, 1'b1, 260);
    check_no_pair("upper-burst no extra pair", 20);

    u0 = make_word(4'h6);
    u1 = make_word(4'h7);
    u2 = make_word(4'h8);
    l0 = make_word(4'hd);
    l1 = make_word(4'he);
    l2 = make_word(4'hf);
    send_hp1(l0, "lower-burst skew");
    send_hp1(l1, "lower-burst skew");
    send_hp1(l2, "lower-burst skew");
    wait_ready_state("lower-burst leaves hp1 backpressured", 1'b1, 1'b0, 260);
    check_no_pair("lower-burst no pair before upper burst", 12);
    fork
      wait_three_pairs("lower-burst skew", u0, l0, u1, l1, u2, l2, 1200);
      begin
        repeat (3) tick_axi();
        send_hp0(u0, "lower-burst skew");
        send_hp0(u1, "lower-burst skew");
        send_hp0(u2, "lower-burst skew");
      end
    join
    wait_ready_state("lower-burst ready restored", 1'b1, 1'b1, 260);
    check_no_pair("lower-burst no extra pair", 20);

    $display("");
    $display("PASS: %0d / %0d", pass_count, pass_count + fail_count);
    $display("FAIL: %0d", fail_count);
    if (fail_count == 0) begin
      $display("OVERALL: PASS");
      $finish;
    end
    $display("OVERALL: FAIL");
    $finish;
  end
endmodule
