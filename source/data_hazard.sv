module data_hazard (

    input  logic [4:0]  i_rs1D,
    input  logic [4:0]  i_rs2D,
    input  logic [4:0]  i_rs1E,
    input  logic [4:0]  i_rs2E,
    input  logic [4:0]  i_rdE,
    input  logic        i_pc_srcE,
    input  logic [1:0]  i_result_srcE
    input  logic        i_reg_wrM,
    input  logic [4:0]  i_rdM,
    input  logic        i_reg_wrW,
    input  logic [4:0]  i_rdW,


    output logic        o_stallF,
    output logic        o_stallD,
    output logic        o_flushD,
    output logic        o_flushE,
    output logic [1:0]  o_forwardAE,
    output logic [1:0]  o_forwardBE,
);


    always_comb begin  
    //EX hazard
        if (i_reg_wrM && (i_rdM != 5'b0) && (i_rdM == i_rs1E))
            o_forwardAE = 2'b10;  
        if (i_reg_wrM && (i_rdM != 5'b0) && (i_rdM == i_rs2E))
            o_forwardBE = 2'b10;  
    //MEM hazard
        if (i_reg_wrW && (i_rdW != 5'b0) && (i_rdW == i_rs1E)
            && !(i_reg_wrM && (i_rdM != 5'b0) && (i_rdM == i_rs1E)))
            o_forwardAE = 2'b01;             
        if (i_reg_wrW && (i_rdW != 5'b0) && (i_rdW == i_rs2E)
            && !(i_reg_wrM && (i_rdM != 5'b0) && (i_rdM == i_rs2E)))
            o_forwardBE = 2'b01;    
    end
    
    // EX is a load instruction
    logic w_load_use_hazard;
    assign w_load_use_hazard = (i_result_srcE == 2'b01) &&  ((i_rdE == i_rs1D) || (i_rdE == i_rs2D));

    always_comb begin
        
        if (i_pc_srcE) begin
            o_flushD = 1'b1;
            o_flushE = 1'b1;
        end

        if (w_load_use_hazard) begin
            o_stallF = 1'b1;
            o_stallD = 1'b1;
            o_flushE = 1'b1;
        end
    end



endmodule