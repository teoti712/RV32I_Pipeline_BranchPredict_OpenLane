`timescale 1ns/1ps
module tb_pipeline_phs3_store_load_full;

  logic i_clk, i_rst_n;
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  initial begin
    i_rst_n = 0;
    repeat (2) @(posedge i_clk);
    i_rst_n = 1;
  end

  // === INPUTS ===
  logic [4:0]  i_rdE;
  logic [31:0] i_pc_plus4E;
  logic        i_reg_wrE;
  logic [1:0]  i_result_srcE;
  logic        i_mem_wrE;
  logic [31:0] i_wr_dataE;
  logic [31:0] i_alu_resultE;
  logic [31:0] i_instE;
  logic [31:0] i_io_sw = 0;
  logic [3:0]  i_io_btn = 0;

  // === OUTPUTS ===
  logic [4:0]  o_rdM;
  logic [31:0] o_pc_plus4M;
  logic        o_reg_wrM;
  logic [1:0]  o_result_srcM;
  logic [31:0] o_alu_resultM;
  logic [31:0] o_ld_data;
  logic [31:0] o_io_ledr, o_io_ledg, o_io_lcd;
  logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3;
  logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7;

  // === DUT ===
  pipeline_phs3 dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rdE(i_rdE),
    .i_pc_plus4E(i_pc_plus4E),
    .i_reg_wrE(i_reg_wrE),
    .i_result_srcE(i_result_srcE),
    .i_mem_wrE(i_mem_wrE),
    .i_wr_dataE(i_wr_dataE),
    .i_alu_resultE(i_alu_resultE),
    .i_instE(i_instE),
    .o_rdM(o_rdM),
    .o_pc_plus4M(o_pc_plus4M),
    .o_reg_wrM(o_reg_wrM),
    .o_result_srcM(o_result_srcM),
    .o_alu_resultM(o_alu_resultM),
    .i_io_sw(i_io_sw),
    .i_io_btn(i_io_btn),
    .o_ld_data(o_ld_data),
    .o_io_ledr(o_io_ledr),
    .o_io_ledg(o_io_ledg),
    .o_io_hex0(o_io_hex0),
    .o_io_hex1(o_io_hex1),
    .o_io_hex2(o_io_hex2),
    .o_io_hex3(o_io_hex3),
    .o_io_hex4(o_io_hex4),
    .o_io_hex5(o_io_hex5),
    .o_io_hex6(o_io_hex6),
    .o_io_hex7(o_io_hex7),
    .o_io_lcd(o_io_lcd)
  );

  // === CONSTANT ===
  localparam BASE = 32'h0000_2000;

  // === TEST PROCESS ===
  initial begin
    i_rdE         = 0;
    i_pc_plus4E   = 0;
    i_reg_wrE     = 0;
    i_result_srcE = 0;
    i_mem_wrE     = 0;
    i_wr_dataE    = 0;
    i_alu_resultE = 0;
    i_instE       = 0;

    @(posedge i_rst_n);
    @(posedge i_clk);

    // =====================
    // STORE TESTS
    // =====================
    // SB
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b000, 4'b0}; // funct3=000 (SB)
    i_mem_wrE     <= 1;
    i_alu_resultE <= BASE + 32'h4;
    i_wr_dataE    <= 32'h000000AA;

    // SH
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b001, 4'b0}; // funct3=001 (SH)
    i_alu_resultE <= BASE + 32'h8;
    i_wr_dataE    <= 32'h0000BBBB;

    // SW
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b010, 4'b0}; // funct3=010 (SW)
    i_alu_resultE <= BASE + 32'hC;
    i_wr_dataE    <= 32'hCCCCDDDD;

    // Dừng ghi
    @(posedge i_clk);
    i_mem_wrE <= 0;

    // =====================
    // LOAD TESTS
    // =====================
    // LB
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b000, 4'b0}; // LB
    i_alu_resultE <= BASE + 32'h4;

    // LH
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b001, 4'b0}; // LH
    i_alu_resultE <= BASE + 32'h8;

    // LW
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b010, 4'b0}; // LW
    i_alu_resultE <= BASE + 32'hC;

    // LBU
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b100, 4'b0}; // LBU
    i_alu_resultE <= BASE + 32'h4;

    // LHU
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b101, 4'b0}; // LHU
    i_alu_resultE <= BASE + 32'h8;

    // Lấy địa chỉ lẻ
    @(posedge i_clk);
    i_instE       <= {25'b0, 3'b000, 4'b0}; // LB tại địa chỉ lẻ
    i_alu_resultE <= BASE + 32'h5;

    repeat (2) @(posedge i_clk);
    $finish;
  end

  always @(posedge i_clk)
    $display("[%0t] clk↑ | inst[14:12]=%b | addr=%h | wr=%b | data=%h | ld=%h",
             $time, i_instE[14:12], i_alu_resultE, i_mem_wrE, i_wr_dataE, o_ld_data);

  initial begin
    $dumpfile("tb_pipeline_phs3_store_load_full.vcd");
    $dumpvars(0, tb_pipeline_phs3_store_load_full);
  end

endmodule
