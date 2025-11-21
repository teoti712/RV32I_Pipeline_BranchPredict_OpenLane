`timescale 1ns/1ps

module tb_pipeline_seq6;

    // Top I/O
    logic i_clk;
    logic i_rst_n;
    logic [31:0] i_io_sw;
    logic [3:0]  i_io_btn;
    logic [31:0] o_ld_data;
    logic [31:0] o_io_ledr;
    logic [31:0] o_io_ledg;
    logic [6:0]  o_io_hex0;
    logic [6:0]  o_io_hex1;
    logic [6:0]  o_io_hex2;
    logic [6:0]  o_io_hex3;
    logic [6:0]  o_io_hex4;
    logic [6:0]  o_io_hex5;
    logic [6:0]  o_io_hex6;
    logic [6:0]  o_io_hex7;
    logic [31:0] o_io_lcd;

    // instantiate DUT (adjust instance name if different)
    pipeline uut (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_io_sw  (i_io_sw),
        .i_io_btn (i_io_btn),
        .o_ld_data(o_ld_data),
        .o_io_ledr(o_io_ledr),
        .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0),
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_io_lcd (o_io_lcd)
    );

    // clock
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10 ns period
    end

    // program instructions
    localparam int N_INS = 6;
    logic [31:0] inst_mem [0:N_INS-1];

    // TB model regfile and expected values
    logic [31:0] tb_regs      [0:31];
    logic [31:0] expected_regs[0:31];

    // control vars
    integer i;
    integer cycles_after_last_inst;
    integer errs;

    // initialize program and expected
    initial begin
        // instruction hex sequence you provided
        inst_mem[0] = 32'h00500093; // addi x1, x0, 5
        inst_mem[1] = 32'h00700113; // addi x2, x0, 7
        inst_mem[2] = 32'h002081B3; // add  x3, x1, x2
        inst_mem[3] = 32'h00218233; // add  x4, x3, x2
        inst_mem[4] = 32'h002202B3; // add  x5, x4, x2
        inst_mem[5] = 32'h00228333; // add  x6, x5, x2

        // clear tb registers
        for (i = 0; i < 32; i = i + 1) begin
            tb_regs[i] = 32'd0;
            expected_regs[i] = 32'd0;
        end

        // expected results computed
        expected_regs[1] = 32'd5;   // x1 = 5
        expected_regs[2] = 32'd7;   // x2 = 7
        expected_regs[3] = expected_regs[1] + expected_regs[2]; // 12
        expected_regs[4] = expected_regs[3] + expected_regs[2]; // 19
        expected_regs[5] = expected_regs[4] + expected_regs[2]; // 26
        expected_regs[6] = expected_regs[5] + expected_regs[2]; // 33

        cycles_after_last_inst = 14; // allow pipeline to drain
    end

    // main stimulus
    initial begin
        // initialize IOs
        i_io_sw  = 32'b0;
        i_io_btn = 4'b0;

        // waveform dump
        $dumpfile("tb_pipeline_seq6.vcd");
        $dumpvars(0, tb_pipeline_seq6);

        // reset
        i_rst_n = 0;
        repeat (5) @(posedge i_clk);
        i_rst_n = 1;
        @(posedge i_clk);

        // feed instructions one per cycle by forcing fetch output
        for (i = 0; i < N_INS; i = i + 1) begin
            force uut.w_instF = inst_mem[i];
            $display("[%0t] Driving inst[%0d] = 0x%08h", $time, i, inst_mem[i]);
            @(posedge i_clk);
        end

        // stop forcing fetch output (IMEM idle)
        release uut.w_instF;

        // allow pipeline to drain
        repeat (cycles_after_last_inst) @(posedge i_clk);
        // extra cycles
        repeat (2) @(posedge i_clk);

        // compare results x1..x6
        $display("\n=== Final comparison (x1..x6) ===");
        errs = 0;
        for (i = 1; i <= 6; i = i + 1) begin
            $display("x%0d : expected = 0x%08h (%0d), tb_model = 0x%08h (%0d)",
                     i, expected_regs[i], expected_regs[i], tb_regs[i], tb_regs[i]);
            if (tb_regs[i] !== expected_regs[i]) errs = errs + 1;
        end

        if (errs == 0) $display("TEST PASSED: All registers match expected values.");
        else              $display("TEST FAILED: %0d mismatches.", errs);

        $display("Simulation finished.");
        $finish;
    end

    // monitor write-back stage and update TB model regfile
    // sampling uut.w_reg_wrW, uut.w_rdW, uut.w_resultW
    initial begin
        // wait for reset
        wait (i_rst_n == 1);
        @(posedge i_clk);

        forever begin
            @(posedge i_clk);
            // If DUT signals are named differently, adjust hierarchical path accordingly
            if (uut.w_reg_wrW) begin
                tb_regs[uut.w_rdW] = uut.w_resultW;
                $display("[%0t] Writeback: rd=x%0d, data=0x%08h", $time, uut.w_rdW, uut.w_resultW);
            end
        end
    end

endmodule
