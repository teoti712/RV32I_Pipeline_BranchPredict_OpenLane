module IFID_register(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_flushD,
    input  logic        i_stallD,
    input  logic [31:0] i_instF,
    input  logic [31:0] i_pcF,
    input  logic [31:0] i_pc_plus4F,

    output logic [31:0] o_instD,
    output logic [31:0] o_pcD,
    output logic [31:0] o_pc_plus4D
);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_instD      <= 32'b0;
            o_pcD        <= 32'b0;
            o_pc_plus4D  <= 32'b0;
        end
        else if (i_flushD) begin
            o_instD      <= 32'b0;
            o_pcD        <= 32'b0;
            o_pc_plus4D  <= 32'b0;
        end
        else if (i_stallD) begin
            o_instD      <= o_instD;
            o_pcD        <= o_pcD;
            o_pc_plus4D  <= o_pc_plus4D;
        end
        else begin
            o_instD      <= i_instF;
            o_pcD        <= i_pcF;
            o_pc_plus4D  <= i_pc_plus4F;            
        end

    end

endmodule
