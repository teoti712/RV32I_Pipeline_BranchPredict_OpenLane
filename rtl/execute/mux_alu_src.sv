module mux_alu_src (
    input  logic        i_sel,
    input  logic [31:0] i_A,
    input  logic [31:0] i_B,
    output logic [31:0] o_mux
);
    always_comb begin
        case (i_sel)
            1'b0: o_mux = i_A;
            1'b1: o_mux = i_B;
            default: o_mux = 32'b0;
        endcase
    end
endmodule
