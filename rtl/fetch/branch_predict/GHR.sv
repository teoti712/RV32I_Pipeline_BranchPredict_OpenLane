module GHR #(
    parameter WIDTH = 8
)(
    input  logic                i_clk,
    input  logic                i_rst_n,
    input  logic                i_update_en,  
    input  logic                i_taken,     
    output logic [WIDTH-1:0]    o_ghr     
);
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_ghr <= 8'b0;
        end else if (i_update_en) begin
            o_ghr <= { o_ghr[WIDTH-2:0], i_taken};
        end
    end
endmodule
