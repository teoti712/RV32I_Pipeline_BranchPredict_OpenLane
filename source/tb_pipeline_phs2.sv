`timescale 1ns/1ps
`default_nettype none

module tb_pipeline_jump_branch;

  // Clock & Reset
  logic i_clk = 0;
  logic i_rst_n = 0;
  always #5 i_clk = ~i_clk;   // 100MHz clock

  // Inputs to DUT
  logic        i_flushE;
  logic [4:0]  i_rs1D, i_rs2D, i_rdD;
  logic [31:0] i_pcD, i_pc_plus4D;
  logic [31:0] i_rs1_dataD, i_rs2_dataD, i_immExtD;
  logic        reg_wrD, mem_wrD, jumpD, branchD;
  logic [1:0]  result_srcD;
  logic [3:0]  alu_ctrlD;
  logic        alu_srcAD, alu_srcBD;
  logic [31:0] i_alu_resultM, i_resultW;
  logic [1:0]  i_forwardAE, i_forwardBE;

  // Outputs from DUT
  logic [4:0]  o_rs1E, o_rs2E, o_rdE;
  logic [31:0] o_pc_plus4E;
  logic        reg_wrE, mem_wrE;
  logic [1:0]  result_srcE;
  logic        o_pc_srcE;
  logic [31:0] o_wr_dataE, o_alu_resultE, o_pc_targetE;

  // DUT instance
  pipeline_phs2 dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_flushE(i_flushE),
    .i_rs1D(i_rs1D),
    .i_rs2D(i_rs2D),
    .i_rdD(i_rdD),
    .i_pcD(i_pcD),
    .i_pc_plus4D(i_pc_plus4D),
    .i_rs1_dataD(i_rs1_dataD),
    .i_rs2_dataD(i_rs2_dataD),
    .i_immExtD(i_immExtD),
    .reg_wrD(reg_wrD),
    .result_srcD(result_srcD),
    .mem_wrD(mem_wrD),
    .jumpD(jumpD),
    .branchD(branchD),
    .alu_ctrlD(alu_ctrlD),
    .alu_srcAD(alu_srcAD),
    .alu_srcBD(alu_srcBD),
    .i_alu_resultM(i_alu_resultM),
    .i_resultW(i_resultW),
    .i_forwardAE(i_forwardAE),
    .i_forwardBE(i_forwardBE),
    .o_rs1E(o_rs1E),
    .o_rs2E(o_rs2E),
    .o_rdE(o_rdE),
    .o_pc_plus4E(o_pc_plus4E),
    .reg_wrE(reg_wrE),
    .result_srcE(result_srcE),
    .mem_wrE(mem_wrE),
    .o_pc_srcE(o_pc_srcE),
    .o_wr_dataE(o_wr_dataE),
    .o_alu_resultE(o_alu_resultE),
    .o_pc_targetE(o_pc_targetE)
  );

  // ============================
  // Testbench stimulus
  // ============================
  initial begin
    $display("\n===== PIPELINE TEST: jumpD & branchD =====");
    $monitor("[%0t] jumpD=%b branchD=%b alu_ctrlD=%0d o_pc_srcE=%b o_alu_resultE=%0d",
              $time, jumpD, branchD, alu_ctrlD, o_pc_srcE, o_alu_resultE);

    // Initialize
    i_rst_n = 0;
    i_flushE = 0;
    i_rs1D = 5'd1;
    i_rs2D = 5'd2;
    i_rdD  = 5'd3;
    i_pcD = 32'h1000;
    i_pc_plus4D = 32'h1004;
    i_rs1_dataD = 32'd10;
    i_rs2_dataD = 32'd5;
    i_immExtD = 32'd4;
    reg_wrD = 1;
    result_srcD = 2'b00;
    mem_wrD = 0;
    alu_ctrlD = 4'd0; // default ADD
    alu_srcAD = 0;
    alu_srcBD = 0;
    i_alu_resultM = 32'd0;
    i_resultW = 32'd0;
    i_forwardAE = 2'b00;
    i_forwardBE = 2'b00;
    jumpD = 0;
    branchD = 0;

    // Reset deassert
    repeat (2) @(posedge i_clk);
    i_rst_n = 1;

    // ------------------------
    // CASE 1: No jump/branch
    // ------------------------
    @(posedge i_clk);
    jumpD = 0; branchD = 0; alu_ctrlD = 4'd0;
    @(posedge i_clk);
    $display("CASE 1: No Jump/Branch -> o_pc_srcE=%b (expect 0)", o_pc_srcE);

    // ------------------------
    // CASE 2: Jump only (1 cycle)
    // ------------------------
    @(posedge i_clk);
    jumpD = 1; branchD = 0; alu_ctrlD = 4'd0;
    @(posedge i_clk);
    jumpD = 0; // chỉ bật 1 chu kỳ
    @(posedge i_clk);
    $display("CASE 2: Jump=1 (1 cycle) -> o_pc_srcE=%b (expect 1 for 1 cycle)", o_pc_srcE);

    // ------------------------
    // CASE 3: Branch active - SLTU true (rs1 < rs2)
    // ------------------------
    @(posedge i_clk);
    jumpD = 0; branchD = 1;
    alu_ctrlD = 4'd8;   // SLTU
    i_rs1_dataD = 32'd5;
    i_rs2_dataD = 32'd10; // rs1 < rs2 => ALU jump true
    @(posedge i_clk);
    branchD = 0; // branch chỉ 1 chu kỳ
    @(posedge i_clk);
    $display("CASE 3: Branch=1, SLTU true -> o_pc_srcE=%b (expect 1)", o_pc_srcE);

    // ------------------------
    // CASE 4: Branch active - SLTU false (rs1 > rs2)
    // ------------------------
    @(posedge i_clk);
    jumpD = 0; branchD = 1;
    alu_ctrlD = 4'd8;
    i_rs1_dataD = 32'd12;
    i_rs2_dataD = 32'd2; // rs1 > rs2 => ALU jump false
    @(posedge i_clk);
    branchD = 0;
    @(posedge i_clk);
    $display("CASE 4: Branch=1, SLTU false -> o_pc_srcE=%b (expect 0)", o_pc_srcE);

    // ------------------------
    // CASE 5: Jump & Branch together (priority OR)
    // ------------------------
    @(posedge i_clk);
    jumpD = 1; branchD = 1;
    alu_ctrlD = 4'd8;
    i_rs1_dataD = 32'd5;
    i_rs2_dataD = 32'd10;
    @(posedge i_clk);
    jumpD = 0; branchD = 0;
    @(posedge i_clk);
    $display("CASE 5: Jump+Branch=1 -> o_pc_srcE=%b (expect 1)", o_pc_srcE);

    $display("===== TEST FINISHED =====\n");
    $stop;
  end

endmodule
