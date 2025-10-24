module pipeline_phs2 (

    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_flushE,
    input  logic [4:0]  i_rs1D,
    input  logic [4:0]  i_rs2D,
    input  logic [4:0]  i_rdD,
    input  logic [31:0] i_pcD,
    input  logic [31:0] i_pc_plus4D,
    input  logic [31:0] i_rs1_dataD,
    input  logic [31:0] i_rs2_dataD,
    input  logic [31:0] i_immExtD,
    input  logic        reg_wrD,
    input  logic [1:0]  result_srcD,
    input  logic        mem_wrD,
    input  logic        jumpD,
    input  logic        branchD,
    input  logic [3:0]  alu_ctrlD,
    input  logic        alu_srcAD,
    input  logic        alu_srcBD,

    input  logic [31:0] i_alu_resultM,
    input  logic [31:0] i_resultW,    
    input  logic [1:0]  i_forwardAE,
    input  logic [1:0]  i_forwardBE,

    output logic [4:0]  o_rs1E,
    output logic [4:0]  o_rs2E,
    output logic [4:0]  o_rdE,
    output logic [31:0] o_pc_plus4E,
    output logic        reg_wrE,
    output logic [1:0]  result_srcE,
    output logic        mem_wrE,
    output logic [3:0]  o_alu_ctrlE,
    output logic        o_pc_srcE,

    output logic [31:0] o_wr_dataE,
    output logic [31:0] o_alu_resultE,
    output logic [31:0] o_pc_targetE
);
   
    logic [31:0] w_pcE;
    logic [31:0] w_rs1_dataE;
    logic [31:0] w_rs2_dataE;
    logic [31:0] w_immExtE;
    logic [3:0]  w_alu_ctrlE;
    logic        w_alu_srcAE;
    logic        w_alu_srcBE;
    logic        w_jumpE;
    logic        w_branchE;
    logic        w_o_and;
    logic        w_jump_enE;

    IDEX_register IDEX_register_inst (
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

    .o_rs1E(o_rs1E),
    .o_rs2E(o_rs2E),
    .o_rdE(o_rdE),
    .o_pcE(w_pcE),
    .o_pc_plus4E(o_pc_plus4E),
    .o_rs1_dataE(w_rs1_dataE),
    .o_rs2_dataE(w_rs2_dataE), 
    .o_immExtE(w_immExtE),
    .reg_wrE(reg_wrE),
    .result_srcE(result_srcE),
    .mem_wrE(mem_wrE),
    .jumpE(w_jumpE),
    .branchE(w_branchE),
    .alu_ctrlE(w_alu_ctrlE),
    .alu_srcAE(w_alu_srcAE),
    .alu_srcBE(w_alu_srcBE)
);

    execute execute_inst (
    .i_rs1_dataE(w_rs1_dataE),
    .i_rs2_dataE(w_rs2_dataE),
    .i_alu_resultM(i_alu_resultM),
    .i_resultW(i_resultW),
    .i_pcE(w_pcE),
    .i_immExtE(w_immExtE),
    .i_forwardAE(i_forwardAE),
    .i_forwardBE(i_forwardBE),
    .i_alu_srcAE(w_alu_srcAE),
    .i_alu_srcBE(w_alu_srcBE),
    .i_alu_ctrlE(w_alu_ctrlE),

    .o_jump_enE(w_jump_enE),
    .o_wr_dataE(o_wr_dataE),
    .o_alu_resultE(o_alu_resultE),
    .o_pc_targetE(o_pc_targetE) );


    assign w_o_and = w_branchE & w_jump_enE;
    assign o_pc_srcE = w_o_and | w_jumpE;
    assign o_alu_ctrlE = w_alu_ctrlE;


endmodule