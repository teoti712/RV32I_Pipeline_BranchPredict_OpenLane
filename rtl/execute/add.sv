module add(
    input  logic [31:0] i_pcE,
    input  logic [31:0] i_immExtE,
    output logic [31:0] o_pc_targetE);

    assign o_pc_targetE = i_pcE + i_immExtE;
endmodule