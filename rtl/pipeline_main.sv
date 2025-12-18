module pipeline(
    input logic i_clk,
    input logic i_rst_n,
    input logic [31:0] i_io_sw,
    input logic [3:0] i_io_btn,
   // Outputs:
    output logic [31:0] o_ld_data,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0] o_io_hex0,
    output logic [6:0] o_io_hex1,
    output logic [6:0] o_io_hex2,
    output logic [6:0] o_io_hex3,
    output logic [6:0] o_io_hex4,
    output logic [6:0] o_io_hex5,
    output logic [6:0] o_io_hex6,
    output logic [6:0] o_io_hex7,
    output logic [31:0] o_io_lcd);

logic        w_stallF;
//logic        w_pc_srcE;
//logic [31:0] w_pc_targetE;
logic [31:0] w_instF;
logic [31:0] w_pcF;
logic [31:0] w_pc_plus4F;

//branch preidctor unit signal
logic       w_is_branchE;
logic       w_actual_takenE;
logic [7:0] w_pht_idxE;
logic [31:0]w_pcE;
logic [31:0]w_targetE;
logic [31:0]w_correct_pcE;
logic       w_mispredE;
logic [7:0] w_pht_idxF;
logic       w_pred_takenF;
logic [31:0]w_pred_targetF;


fetch_stage u_fetch_stage (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_stallF    (w_stallF),
    //.i_pc_srcE   (w_pc_srcE),
    //.i_pc_targetE(w_pc_targetE),
    .o_instF     (w_instF),
    .o_pcF       (w_pcF),
    .o_pc_plus4F (w_pc_plus4F),
    .i_is_branchE(w_is_branchE),
    .i_actual_takenE(w_actual_takenE),
    .i_pht_idxE(w_pht_idxE),
    .i_pcE(w_pcE),
    .i_targetE(w_targetE),
    .i_correct_pcE(w_correct_pcE),
    .i_mispredE(w_mispredE),
    .o_pht_idxF(w_pht_idxF),
    .o_pred_takenF(w_pred_takenF),
    .o_pred_targetF(w_pred_targetF));

logic        w_flushD;
logic        w_stallD;
logic [31:0] w_instD;
logic [31:0] w_pcD;
logic [31:0] w_pc_plus4D;
//
logic [7:0]  w_pht_idxD;
logic        w_pred_takenD;
logic [31:0] w_pred_targetD;

IFID_register u_IFID_register (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_flushD   (w_flushD),
    .i_stallD   (w_stallD),
    .i_instF    (w_instF),
    .i_pcF      (w_pcF),
    .i_pc_plus4F(w_pc_plus4F),
    .o_instD    (w_instD),
    .o_pcD      (w_pcD),
    .o_pc_plus4D(w_pc_plus4D),
    //branch_predictor_unit_signal
    .i_pht_idxF(w_pht_idxF),
    .i_pred_takenF(w_pred_takenF),
    .i_pred_targetF(w_pred_targetF),
    .o_pht_idxD (w_pht_idxD),
    .o_pred_takenD(w_pred_takenD),
    .o_pred_targetD(w_pred_targetD));

logic [31:0] w_resultW;
logic [4:0]  w_rdW;
logic        w_reg_wrW;

logic [31:0] w_immExtD;
logic [31:0] w_rs1_dataD;
logic [31:0] w_rs2_dataD;
logic        w_reg_wrD;
logic [1:0]  w_result_srcD;
logic        w_mem_wrD;
logic        w_jumpD;
logic        w_branchD;
logic [3:0]  w_alu_ctrlD;
logic        w_alu_srcAD;
logic        w_alu_srcBD;

decode_stage u_decode_stage (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_instD     (w_instD),
    .i_resultW   (w_resultW),
    .i_rdW       (w_rdW),
    .i_reg_wrW   (w_reg_wrW),
    .o_immExtD   (w_immExtD),
    .o_rs1_dataD (w_rs1_dataD),
    .o_rs2_dataD (w_rs2_dataD),
    .reg_wrD     (w_reg_wrD),
    .result_srcD (w_result_srcD),
    .mem_wrD     (w_mem_wrD),
    .jumpD       (w_jumpD),
    .branchD     (w_branchD),
    .alu_ctrlD   (w_alu_ctrlD),
    .alu_srcAD   (w_alu_srcAD),
    .alu_srcBD   (w_alu_srcBD));

logic        w_flushE;
logic [4:0]  w_rs1D;
logic [4:0]  w_rs2D;
logic [4:0]  w_rdD;

