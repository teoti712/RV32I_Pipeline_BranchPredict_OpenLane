module fetch_stage(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_stallF,
    //input  logic        i_pc_srcE,   
    //input  logic [31:0] i_pc_targetE, 

    output logic [31:0] o_instF,
    output logic [31:0] o_pcF,
    output logic [31:0] o_pc_plus4F,

    // branch_predictor_unit_signal
    input  logic        i_is_branchE,
    input  logic        i_actual_takenE,
    input  logic [7:0]  i_pht_idxE,
    input  logic [31:0] i_pcE,
    input  logic [31:0] i_targetE,
    input  logic [31:0] i_correct_pcE,
    input  logic        i_mispredE,

    output logic [7:0]  o_pht_idxF,
    output logic        o_pred_takenF,
    output logic [31:0] o_pred_targetF);

    logic [31:0] w_pc_plus4F, w_pcFi, w_pcF, w_next_pcF;


    branch_predict_unit u_branch_predict_unit(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_pcF(w_pcF),
        .i_pc_plus4F(w_pc_plus4F),
        .o_next_pcF(w_next_pcF),
        .o_pht_idxF(o_pht_idxF),
        .o_pred_takenF(o_pred_takenF),
        .o_pred_targetF(o_pred_targetF),
        .i_is_branchE(i_is_branchE),
        .i_actual_takenE(i_actual_takenE),
        .i_pht_idxE(i_pht_idxE),
        .i_pcE(i_pcE),
        .i_targetE(i_targetE));

    mux_alu_src mux_pc_Src (
        .i_sel(i_mispredE),
        .i_A(w_next_pcF),
        .i_B(i_correct_pcE),
        .o_mux(w_pcFi)
    );
    pc  pc_inst(
        .i_clk(i_clk),                
        .i_rst_n(i_rst_n), 
        .i_stallF(i_stallF),
        .i_pcFi(w_pcFi),
        .o_pcF(w_pcF));
    inst_mem  inst_mem_inst ( 
        .i_pcF(w_pcF),
	    .o_instF(o_instF));  
    pc_plus4F   pc_plus4F_inst (
        .i_pcF(w_pcF),
        .o_pc_plus4F(w_pc_plus4F));     

    assign o_pc_plus4F = w_pc_plus4F;
    assign o_pcF = w_pcF;
endmodule