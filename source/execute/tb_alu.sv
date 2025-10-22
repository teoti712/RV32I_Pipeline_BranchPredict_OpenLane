`timescale 1ns/1ps

module tb_alu_slt_sltu();

    // DUT signals
    logic [31:0] i_rs1_data, i_rs2_data;
    logic [3:0]  i_alu_sel;
    logic [31:0] o_alu_resultE;
    logic        o_jump;

    // Instantiate DUT
    alu dut (
        .i_rs1_data(i_rs1_data),
        .i_rs2_data(i_rs2_data),
        .i_alu_sel(i_alu_sel),
        .o_alu_resultE(o_alu_resultE),
        .o_jump(o_jump)
    );

    // Localparam for ALU operations
    localparam [3:0] FUNC_SLT  = 4'b0111;
    localparam [3:0] FUNC_SLTU = 4'b1000;

    // Task to run one test
    task run_test(input [31:0] rs1, rs2, input [3:0] sel, string name);
        begin
            i_rs1_data = rs1;
            i_rs2_data = rs2;
            i_alu_sel  = sel;
            #1; // allow combinational settle

            $display("[%s] rs1 = %0d (0x%h), rs2 = %0d (0x%h) => result = %0d (0x%h)", 
                name, rs1, rs1, rs2, rs2, o_alu_resultE, o_alu_resultE);
        end
    endtask

    initial begin
        $display("==== TEST SLT & SLTU ====");

        // ----------- Test SLT (signed compare) -----------
        run_test(32'sd5,   32'sd10, FUNC_SLT,  "SLT: 5 < 10 -> expect 1");
        run_test(32'sd10,  32'sd5,  FUNC_SLT,  "SLT: 10 < 5 -> expect 0");
        run_test(-32'sd3,  32'sd2,  FUNC_SLT,  "SLT: -3 < 2 -> expect 1");
        run_test(-32'sd5, -32'sd5,  FUNC_SLT,  "SLT: -5 < -5 -> expect 0");

        // ----------- Test SLTU (unsigned compare) -----------
        run_test(32'd5,   32'd10, FUNC_SLTU, "SLTU: 5 < 10 -> expect 1");
        run_test(32'd10,  32'd5,  FUNC_SLTU, "SLTU: 10 < 5 -> expect 0");
        run_test(32'hFFFF_FFFF, 32'd0, FUNC_SLTU, "SLTU: 0xFFFFFFFF < 0 -> expect 0");
        run_test(32'd0, 32'hFFFF_FFFF, FUNC_SLTU, "SLTU: 0 < 0xFFFFFFFF -> expect 1");

        $display("==== END TEST ====");
        #5;
        $finish;
    end

endmodule