logic [4:0]  w_rs1E;
logic [4:0]  w_rs2E;
logic [4:0]  w_rdE;
//logic [31:0] w_pcE;
logic [31:0] w_pc_plus4E;
logic [31:0] w_rs1_dataE;
logic [31:0] w_rs2_dataE;
logic [31:0] w_immExtE;
logic        w_reg_wrE;
logic [1:0]  w_result_srcE;
logic        w_mem_wrE;
logic        w_jumpE;
logic        w_branchE;
logic [3:0]  w_alu_ctrlE;
logic        w_alu_srcAE;
logic        w_alu_srcBE;
logic [31:0] w_instE;

assign w_rs1D = w_instD[19:15];
assign w_rs2D = w_instD[24:20];
assign w_rdD  = w_instD[11:7];
//
//logic [7:0]  w_pht_idxE;
logic        w_pred_takenE;
logic [31:0] w_pred_targetE;

IDEX_register u_IDEX_register (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_flushE    (w_flushE),
    .i_rs1D      (w_rs1D),
    .i_rs2D      (w_rs2D),
    .i_rdD       (w_rdD),
    .i_pcD       (w_pcD),
    .i_pc_plus4D (w_pc_plus4D),
    .i_rs1_dataD (w_rs1_dataD),
    .i_rs2_dataD (w_rs2_dataD),
    .i_immExtD   (w_immExtD),
    .reg_wrD     (w_reg_wrD),
    .result_srcD (w_result_srcD),
    .mem_wrD     (w_mem_wrD),
    .jumpD       (w_jumpD),
    .branchD     (w_branchD),
    .alu_ctrlD   (w_alu_ctrlD),
    .alu_srcAD   (w_alu_srcAD),
    .alu_srcBD   (w_alu_srcBD),
    .i_instD     (w_instD),
    .o_rs1E      (w_rs1E),
    .o_rs2E      (w_rs2E),
    .o_rdE       (w_rdE),
    .o_pcE       (w_pcE),
    .o_pc_plus4E (w_pc_plus4E),
    .o_rs1_dataE (w_rs1_dataE),
    .o_rs2_dataE (w_rs2_dataE),
    .o_immExtE   (w_immExtE),
    .reg_wrE     (w_reg_wrE),
    .result_srcE (w_result_srcE),
    .mem_wrE     (w_mem_wrE),
    .jumpE       (w_jumpE),
    .branchE     (w_branchE),
    .alu_ctrlE   (w_alu_ctrlE),
    .alu_srcAE   (w_alu_srcAE),
    .alu_srcBE   (w_alu_srcBE),
    .o_instE     (w_instE),
    //branch_predictor_unit_signal
    .i_pht_idxD(w_pht_idxD),
    .i_pred_takenD(w_pred_takenD),
    .i_pred_targetD(w_pred_targetD),
    .o_pht_idxE (w_pht_idxE),
    .o_pred_takenE(w_pred_takenE),
    .o_pred_targetE(w_pred_targetE));

logic [1:0]  w_forwardAE;
logic [1:0]  w_forwardBE;
logic [31:0] w_wr_dataE;
logic [31:0] w_alu_resultE;
logic        w_branch_takenE; //
logic [31:0] w_alu_resultM;
logic [31:0] w_actual_targetE;
execute_stage u_execute_stage (
    .i_instE        (w_instE),
    .i_rs1_dataE    (w_rs1_dataE),
    .i_rs2_dataE    (w_rs2_dataE),
    .i_alu_resultM  (w_alu_resultM),
    .i_resultW      (w_resultW),
    .i_pcE          (w_pcE),
    .i_immExtE      (w_immExtE),
    .i_forwardAE    (w_forwardAE),
    .i_forwardBE    (w_forwardBE),
    .i_alu_srcAE    (w_alu_srcAE),
    .i_alu_srcBE    (w_alu_srcBE),
    .i_alu_ctrlE    (w_alu_ctrlE),
    .o_branch_takenE(w_branch_takenE), //
    .o_wr_dataE     (w_wr_dataE),
    .o_alu_resultE  (w_alu_resultE),
    .o_pc_targetE   (w_actual_targetE));


//jump
logic w_and;
and(w_and,w_branch_takenE,w_branchE);
or(w_actual_takenE,w_and,w_jumpE);

//is_branchE
or (w_is_branchE, w_jumpE, w_branchE);

