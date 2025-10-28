module pipeline(
    input logic i_clk,
    input logic i_rst_n
);


//wire signal control unit
logic       w_reg_wrW;

// wire signal data hazard
logic       w_flushD;
logic       w_stallF;
logic       w_stallD;
logic       w_flushE;

// Phase 1
logic       w_pc_srcE;
logic [31:0]w_pc_plus4F;
logic [31:0]w_pcFi;
logic [31:0]w_rdW;
logic [31:0]w_resultW;


// ===== Signals between Stage 1 -> Stage 2 =====
logic [4:0]  w_rs1D;
logic [4:0]  w_rs2D;
logic [4:0]  w_rdD;
logic [31:0] w_pcD;
logic [31:0] w_pc_plus4D;
logic [31:0] w_rs1_dataD;
logic [31:0] w_rs2_dataD;
logic [31:0] w_immExtD;
logic [31:0] w_instD;

logic        w_reg_wrD;
logic [1:0]  w_result_srcD;
logic        w_mem_wrD;
logic        w_jumpD;
logic        w_branchD;
logic [3:0]  w_alu_ctrlD;
logic        w_alu_srcAD;
logic        w_alu_srcBD;

// ===== Signals between Stage 2 -> Stage 3 =====
logic [4:0]  w_rs1E;
logic [4:0]  w_rs2E;
logic [4:0]  w_rdE;
logic [31:0] w_pc_plus4E;

logic        w_reg_wrE;
logic [1:0]  w_result_srcE;
logic        w_mem_wrE;
logic [3:0]  w_alu_ctrlE;
logic        w_pc_srcE;

logic [31:0] w_wr_dataE;
logic [31:0] w_alu_resultE;
logic [31:0] w_pc_targetE;
logic [31:0] w_instE;

// ===== Signals from EX/MEM + WB stage back to EX =====
logic [31:0] w_alu_resultM;
logic [31:0] w_resultW;

// ===== Forwarding control =====
logic [1:0] w_forwardAE;
logic [1:0] w_forwardBE;

// ===== Hazard control =====
logic w_flushE;

mux_alu_src pc_source_unit(
    .i_sel(w_pc_srcE),
    .i_A(w_pc_plus4F),
    .i_B(w_pc_targetE),
    .o_mux(w_pcFi)
);

pipeline_phs1 phs1_inst(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_reg_wrW(w_reg_wrW),
    .i_rdW(w_rdW),
    .i_resultW(w_resultW),
    .i_stallF(w_stallF),
    .i_stallD(w_stallD),
    .i_flushD(w_flushD),

    // signal to id/ex pipeline register
    .o_instD(w_instD),
    .o_rs1D(w_rs1D),
    .o_rs2D(w_rs2D),
    .o_rdD(w_rdD),
    .o_pcD(w_pcD),
    .o_pc_plus4D(w_pc_plus4D),
    .o_rs1_dataD(w_rs1_dataD),
    .o_rs2_dataD(w_rs2_dataD),
    .o_immExtD(w_immExtD),

    // signal control unit
    .reg_wrD(w_reg_wrD),
    .result_srcD(w_result_srcD),
    .mem_wrD(w_mem_wrD),
    .jumpD(w_jumpD),
    .branchD(w_branchD),
    .alu_ctrlD(w_alu_ctrlD),
    .alu_srcAD(w_alu_srcAD),
    .alu_srcBD(w_alu_srcBD)
);

pipeline_phs2 phs2_inst(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_flushE(w_flushE),
    .i_rs1D(w_rs1D),
    .i_rs2D(w_rs2D),
    .i_rdD(w_rdD),
    .i_pcD(w_pcD),
    .i_pc_plus4D(w_pc_plus4D),
    .i_rs1_dataD(w_rs1_dataD),
    .i_rs2_dataD(w_rs2_dataD),
    .i_immExtD(w_immExtD),
    .i_instD(w_instD),
    .reg_wrD(w_reg_wrD),
    .result_srcD(w_result_srcD),
    .mem_wrD(w_mem_wrD),
    .jumpD(w_jumpD),
    .branchD(w_branchD),
    .alu_ctrlD(w_alu_ctrlD),
    .alu_srcAD(w_alu_srcAD),
    .alu_srcBD(w_alu_srcBD),
    .i_alu_resultM(w_alu_resultM),
    .i_resultW(w_resultW),
    .i_forwardAE(w_forwardAE),
    .i_forwardBE(w_forwardBE),
    .o_rs1E(w_rs1E),
    .o_rs2E(w_rs2E),
    .o_rdE(w_rdE),
    .o_pc_plus4E(w_pc_plus4E),
    .reg_wrE(w_reg_wrE),
    .result_srcE(w_result_srcE),
    .mem_wrE(w_mem_wrE),
    .o_alu_ctrlE(w_alu_ctrlE),
    .o_pc_srcE(w_pc_srcE),
    .o_wr_dataE(w_wr_dataE),
    .o_alu_resultE(w_alu_resultE),
    .o_pc_targetE(w_pc_targetE),
    .o_instE(w_instE));

endmodule
