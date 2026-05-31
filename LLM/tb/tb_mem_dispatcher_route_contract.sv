// PCCX(TM) — reusable AI accelerator project.
// SPDX-FileCopyrightText: 2026 Hyun Woo Kim
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns / 1ps
`include "GLOBAL_CONST.svh"
`include "GEMM_Array.svh"
`include "npu_interfaces.svh"
`include "mem_IO.svh"

import isa_pkg::*;

module xpm_fifo_axis #(
    parameter int FIFO_DEPTH = 16,
    parameter int TDATA_WIDTH = 128,
    parameter string FIFO_MEMORY_TYPE = "auto",
    parameter string CLOCKING_MODE = "common_clock"
) (
    input  logic                   s_aclk,
    input  logic                   m_aclk,
    input  logic                   s_aresetn,
    input  logic [TDATA_WIDTH-1:0] s_axis_tdata,
    input  logic                   s_axis_tvalid,
    input  logic [TDATA_WIDTH/8-1:0] s_axis_tstrb,
    input  logic [TDATA_WIDTH/8-1:0] s_axis_tkeep,
    input  logic                   s_axis_tlast,
    output logic                   s_axis_tready,
    input  logic                   m_axis_tready,
    output logic [TDATA_WIDTH-1:0] m_axis_tdata,
    output logic                   m_axis_tvalid,
    output logic [TDATA_WIDTH/8-1:0] m_axis_tkeep,
    output logic                   m_axis_tlast
);
  assign s_axis_tready = m_axis_tready;
  assign m_axis_tdata  = s_axis_tdata;
  assign m_axis_tvalid = s_axis_tvalid;
  assign m_axis_tkeep  = s_axis_tkeep;
  assign m_axis_tlast  = s_axis_tlast;

  wire unused_fifo_axis_inputs = s_aclk ^ m_aclk ^ s_aresetn ^ ^s_axis_tstrb;
endmodule

