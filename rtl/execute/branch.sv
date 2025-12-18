module branch (
    input  logic [31:0] i_rs1_dataE,
    input  logic [31:0] i_rs2_dataE,
    input  logic [2:0]  i_funct3E,     
    output logic        o_branch_takenE
);
    always_comb begin
        o_branch_takenE = 1'b0;
        case (i_funct3E)
            3'b000: o_branch_takenE = (i_rs1_dataE == i_rs2_dataE);                         // BEQ
            3'b001: o_branch_takenE = (i_rs1_dataE != i_rs2_dataE);                         // BNE
            3'b100: o_branch_takenE = ($signed(i_rs1_dataE) <  $signed(i_rs2_dataE));       // BLT (signed)
            3'b101: o_branch_takenE = ($signed(i_rs1_dataE) >= $signed(i_rs2_dataE));       // BGE (signed)
            3'b110: o_branch_takenE = (i_rs1_dataE < i_rs2_dataE);                         // BLTU (unsigned)
            3'b111: o_branch_takenE = (i_rs1_dataE >= i_rs2_dataE);                        // BGEU (unsigned)
            default: o_branch_takenE = 1'b0;
        endcase
    end
endmodule
