module fetch_stage(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_stallF,
    input  logic        i_pc_srcE,   
    input  logic [31:0] i_pc_targetE, 

    output logic [31:0] o_instF,
    output logic [31:0] o_pcF,
    output logic [31:0] o_pc_plus4F
);

    logic [31:0] w_pc_plus4F, w_pcFi, w_pcF;

    mux_alu_src mux_pc_Src (
        .i_sel(i_pc_srcE),
        .i_A(w_pc_plus4F),
        .i_B(i_pc_targetE),
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