module xpm_fifo_sync #(
    parameter int FIFO_WRITE_DEPTH = 16,
    parameter int WRITE_DATA_WIDTH = 32,
    parameter int READ_DATA_WIDTH = WRITE_DATA_WIDTH,
    parameter string FIFO_MEMORY_TYPE = "auto",
    parameter string READ_MODE = "std",
    parameter int FIFO_READ_LATENCY = 1,
    parameter int FULL_RESET_VALUE = 0,
    parameter int PROG_FULL_THRESH = FIFO_WRITE_DEPTH
) (
    input  logic                        sleep,
    input  logic                        rst,
    input  logic                        wr_clk,
    input  logic                        wr_en,
    input  logic [WRITE_DATA_WIDTH-1:0] din,
    input  logic                        rd_en,
    output logic [READ_DATA_WIDTH-1:0]  dout,
    output logic                        empty,
    output logic                        full,
    output logic                        prog_full
);
  localparam int Depth = (FIFO_WRITE_DEPTH < 2) ? 2 : FIFO_WRITE_DEPTH;
  localparam int PtrW = $clog2(Depth);
  localparam int CountW = $clog2(Depth + 1);

  logic [WRITE_DATA_WIDTH-1:0] mem [0:Depth-1];
  logic [PtrW-1:0] wr_ptr;
  logic [PtrW-1:0] rd_ptr;
  logic [CountW-1:0] count;
  logic [READ_DATA_WIDTH-1:0] dout_reg;
  logic do_wr;
  logic do_rd;

  assign empty = (count == '0);
  assign full = (count == CountW'(Depth));
  assign prog_full = (count >= CountW'(PROG_FULL_THRESH));
  assign do_wr = wr_en && !full;
  assign do_rd = rd_en && !empty;
  assign dout = (READ_MODE == "fwft") ? READ_DATA_WIDTH'(mem[rd_ptr]) : dout_reg;

  always_ff @(posedge wr_clk) begin
    if (rst) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
      count  <= '0;
      dout_reg <= '0;
    end else begin
      if (do_wr) begin
        mem[wr_ptr] <= din;
        wr_ptr <= (wr_ptr == PtrW'(Depth - 1)) ? '0 : wr_ptr + PtrW'(1);
      end

      if (do_rd) begin
        if (READ_MODE != "fwft") dout_reg <= READ_DATA_WIDTH'(mem[rd_ptr]);
        rd_ptr <= (rd_ptr == PtrW'(Depth - 1)) ? '0 : rd_ptr + PtrW'(1);
      end

      unique case ({do_wr, do_rd})
        2'b10: count <= count + CountW'(1);
        2'b01: count <= count - CountW'(1);
        default: count <= count;
      endcase
    end
  end

  wire unused_fifo_sync_inputs = sleep;
endmodule

module xpm_memory_tdpram #(
    parameter int ADDR_WIDTH_A = 17,
    parameter int ADDR_WIDTH_B = 17,
    parameter int WRITE_DATA_WIDTH_A = 128,
    parameter int READ_DATA_WIDTH_A = 128,
    parameter int WRITE_DATA_WIDTH_B = 128,
    parameter int READ_DATA_WIDTH_B = 128,
    parameter int BYTE_WRITE_WIDTH_A = 128,
    parameter int BYTE_WRITE_WIDTH_B = 128,
    parameter int MEMORY_SIZE = 128 * 1024,
    parameter string MEMORY_PRIMITIVE = "auto",
    parameter string CLOCKING_MODE = "common_clock",
    parameter int CASCADE_HEIGHT = 0,
    parameter int READ_LATENCY_A = 7,
    parameter int READ_LATENCY_B = 6,
    parameter string WRITE_MODE_A = "no_change",
    parameter string WRITE_MODE_B = "no_change",
    parameter string MEMORY_INIT_FILE = "none",
    parameter string MEMORY_INIT_PARAM = "0",
    parameter int USE_MEM_INIT = 0,
    parameter int AUTO_SLEEP_TIME = 0,
    parameter string WAKEUP_TIME = "disable_sleep",
    parameter string ECC_MODE = "no_ecc",
    parameter int USE_EMBEDDED_CONSTRAINT = 0
) (
    input  logic clka,
    input  logic rsta,
    input  logic ena,
    input  logic wea,
    input  logic [ADDR_WIDTH_A-1:0] addra,
    input  logic [WRITE_DATA_WIDTH_A-1:0] dina,
    output logic [READ_DATA_WIDTH_A-1:0] douta,
    input  logic regcea,
    input  logic injectsbiterra,
    input  logic injectdbiterra,
    output logic sbiterra,
    output logic dbiterra,
    input  logic clkb,
    input  logic rstb,
    input  logic enb,
    input  logic web,
    input  logic [ADDR_WIDTH_B-1:0] addrb,
    input  logic [WRITE_DATA_WIDTH_B-1:0] dinb,
    output logic [READ_DATA_WIDTH_B-1:0] doutb,
    input  logic regceb,
    input  logic injectsbiterrb,
    input  logic injectdbiterrb,
    output logic sbiterrb,
    output logic dbiterrb
);
  localparam int Depth = MEMORY_SIZE / WRITE_DATA_WIDTH_A;

  logic [127:0] mem [0:Depth-1];
  logic [127:0] pipe_a [0:READ_LATENCY_A-1];
  logic [127:0] pipe_b [0:READ_LATENCY_B-1];

  assign sbiterra = 1'b0;
  assign dbiterra = 1'b0;
  assign sbiterrb = 1'b0;
  assign dbiterrb = 1'b0;

  always_ff @(posedge clka) begin
    if (rsta) begin
      for (int i = 0; i < READ_LATENCY_A; i++) pipe_a[i] <= '0;
      douta <= '0;
    end else if (ena) begin
      if (wea) mem[addra] <= dina;
      pipe_a[0] <= mem[addra];
      for (int i = 1; i < READ_LATENCY_A; i++) pipe_a[i] <= pipe_a[i-1];
      if (regcea) douta <= pipe_a[READ_LATENCY_A-2];
    end
  end

  always_ff @(posedge clkb) begin
    if (rstb) begin
      for (int i = 0; i < READ_LATENCY_B; i++) pipe_b[i] <= '0;
      doutb <= '0;
    end else if (enb) begin
      if (web) mem[addrb] <= dinb;
      pipe_b[0] <= mem[addrb];
      for (int i = 1; i < READ_LATENCY_B; i++) pipe_b[i] <= pipe_b[i-1];
      if (regceb) doutb <= pipe_b[READ_LATENCY_B-2];
    end
  end

  wire unused_mem_inputs = injectsbiterra ^ injectdbiterra ^ injectsbiterrb ^ injectdbiterrb;
endmodule

module tb_mem_dispatcher_route_contract;
  logic clk = 1'b0;
  logic rst_n = 1'b0;

  axis_if #(.DATA_WIDTH(128)) s_acp_fmap();
  axis_if #(.DATA_WIDTH(128)) m_acp_result();
  axis_if #(.DATA_WIDTH(128)) m_l1_fmap();

  memory_control_uop_t load_uop;
  logic load_valid;
  memory_control_uop_t store_uop;
  logic store_valid;
  memory_set_uop_t mem_set_uop;
  logic mem_set_valid;
  cvo_control_uop_t cvo_uop;
  logic cvo_valid;

  logic [15:0] cvo_data;
  logic cvo_data_valid;
  logic cvo_data_ready;
  logic [15:0] cvo_result;
  logic cvo_result_valid;
  logic cvo_result_ready;
  logic [`AXI_STREAM_WIDTH-1:0] gemm_result_data;
  logic gemm_result_valid;
  logic gemm_result_ready;
  logic fifo_full;
  logic cvo_busy;
  logic store_busy;
  logic store_done;
  logic memset_done;
  logic [15:0] debug_status;

  int acp_pulses;
  int npu_pulses;

  always #5 clk = ~clk;

  mem_dispatcher dut (
      .clk_core(clk),
      .rst_n_core(rst_n),
      .clk_axi(clk),
      .rst_axi_n(rst_n),
      .S_AXIS_ACP_FMAP(s_acp_fmap),
      .M_AXIS_ACP_RESULT(m_acp_result),
      .M_AXIS_L1_FMAP(m_l1_fmap),
      .IN_LOAD_uop(load_uop),
      .IN_LOAD_uop_valid(load_valid),
      .IN_STORE_uop(store_uop),
      .IN_store_uop_valid(store_valid),
      .IN_mem_set_uop(mem_set_uop),
      .IN_mem_set_uop_valid(mem_set_valid),
      .IN_CVO_uop(cvo_uop),
      .IN_cvo_uop_valid(cvo_valid),
      .OUT_cvo_data(cvo_data),
      .OUT_cvo_valid(cvo_data_valid),
      .IN_cvo_data_ready(cvo_data_ready),
      .IN_cvo_result(cvo_result),
      .IN_cvo_result_valid(cvo_result_valid),
      .OUT_cvo_result_ready(cvo_result_ready),
      .IN_gemm_result_data(gemm_result_data),
      .IN_gemm_result_valid(gemm_result_valid),
      .OUT_gemm_result_ready(gemm_result_ready),
      .OUT_fifo_full(fifo_full),
      .OUT_cvo_busy(cvo_busy),
      .OUT_store_busy(store_busy),
      .OUT_store_done(store_done),
      .OUT_memset_done(memset_done),
      .OUT_debug_status(debug_status)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      acp_pulses <= 0;
      npu_pulses <= 0;
    end else begin
      if (dut.acp_rx_start) acp_pulses <= acp_pulses + 1;
      if (dut.npu_rx_start) npu_pulses <= npu_pulses + 1;
    end
  end

  task automatic fail(input string msg);
    begin
      $display("OVERALL: FAIL - %s", msg);
      $fatal(1, "%s", msg);
    end
  endtask

  task automatic expect_bit(input string name, input logic got, input logic exp);
    begin
      if (got !== exp) begin
        $display("FAIL: %s got=%0b expected=%0b", name, got, exp);
        fail(name);
      end
      $display("PASS: %s = %0b", name, got);
    end
  endtask

  task automatic expect_addr(input string name, input logic [16:0] got, input logic [16:0] exp);
    begin
      if (got !== exp) begin
        $display("FAIL: %s got=%0d expected=%0d", name, got, exp);
        fail(name);
      end
      $display("PASS: %s = %0d", name, got);
    end
  endtask

  task automatic expect_no_new_pulses(input string name, input int acp_before, input int npu_before);
    begin
      repeat (20) @(negedge clk);
      if (acp_pulses != acp_before || npu_pulses != npu_before) begin
        $display(
            "FAIL: %s acp %0d->%0d npu %0d->%0d",
            name,
            acp_before,
            acp_pulses,
            npu_before,
            npu_pulses
        );
        fail(name);
      end
      $display("PASS: %s", name);
    end
  endtask

  task automatic reset_dut();
    begin
      s_acp_fmap.tdata = '0;
      s_acp_fmap.tvalid = 1'b0;
      s_acp_fmap.tlast = 1'b0;
      s_acp_fmap.tkeep = '1;
      m_acp_result.tready = 1'b0;
      m_l1_fmap.tready = 1'b0;
      load_uop = '0;
      load_valid = 1'b0;
      store_uop = '0;
      store_valid = 1'b0;
      mem_set_uop = '0;
      mem_set_valid = 1'b0;
      cvo_uop = '0;
      cvo_valid = 1'b0;
      cvo_data_ready = 1'b0;
      cvo_result = '0;
      cvo_result_valid = 1'b0;
      gemm_result_data = '0;
      gemm_result_valid = 1'b0;
      rst_n = 1'b0;
      repeat (8) @(negedge clk);
      rst_n = 1'b1;
      repeat (4) @(negedge clk);
    end
  endtask

  task automatic write_fmap_shape(
      input logic [5:0] ptr,
      input logic [16:0] x,
      input logic [16:0] y,
      input logic [16:0] z
  );
    begin
      @(negedge clk);
      mem_set_uop.dest_cache = data_to_fmap_shape;
      mem_set_uop.dest_addr = ptr;
      mem_set_uop.a_value = x[15:0];
      mem_set_uop.b_value = y[15:0];
      mem_set_uop.c_value = z[15:0];
      mem_set_valid = 1'b1;
      @(negedge clk);
      mem_set_valid = 1'b0;
      repeat (2) @(negedge clk);
    end
  endtask

  task automatic issue_load(
      input data_route_e route,
      input logic [16:0] dest_addr,
      input logic [16:0] src_addr,
      input logic [5:0] shape_ptr
  );
    begin
      @(negedge clk);
      load_uop.data_dest = route;
      load_uop.dest_addr = dest_addr;
      load_uop.src_addr = src_addr;
      load_uop.shape_ptr_addr = shape_ptr;
      load_uop.async = SYNC_OP;
      load_valid = 1'b1;
      @(negedge clk);
      load_valid = 1'b0;
    end
  endtask

  task automatic wait_acp_descriptor(
      input string name,
      input logic exp_write,
      input logic [16:0] exp_base,
      input logic [16:0] exp_end
  );
    begin
      for (int i = 0; i < 20; i++) begin
        @(posedge clk);
        if (dut.acp_rx_start) begin
          expect_bit({name, " write_en"}, dut.acp_uop.write_en, exp_write);
          expect_addr({name, " base"}, dut.acp_uop.base_addr, exp_base);
          expect_addr({name, " end"}, dut.acp_uop.end_addr, exp_end);
          $display("PASS: %s descriptor observed", name);
          return;
        end
      end
      fail({name, " descriptor timeout"});
    end
  endtask

  task automatic wait_npu_descriptor(
      input string name,
      input logic exp_write,
      input logic [16:0] exp_base,
      input logic [16:0] exp_end
  );
    begin
      for (int i = 0; i < 20; i++) begin
        @(posedge clk);
        if (dut.npu_rx_start) begin
          expect_bit({name, " write_en"}, dut.npu_uop.write_en, exp_write);
          expect_addr({name, " base"}, dut.npu_uop.base_addr, exp_base);
          expect_addr({name, " end"}, dut.npu_uop.end_addr, exp_end);
          $display("PASS: %s descriptor observed", name);
          return;
        end
      end
      fail({name, " descriptor timeout"});
    end
  endtask

  initial begin
    int acp_before;
    int npu_before;

    reset_dut();

    write_fmap_shape(6'd3, 17'd5, 17'd2, 17'd1);

    issue_load(from_host_to_L2, 17'd20, 17'd90, 6'd3);
    wait_acp_descriptor("from_host_to_L2", 1'b1, 17'd20, 17'd22);
    @(negedge clk);
    acp_before = acp_pulses;
    npu_before = npu_pulses;
    expect_no_new_pulses("stale host_to_L2 uop does not retrigger", acp_before, npu_before);

    issue_load(from_L2_to_host, 17'd20, 17'd31, 6'd3);
    wait_acp_descriptor("from_L2_to_host", 1'b0, 17'd31, 17'd33);

    issue_load(from_L2_to_L1_GEMM, 17'd0, 17'd44, 6'd3);
    wait_npu_descriptor("from_L2_to_L1_GEMM", 1'b0, 17'd44, 17'd46);

    issue_load(from_L2_to_L1_GEMV, 17'd0, 17'd55, 6'd3);
    wait_npu_descriptor("from_L2_to_L1_GEMV", 1'b0, 17'd55, 17'd57);

    @(negedge clk);
    acp_before = acp_pulses;
    npu_before = npu_pulses;
    issue_load(from_L2_to_CVO, 17'd0, 17'd60, 6'd3);
    expect_no_new_pulses("from_L2_to_CVO does not enqueue ACP/NPU load", acp_before, npu_before);

    write_fmap_shape(6'd4, 17'd0, 17'd8, 17'd1);
    acp_before = acp_pulses;
    npu_before = npu_pulses;
    issue_load(from_host_to_L2, 17'd70, 17'd0, 6'd4);
    expect_no_new_pulses("zero element shape does not enqueue descriptor", acp_before, npu_before);

    $display("OVERALL: PASS");
    $finish;
  end
endmodule
