module EXMEM_register(

    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [4:0]  i_rdE,
    input  logic [31:0] i_pc_plus4E,
    input  logic        i_reg_wrE,
    input  logic [1:0]  i_result_srcE,
    input  logic        i_mem_wrE,
    input  logic [31:0] i_wr_dataE,
    input  logic [31:0] i_alu_resultE,
    input  logic [31:0] i_instE,

    output logic [4:0]  o_rdM,
    output logic [31:0] o_pc_plus4M,
    output logic        o_reg_wrM,
    output logic [1:0]  o_result_srcM,
    output logic        o_mem_wrM,
    output logic [31:0] o_wr_dataM,
    output logic [31:0] o_alu_resultM,
    output logic [31:0] o_instM
);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_rdM          <= 5'b0;
            o_pc_plus4M    <= 32'b0;
            o_reg_wrM      <= 1'b0;
            o_result_srcM  <= 2'b0;
            o_mem_wrM      <= 1'b0;
            o_wr_dataM     <= 32'b0;
            o_alu_resultM  <= 32'b0;
            o_instM        <= 32'b0;
        end
        else begin
            o_rdM          <= i_rdE;
            o_pc_plus4M    <= i_pc_plus4E;
            o_reg_wrM      <= i_reg_wrE;
            o_result_srcM  <= i_result_srcE;
            o_mem_wrM      <= i_mem_wrE;
            o_wr_dataM     <= i_wr_dataE;
            o_alu_resultM  <= i_alu_resultE;
            o_instM        <= i_instE;
        end
    end

endmodule