//branch_resolve_unit
branch_resolve_unit u_branch_resolve_unit (
    .i_is_branchE(w_is_branchE),
    .i_pred_takenE(w_pred_takenE),
    .i_pred_targetE(w_pred_targetE),
    .i_actual_takenE(w_actual_takenE),
    .i_actual_targetE(w_alu_resultE), // 
    .i_pc_plus4E(w_pc_plus4E),
    .o_mispredE(w_mispredE),
    .o_correct_pcE(w_correct_pcE));
//
logic [4:0]  w_rdM;
logic [31:0] w_pc_plus4M;
logic        w_reg_wrM;
logic [1:0]  w_result_srcM;
logic        w_mem_wrM;
logic [31:0] w_wr_dataM;
logic [31:0] w_instM;

EXMEM_register u_EXMEM_register (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_rdE          (w_rdE),
    .i_pc_plus4E    (w_pc_plus4E),
    .i_reg_wrE      (w_reg_wrE),
    .i_result_srcE  (w_result_srcE),
    .i_mem_wrE      (w_mem_wrE),
    .i_wr_dataE     (w_wr_dataE),
    .i_alu_resultE  (w_alu_resultE),
    .i_instE        (w_instE),
    .o_rdM          (w_rdM),
    .o_pc_plus4M    (w_pc_plus4M),
    .o_reg_wrM      (w_reg_wrM),
    .o_result_srcM  (w_result_srcM),
    .o_mem_wrM      (w_mem_wrM),
    .o_wr_dataM     (w_wr_dataM),
    .o_alu_resultM  (w_alu_resultM),
    .o_instM        (w_instM));

logic [31:0] w_ld_dataM;

lsu u_lsu (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_lsu_op    (w_instM[14:12]), 
    .i_lsu_addr  (w_alu_resultM),
    .i_st_data   (w_wr_dataM),
    .i_lsu_wren  (w_mem_wrM),
    .i_io_sw     (i_io_sw),
    .i_io_btn    (i_io_btn),
    .o_ld_data   (w_ld_dataM),
    .o_io_ledr   (o_io_ledr),
    .o_io_ledg   (o_io_ledg),
    .o_io_hex0   (o_io_hex0),
    .o_io_hex1   (o_io_hex1),
    .o_io_hex2   (o_io_hex2),
    .o_io_hex3   (o_io_hex3),
    .o_io_hex4   (o_io_hex4),
    .o_io_hex5   (o_io_hex5),
    .o_io_hex6   (o_io_hex6),
    .o_io_hex7   (o_io_hex7),
    .o_io_lcd    (o_io_lcd));

logic [31:0] w_alu_resultW;
logic [31:0] w_ld_dataW;
logic [31:0] w_pc_plus4W;
logic [1:0]  w_result_srcW;
MEMWB_pipepline u_MEMWB_pipepline (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_alu_resultM  (w_alu_resultM),
    .i_read_dataM   (w_ld_dataM),
    .i_rdM          (w_rdM),
    .i_pc_plus4M    (w_pc_plus4M),
    .i_reg_wrM      (w_reg_wrM),
    .i_result_srcM  (w_result_srcM),
    .o_alu_resultW  (w_alu_resultW),
    .o_read_dataW   (w_ld_dataW),
    .o_rdW          (w_rdW),
    .o_pc_plus4W    (w_pc_plus4W),
    .o_reg_wrW      (w_reg_wrW),
    .o_result_srcW  (w_result_srcW)
);

mux_forward u_mux_resultW (
    .i_sel  (w_result_srcW),
    .i_A    (w_alu_resultW),
    .i_B    (w_ld_dataW),
    .i_C    (w_pc_plus4W),
    .o_mux  (w_resultW));

data_hazard u_data_hazard (
    .i_rs1D        (w_rs1D),
    .i_rs2D        (w_rs2D),
    .i_rs1E        (w_rs1E),
    .i_rs2E        (w_rs2E),
    .i_rdE         (w_rdE),
    .i_pc_srcE     (w_mispredE), //  changed 
    .i_result_srcE (w_result_srcE),
    .i_reg_wrM     (w_reg_wrM),
    .i_rdM         (w_rdM),
    .i_reg_wrW     (w_reg_wrW),
    .i_rdW         (w_rdW),
    .o_stallF      (w_stallF),
    .o_stallD      (w_stallD),
    .o_flushD      (w_flushD),
    .o_flushE      (w_flushE),
    .o_forwardAE   (w_forwardAE),
    .o_forwardBE   (w_forwardBE));
endmodule

