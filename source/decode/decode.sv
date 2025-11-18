module decode (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic [31:0]  i_inst,
    input  logic         i_reg_wrW,
    input  logic [4:0]   i_rdW,
    input  logic [31:0]  i_resultW,
    
    output logic [31:0]  o_rs1_dataD,
    output logic [31:0]  o_rs2_dataD,
    output logic [31:0]  o_immExtD,
    output logic         reg_wrD,     
    output logic [1:0]   result_srcD, 
    output logic         mem_wrD,     
    output logic         jumpD,      
    output logic         branchD,    
    output logic [3:0]   alu_ctrlD,  
    output logic         alu_srcAD,
    output logic         alu_srcBD);
            

    imm_gen imm_gen_inst (
	    .i_instD(i_inst),
	    .o_immExtD(o_immExtD));

    reg_file reg_file_inst (	
	    .i_rd_data(i_resultW),
	    .i_rd_addr(i_rdW),
	    .i_rs1_addr(i_inst[19:15]), 
	    .i_rs2_addr(i_inst[24:20]),	
	    .i_rd_wren(i_reg_wrW),
	    .i_rst_n(i_rst_n), 
	    .i_clk(i_clk), 
	    .o_rs1_data(o_rs1_dataD), 
	    .o_rs2_data(o_rs2_dataD));
    
    control_unit ctr_unit_inst (
        .i_op(i_inst[6:0]),
        .i_func3(i_inst[14:12]),
                                .i_func7(i_inst[31:25]),
                                .reg_wrD(reg_wrD),     
                                .result_srcD(result_srcD), 
                                .mem_wrD(mem_wrD),     
                                .jumpD(jumpD),      
                                .branchD(branchD),    
                                .alu_ctrlD(alu_ctrlD),  
                                .alu_srcAD(alu_srcAD),
                                .alu_srcBD(alu_srcBD)   );
endmodule