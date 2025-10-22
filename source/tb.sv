`timescale 1ns/1ps

module tb_pipeline;

    // Clock & reset
    logic i_clk;
    logic i_rst_n;

    // WB stage signals (writeback)
    logic         i_reg_wrW;
    logic [4:0]   i_rdW;
    logic [31:0]  i_resultW;

    // Hazard control signals
    logic         i_stallF;
    logic         i_stallD;
    logic         i_flushD;

    // Outputs from pipeline
    logic [4:0]   o_rs1D, o_rs2D, o_rdD;
    logic [31:0]  o_pcD, o_pc_plus4D;
    logic [31:0]  o_rs1_dataD, o_rs2_dataD;
    logic [31:0]  o_immExtD;
    logic         reg_wrD;     
    logic [1:0]   result_srcD; 
    logic         mem_wrD;     
    logic         jumpD;      
    logic         branchD;    
    logic [3:0]   alu_ctrlD;  
    logic         alu_srcAD;
    logic         alu_srcBD;

    // Instantiate DUT
    pipeline dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_reg_wrW(i_reg_wrW),
        .i_rdW(i_rdW),
        .i_resultW(i_resultW),
        .i_stallF(i_stallF),
        .i_stallD(i_stallD),
        .i_flushD(i_flushD),
        .o_rs1D(o_rs1D),
        .o_rs2D(o_rs2D),
        .o_rdD(o_rdD),
        .o_pcD(o_pcD),
        .o_pc_plus4D(o_pc_plus4D),
        .o_rs1_dataD(o_rs1_dataD),
        .o_rs2_dataD(o_rs2_dataD),
        .o_immExtD(o_immExtD),
        .reg_wrD(reg_wrD),
        .result_srcD(result_srcD),
        .mem_wrD(mem_wrD),
        .jumpD(jumpD),
        .branchD(branchD),
        .alu_ctrlD(alu_ctrlD),
        .alu_srcAD(alu_srcAD),
        .alu_srcBD(alu_srcBD)
    );

    // ===== CLOCK GENERATION =====
    initial i_clk = 0;
    always #5 i_clk = ~i_clk; // 10ns period

    // ===== STIMULUS =====
    initial begin
        $dumpfile("tb_pipeline.vcd");
        $dumpvars(0, tb_pipeline);

        // Default values
        i_rst_n    = 0;
        i_reg_wrW  = 0;
        i_rdW      = 5'd0;
        i_resultW  = 32'd0;
        i_stallF   = 0;
        i_stallD   = 0;
        i_flushD   = 0;

        // ===== RESET =====
        #10;
        $display("[%0t] Asserting reset...", $time);
        i_rst_n = 0;
        #20;
        i_rst_n = 1;
        $display("[%0t] Release reset", $time);

        // ===== NORMAL OPERATION =====
        repeat (5) @(posedge i_clk);
        $display("[%0t] Normal operation", $time);

        // ===== STALL FETCH =====
        i_stallF = 1;
        @(posedge i_clk);
        i_stallF = 0;
        $display("[%0t] Stall Fetch for 1 cycle", $time);

        // ===== STALL DECODE =====
        i_stallD = 1;
        @(posedge i_clk);
        i_stallD = 0;
        $display("[%0t] Stall Decode for 1 cycle", $time);

        // ===== FLUSH DECODE =====
        i_flushD = 1;
        @(posedge i_clk);
        i_flushD = 0;
        $display("[%0t] Flush Decode for 1 cycle", $time);

        // ===== WRITEBACK TEST =====
        repeat (2) @(posedge i_clk);
        i_reg_wrW = 1;
        i_rdW     = 5'd3;
        i_resultW = 32'hDEADBEEF;
        @(posedge i_clk);
        i_reg_wrW = 0;
        $display("[%0t] Writeback test done", $time);

        // ===== END SIMULATION =====
        repeat (10) @(posedge i_clk);
        $display("[%0t] Simulation finished", $time);
        $finish;
    end

    // ===== MONITOR OUTPUTS =====
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            $display("[%0t] PC=%h | PC+4=%h | rs1=%0d rs2=%0d rd=%0d | alu_ctrl=%0d | reg_wrD=%b | branch=%b jump=%b",
                     $time, o_pcD, o_pc_plus4D, o_rs1D, o_rs2D, o_rdD, alu_ctrlD, reg_wrD, branchD, jumpD);
        end
    end

endmodule
