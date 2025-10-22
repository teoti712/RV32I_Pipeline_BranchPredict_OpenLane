module IDEX_register (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_flushE,
    input  logic [4:0]  i_rs1D,
    input  logic [4:0]  i_rs2D,
    input  logic [4:0]  i_rdD,
    input  logic [31:0] i_pcD,
    input  logic [31:0] i_pc_plus4D,
    input  logic [31:0] i_rs1_dataD,
    input  logic [31:0] i_rs2_dataD,
    input  logic [31:0] i_immExtD,
    input  logic        reg_wrD,
    input  logic [1:0]  result_srcD,
    input  logic        mem_wrD,
    input  logic        jumpD,
    input  logic        branchD,
    input  logic [3:0]  alu_ctrlD,
    input  logic        alu_srcAD,
    input  logic        alu_srcBD,

    output logic [4:0]  o_rs1E,
    output logic [4:0]  o_rs2E,
    output logic [4:0]  o_rdE,
    output logic [31:0] o_pcE,
    output logic [31:0] o_pc_plus4E,
    output logic [31:0] o_rs1_dataE,
    output logic [31:0] o_rs2_dataE,
    output logic [31:0] o_immExtE,
    output logic        reg_wrE,
    output logic [1:0]  result_srcE,
    output logic        mem_wrE,
    output logic        jumpE,
    output logic        branchE,
    output logic [3:0]  alu_ctrlE,
    output logic        alu_srcAE,
    output logic        alu_srcBE
);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n || i_flushE) begin
            o_rs1E       <= 5'd0;
            o_rs2E       <= 5'd0;
            o_rdE        <= 5'd0;
            o_pcE        <= 32'd0;
            o_pc_plus4E  <= 32'd0;
            o_rs1_dataE  <= 32'd0;
            o_rs2_dataE  <= 32'd0;
            o_immExtE    <= 32'd0;
            reg_wrE      <= 1'b0;
            result_srcE  <= 2'b00;
            mem_wrE      <= 1'b0;
            jumpE        <= 1'b0;
            branchE      <= 1'b0;
            alu_ctrlE    <= 4'd0;
            alu_srcAE    <= 1'b0;
            alu_srcBE    <= 1'b0;
        end else begin
            o_rs1E       <= i_rs1D;
            o_rs2E       <= i_rs2D;
            o_rdE        <= i_rdD;
            o_pcE        <= i_pcD;
            o_pc_plus4E  <= i_pc_plus4D;
            o_rs1_dataE  <= i_rs1_dataD;
            o_rs2_dataE  <= i_rs2_dataD;
            o_immExtE    <= i_immExtD;
            reg_wrE      <= reg_wrD;
            result_srcE  <= result_srcD;
            mem_wrE      <= mem_wrD;
            jumpE        <= jumpD;
            branchE      <= branchD;
            alu_ctrlE    <= alu_ctrlD;
            alu_srcAE    <= alu_srcAD;
            alu_srcBE    <= alu_srcBD;
        end
    end

endmodule
