module mux_forward (
    input  logic [1:0]  i_sel,
    input  logic [31:0] i_A,
    input  logic [31:0] i_B,
    input  logic [31:0] i_C,
    output logic [31:0] o_mux
);
    always_comb begin
        case (i_sel)
            2'b00: o_mux = i_A;
            2'b01: o_mux = i_B;
            2'b10: o_mux = i_C;
            default: o_mux = 32'b0;
        endcase
    end
endmodule
