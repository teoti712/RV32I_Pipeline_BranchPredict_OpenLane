module pipeline_phs3(

    //signal ex/mem register
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic [4:0]  i_rdE,
    input  logic [31:0] i_pc_plus4E,
    input  logic        i_reg_wrE,
    input  logic [1:0]  i_result_srcE,
    input  logic        i_mem_wrE,
    input  logic [31:0] i_wr_dataE,
    input  logic [31:0] i_alu_resultE,
    input  logic [31:0] i_instE, // contain func3
    
    output logic [4:0]  o_rdM,
    output logic [31:0] o_pc_plus4M,
    output logic        o_reg_wrM,
    output logic [1:0]  o_result_srcM, 
    output logic [31:0] o_alu_resultM,



    // signal lsu
    input logic [31:0] i_io_sw,
    input logic [3:0] i_io_btn,
    // Outputs:
    output logic [31:0] o_ld_data,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0] o_io_hex0,
    output logic [6:0] o_io_hex1,
    output logic [6:0] o_io_hex2,
    output logic [6:0] o_io_hex3,
    output logic [6:0] o_io_hex4,
    output logic [6:0] o_io_hex5,
    output logic [6:0] o_io_hex6,
    output logic [6:0] o_io_hex7,
    output logic [31:0] o_io_lcd

);

    // wire signal ex/mem register
    logic [31:0] w_wr_dataM;
    logic [31:0] w_alu_resultM;
    logic        w_mem_wrM;
    logic [31:0] w_instM;
 

EXMEM_register EXMEM_register_inst (

    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rdE(i_rdE),
    .i_pc_plus4E(i_pc_plus4E),
    .i_reg_wrE(i_reg_wrE),
    .i_result_srcE(i_result_srcE),
    .i_mem_wrE(i_mem_wrE),
    .i_wr_dataE(i_wr_dataE),
    .i_alu_resultE(i_alu_resultE),
    .i_instE(i_instE),

    .o_rdM(o_rdM),
    .o_pc_plus4M(o_pc_plus4M),
    .o_reg_wrM(o_reg_wrM),
    .o_result_srcM(o_result_srcM),
    .o_mem_wrM(w_mem_wrM),
    .o_wr_dataM(w_wr_dataM),
    .o_alu_resultM(w_alu_resultM),
    .o_instM(w_instM)
);


lsu LSU_inst (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_lsu_op   (w_instM[14:12]),
    .i_lsu_addr (w_alu_resultM),
    .i_st_data  (w_wr_dataM),
    .i_lsu_wren (w_mem_wrM),
    .i_io_sw    (i_io_sw),
    .i_io_btn   (i_io_btn),
    .o_ld_data  (o_ld_data), // ld_data or o_ld_data
    .o_io_ledr  (o_io_ledr),
    .o_io_ledg  (o_io_ledg),
    .o_io_hex0  (o_io_hex0),
    .o_io_hex1  (o_io_hex1),
    .o_io_hex2  (o_io_hex2),
    .o_io_hex3  (o_io_hex3),
    .o_io_hex4  (o_io_hex4),
    .o_io_hex5  (o_io_hex5),
    .o_io_hex6  (o_io_hex6),
    .o_io_hex7  (o_io_hex7),
    .o_io_lcd   (o_io_lcd)
);

    assign o_alu_resultM = w_alu_resultM;




endmodule