module alu (
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic [3:0]  i_alu_sel,
    output logic [31:0] o_alu_resultE
);

    logic [4:0] shamt;
    assign shamt = i_rs2_data[4:0];

    always_comb begin
        case (i_alu_sel)
            4'b0000: o_alu_resultE = i_rs1_data + i_rs2_data;             // ADD
            4'b0001: o_alu_resultE = i_rs1_data - i_rs2_data;             // SUB
            4'b0010: o_alu_resultE = i_rs1_data << shamt;                 // SLL
            4'b0011: o_alu_resultE = i_rs1_data >> shamt;                 // SRL
            4'b0100: o_alu_resultE = i_rs1_data ^  i_rs2_data;            // XOR
            4'b0101: o_alu_resultE = i_rs1_data &  i_rs2_data;            // AND
            4'b0110: o_alu_resultE = i_rs1_data |  i_rs2_data;            // OR
            4'b0111: o_alu_resultE = ($signed(i_rs1_data) < $signed(i_rs2_data)) ? 32'd1 : 32'd0; // SLT
            4'b1000: o_alu_resultE = (i_rs1_data < i_rs2_data) ? 32'd1 : 32'd0;                    // SLTU
            4'b1001: o_alu_resultE = $signed(i_rs1_data) >>> shamt;        // SRA
            4'b1010: o_alu_resultE = i_rs2_data;                           // LUI (or custom)
            4'b1011: o_alu_resultE = (i_rs1_data + i_rs2_data) & 32'hFFFF_FFFC; // align for JALR
            default: o_alu_resultE = 32'd0; 
        endcase
    end
endmodule
