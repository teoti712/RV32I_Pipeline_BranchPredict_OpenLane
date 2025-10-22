module pc_plus4F(
    input  logic [31:0] i_pcF,
    output logic [31:0] o_pc_plus4F);

    assign o_pc_plus4F = i_pcF + 3'd4;
endmodule