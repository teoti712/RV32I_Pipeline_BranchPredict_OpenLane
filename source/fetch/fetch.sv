module fetch(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_stallF,

    output logic [31:0]     o_instF,
    output logic [31:0]     o_pcF,
    output logic [31:0]     o_pc_plus4F );

    logic  [31:0] w_pcF,w_pc_plus4F;

    pc  pc_inst(.i_clk(i_clk), 
                .i_rst_n(i_rst_n), 
                .i_stallF(i_stallF),
                .i_pcFi(w_pc_plus4F),
                .o_pcF(w_pcF));

    inst_mem    inst_mem_inst ( .i_pcF(w_pcF),
	                        .o_instF(o_instF));
    
    pc_plus4F   pc_plus4F_inst (.i_pcF(w_pcF),
                                .o_pc_plus4F(w_pc_plus4F));

    assign o_pc_plus4F = w_pc_plus4F;
    assign o_pcF = w_pcF;

endmodule