module MEMWB_pipepline(

input  logic        i_clk,
input  logic        i_rst_n,
input  logic [31:0] i_alu_resultM,
input  logic [31:0] i_read_dataM,
input  logic [31:0] i_rdM,
input  logic [31:0] i_pc_plus4M,
input  logic [31:0] i_reg_wrM,
input  logic [31:0] i_result_srcM,

output  logic [31:0] o_alu_resultW,
output  logic [31:0] o_read_dataW,
output  logic [31:0] o_rdW,
output  logic [31:0] o_pc_plus4W,
output  logic [31:0] o_reg_wrW,
output  logic [31:0] o_result_srcW );

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_alu_resultW <= 32'b0;
            o_read_dataW  <= 32'b0;
            o_rdW         <= 5'b0;
            o_pc_plus4W   <= 32'b0;
            o_reg_wrW     <= 1'b0;
            o_result_srcW <= 2'b0;
        end
        else begin
            o_alu_resultW <= i_alu_resultM;
            o_read_dataW  <= i_read_dataM;
            o_rdW         <= i_rdM;
            o_pc_plus4W   <= i_pc_plus4M;
            o_reg_wrW     <= i_reg_wrM;
            o_result_srcW <= i_result_srcM;
        end
    end


endmodule