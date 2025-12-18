module control_unit (
    input   logic [6:0]     i_op,
    input   logic [2:0]     i_func3,
    input   logic [6:0]     i_func7,

    output  logic           reg_wrD,     
    output  logic [1:0]     result_srcD, 
    output  logic           mem_wrD,     
    output  logic           jumpD,      
    output  logic           branchD,    
    output  logic [3:0]     alu_ctrlD,  
    output  logic           alu_srcAD,
    output  logic           alu_srcBD   );


    localparam [6:0] op_RTYPE = 7'b0110011,  
                     op_ITYPE = 7'b0010011,  
                     op_LOAD  = 7'b0000011,  
                     op_STORE = 7'b0100011,  
                     op_BRANCH= 7'b1100011,  
                     op_JAL   = 7'b1101111,  
                     op_JALR  = 7'b1100111,  
                     op_LUI   = 7'b0110111,  
                     op_AUIPC = 7'b0010111;        
    localparam [3:0] func_ADD  = 4'b0_000,
                     func_SUB  = 4'b1_000,
                     func_SLL  = 4'b0_001,
                     func_SLT  = 4'b0_010,
                     func_SLTU = 4'b0_011,
                     func_XOR  = 4'b0_100,
                     func_SRL  = 4'b0_101,
                     func_SRA  = 4'b1_101,
                     func_OR   = 4'b0_110,   
                     func_AND  = 4'b0_111; 
 
    always_comb begin
        if(i_op == 7'b0000000) begin
            {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 4'd0, 1'b0, 1'b0};
        end
        else begin
        case(i_op) 

            op_RTYPE: begin
                      {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_srcAD, alu_srcBD} = {1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                        case({i_func7[5],i_func3})
                            func_ADD:   alu_ctrlD = 4'd0;
                            func_SUB:   alu_ctrlD = 4'd1;
                            func_SLL:   alu_ctrlD = 4'd2;
                            func_SRL:   alu_ctrlD = 4'd3;    
                            func_XOR:   alu_ctrlD = 4'd4;
                            func_AND:   alu_ctrlD = 4'd5;
                            func_OR:    alu_ctrlD = 4'd6;
                            func_SLT:   alu_ctrlD = 4'd7;
                            func_SLTU:  alu_ctrlD = 4'd8;
                            func_SRA:   alu_ctrlD = 4'd9;
                            default:    alu_ctrlD = 4'd0;
                        endcase                
                end
            op_ITYPE: begin
                        {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_srcAD, alu_srcBD} ={1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};

                        case (i_func3)
                            3'b000: alu_ctrlD = 4'd0; // ADDI
                            3'b001: alu_ctrlD = 4'd2; // SLLI (shamt)
                            3'b010: alu_ctrlD = 4'd7; // SLTI
                            3'b011: alu_ctrlD = 4'd8; // SLTIU
                            3'b100: alu_ctrlD = 4'd4; // XORI
                            3'b101: begin              // SRLI or SRAI depending on bit30
                                if (i_func7[5]) alu_ctrlD = 4'd9; // SRAI
                                else            alu_ctrlD = 4'd3; // SRLI
                                end
                            3'b110: alu_ctrlD = 4'd6; // ORI
                            3'b111: alu_ctrlD = 4'd5; // ANDI
                            default: alu_ctrlD = 4'd0;
                        endcase
                    end 
	        op_BRANCH:{reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 4'd0, 1'b1, 1'b1};   
            op_LOAD:  {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b1, 2'b01, 1'b0, 1'b0, 1'b0, 4'd0, 1'b0, 1'b1};
            op_STORE: {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 4'd0, 1'b0, 1'b1};
            op_JAL:   {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b1, 2'b10, 1'b0, 1'b1, 1'b0, 4'd0, 1'b1, 1'b1};
            op_JALR:  {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b1, 2'b10, 1'b0, 1'b1, 1'b0, 4'd0, 1'b0, 1'b1};
            op_LUI:   {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 4'd10,1'b0, 1'b1};
            op_AUIPC: {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 4'd0, 1'b1, 1'b1};
            default:  {reg_wrD, result_srcD, mem_wrD, jumpD, branchD, alu_ctrlD, alu_srcAD, alu_srcBD} = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 4'd0, 1'b0, 1'b0};
        endcase
        end        
    end    
endmodule

