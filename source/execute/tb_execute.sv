`timescale 1ns/1ps

module tb_execute;

    // ===== DUT Inputs =====
    logic [31:0] i_rs1_dataE;
    logic [31:0] i_rs2_dataE;
    logic [31:0] i_alu_resultM;
    logic [31:0] i_resultW;
    logic [31:0] i_pcE;
    logic [31:0] i_immExtE;

    logic [1:0]  i_forwardAE;
    logic [1:0]  i_forwardBE;
    logic        i_alu_srcAE;
    logic        i_alu_srcBE;
    logic [3:0]  i_alu_ctrlE;

    // ===== DUT Outputs =====
    logic        o_jump_enE;
    logic [31:0] o_wr_dataE;
    logic [31:0] o_alu_resultE;
    logic [31:0] o_pc_targetE;

    // ===== Instantiate DUT =====
    execute dut (
        .i_rs1_dataE(i_rs1_dataE),
        .i_rs2_dataE(i_rs2_dataE),
        .i_alu_resultM(i_alu_resultM),
        .i_resultW(i_resultW),
        .i_pcE(i_pcE),
        .i_immExtE(i_immExtE),
        .i_forwardAE(i_forwardAE),
        .i_forwardBE(i_forwardBE),
        .i_alu_srcAE(i_alu_srcAE),
        .i_alu_srcBE(i_alu_srcBE),
        .i_alu_ctrlE(i_alu_ctrlE),
        .o_jump_enE(o_jump_enE),
        .o_wr_dataE(o_wr_dataE),
        .o_alu_resultE(o_alu_resultE),
        .o_pc_targetE(o_pc_targetE)
    );

    // ===== Test Stimulus =====
    initial begin
        $display("==============================================");
        $display("🚀 TESTBENCH for EXECUTE MODULE START");
        $display("==============================================");

        // Initialize constant input data
        i_rs1_dataE   = 32'h00000008;
        i_rs2_dataE   = 32'h00000003;
        i_alu_resultM = 32'h00000005;
        i_resultW     = 32'h00000009;
        i_pcE         = 32'h00000004;
        i_immExtE     = 32'h00000010;

        // Test all combinations
        for (int fA = 0; fA < 3; fA++) begin
            for (int fB = 0; fB < 3; fB++) begin
                for (int srcA = 0; srcA < 2; srcA++) begin
                    for (int srcB = 0; srcB < 2; srcB++) begin
                        for (int alu_sel = 0; alu_sel < 11; alu_sel++) begin
                            i_forwardAE = fA;
                            i_forwardBE = fB;
                            i_alu_srcAE = srcA;
                            i_alu_srcBE = srcB;
                            i_alu_ctrlE = alu_sel;
                            #5;
                            $display("FA=%0d FB=%0d srcA=%0b srcB=%0b alu_ctrl=%0d | ALU_Result=0x%08h | Jump=%0b | PC_Target=0x%08h", 
                                i_forwardAE, i_forwardBE, i_alu_srcAE, i_alu_srcBE, i_alu_ctrlE,
                                o_alu_resultE, o_jump_enE, o_pc_targetE);
                        end
                    end
                end
            end
        end

        $display("==============================================");
        $display("✅ TEST COMPLETED");
        $display("==============================================");
        $finish;
    end

endmodule
