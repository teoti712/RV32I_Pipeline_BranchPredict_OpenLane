module execute (

    input  logic [31:0] i_rs1_dataE,
    input  logic [31:0] i_rs2_dataE,
    input  logic [31:0] i_alu_resultM,
    input  logic [31:0] i_resultW,
    input  logic [31:0] i_pcE,
    input  logic [31:0] i_immExtE,

    input  logic [1:0]  i_forwardAE,
    input  logic [1:0]  i_forwardBE,
    input  logic        i_alu_srcAE,
    input  logic        i_alu_srcBE,
    input  logic [3:0]  i_alu_ctrlE,

    output logic        o_jump_enE,
    output logic [31:0] o_wr_dataE,
    output logic [31:0] o_alu_resultE,
    output logic [31:0] o_pc_targetE);

    logic [31:0] w_mux_alu_srcAE;
    logic [31:0] w_mux_alu_srcBE;
    logic [31:0] w_srcAE;
    logic [31:0] w_srcBE;



    mux_forward mux_forwardA (
        .i_sel(i_forwardAE),
        .i_A(i_rs1_dataE),
        .i_B(i_resultW),
        .i_C(i_alu_resultM),
        .o_mux(w_mux_alu_srcAE)
    );

    mux_forward mux_forwardB (
        .i_sel(i_forwardBE),
        .i_A(i_rs2_dataE),
        .i_B(i_resultW),
        .i_C(i_alu_resultM),
        .o_mux(w_mux_alu_srcBE)
    );


    mux_alu_src mux_alu_srcAE (
        .i_sel(i_alu_srcAE),
        .i_A(w_mux_alu_srcAE),
        .i_B(i_pcE),
        .o_mux(w_srcAE)
    );

    mux_alu_src mux_alu_srcBE (
        .i_sel(i_alu_srcBE),
        .i_A(w_mux_alu_srcBE),
        .i_B(i_immExtE),
        .o_mux(w_srcBE)
    );


    add add_inst (
        .i_pcE(i_pcE),
        .i_immExtE(i_immExtE),
        .o_pc_targetE(o_pc_targetE)
    );

    alu alu_inst (
        .i_rs1_data(w_srcAE),
        .i_rs2_data(w_srcBE),
        .i_alu_sel(i_alu_ctrlE),
        .o_alu_resultE(o_alu_resultE),
        .o_jump(o_jump_enE)
    );

    assign o_wr_dataE = w_srcBE;


endmodule
