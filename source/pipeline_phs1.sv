module pipeline_phs1 (

    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_reg_wrW,
    input  logic [4:0]   i_rdW,
    input  logic [31:0]  i_resultW,
    input  logic         i_stallF,
    input  logic         i_stallD,
    input  logic         i_flushD,
   

    // signal to id/ex pipeline  register
    output logic [4:0]   o_rs1D,
    output logic [4:0]   o_rs2D,
    output logic [4:0]   o_rdD,
    output logic [31:0]  o_pcD,
    output logic [31:0]  o_pc_plus4D,
    output logic [31:0]  o_rs1_dataD,
    output logic [31:0]  o_rs2_dataD,
    output logic [31:0]  o_immExtD,

    // signal control unit
    output logic         reg_wrD,     
    output logic [1:0]   result_srcD, 
    output logic         mem_wrD,     
    output logic         jumpD,      
    output logic         branchD,    
    output logic [3:0]   alu_ctrlD,  
    output logic         alu_srcAD,
    output logic         alu_srcBD   );

    logic [31:0] w_instF, w_instD, w_pcF, w_pc_plus4F;

    fetch   fetch_inst(
                       .i_clk(i_clk),
                       .i_rst_n(i_rst_n),
                       .i_stallF(i_stallF),
                       .o_instF(w_instF),
                       .o_pcF(w_pcF),
                       .o_pc_plus4F(w_pc_plus4F) );

    IFID_register IFID_register_inst(
                                    .i_clk(i_clk),
                                    .i_rst_n(i_rst_n),
                                    .i_flushD(i_flushD),
                                    .i_stallD(i_stallD),
                                    .i_instF(w_instF),
                                    .i_pcF(w_pcF),
                                    .i_pc_plus4F(w_pc_plus4F),
                                    .o_instD(w_instD),
                                    .o_pcD(o_pcD),
                                    .o_pc_plus4D(o_pc_plus4D)  );
    decode  decode_inst(
                       .i_clk(i_clk),
                       .i_rst_n(i_rst_n),
                       .i_inst(w_instD),
                       .i_reg_wrW(i_reg_wrW),
                       .i_rdW(i_rdW),
                       .i_resultW(i_resultW),   
	                   .o_rs1_dataD(o_rs1_dataD), 
	                   .o_rs2_dataD(o_rs2_dataD),   
                       .o_immExtD(o_immExtD),
                       .reg_wrD(reg_wrD),     
                       .result_srcD(result_srcD), 
                       .mem_wrD(mem_wrD),     
                       .jumpD(jumpD),      
                       .branchD(branchD),    
                       .alu_ctrlD(alu_ctrlD),  
                       .alu_srcAD(alu_srcAD),
                       .alu_srcBD(alu_srcBD)   );
    
    assign o_rs1D = w_instD[19:15];
    assign o_rs2D = w_instD[24:20];
    assign o_rdD  = w_instD[11:7];
    


endmodule