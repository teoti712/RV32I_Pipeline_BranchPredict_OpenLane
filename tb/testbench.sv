`timescale 1ns/1ps

module testbench;

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

    // instantiate DUT (assumes top-level module named 'pipeline')
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

    // clock generator
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10 ns period
    end

    // Program storage
    localparam int MAX_INS = 32;
    logic [31:0] inst_mem [0:MAX_INS-1];
    int N_INS;

    // TB regfile model and expected
    logic [31:0] tb_regs[0:31];
    logic [31:0] expected_regs[0:31];

    integer i;
    integer cycles_after_last_inst;
    integer errs;

    // Read testcase from +test=... (default "add")
    string testname;
    initial begin
        if (!$value$plusargs("test=%s", testname)) testname = "add";
        $display("=== Testbench: selected testcase = '%s' ===", testname);
    end

    // Load programs per testcase
    initial begin
        // init
        for (i = 0; i < MAX_INS; i = i + 1) inst_mem[i] = 32'h00000013; // nop
        for (i = 0; i < 32; i = i + 1) begin
            tb_regs[i] = 0;
            expected_regs[i] = 0;
        end

        // default values
        N_INS = 0;
        cycles_after_last_inst = 16;

        // Testcases
        if (testname == "add") begin
            N_INS = 6;
            inst_mem[0] = 32'h00500093; // addi x1, x0, 5
            inst_mem[1] = 32'h00700113; // addi x2, x0, 7
            inst_mem[2] = 32'h002081B3; // add  x3, x1, x2
            inst_mem[3] = 32'h00218233; // add  x4, x3, x2
            inst_mem[4] = 32'h002202B3; // add  x5, x4, x2
            inst_mem[5] = 32'h00228333; // add  x6, x5, x2
            expected_regs[1] = 5; expected_regs[2] = 7;
            expected_regs[3] = 12; expected_regs[4] = 19; expected_regs[5] = 26; expected_regs[6] = 33;
            cycles_after_last_inst = 14;
        end
        else if (testname == "sub") begin
            N_INS = 6;
            inst_mem[0] = 32'h00500093; // addi x1, x0, 5
            inst_mem[1] = 32'h00700113; // addi x2, x0, 7
            inst_mem[2] = 32'h402081B3; // sub  x3, x1, x2 -> 5 - 7 = -2
            inst_mem[3] = 32'h40118233; // sub  x4, x3, x1 -> -2 - 5 = -7
            inst_mem[4] = 32'h402202B3; // sub  x5, x4, x2 -> -7 - 7 = -14
            inst_mem[5] = 32'h00228333; // add  x6, x5, x2 -> -14 + 7 = -7
            expected_regs[1] = 5; expected_regs[2] = 7;
            expected_regs[3] = 32'(-2); expected_regs[4] = 32'(-7);
            expected_regs[5] = 32'(-14); expected_regs[6] = 32'(-7);
            cycles_after_last_inst = 16;
        end
        else if (testname == "logic") begin
            N_INS = 6;
            inst_mem[0] = 32'h00500093; // addi x1, x0, 5
            inst_mem[1] = 32'h00700113; // addi x2, x0, 7
            inst_mem[2] = 32'h0020F1B3; // and x3, x1, x2
            inst_mem[3] = 32'h0020E233; // or  x4, x1, x2
            inst_mem[4] = 32'h0020C2B3; // xor x5, x1, x2
            inst_mem[5] = 32'hFFF0C313; // xori x6, x1, -1  (not)
            expected_regs[1] = 5; expected_regs[2] = 7;
            expected_regs[3] = 5; expected_regs[4] = 7; expected_regs[5] = 2; expected_regs[6] = 32'hFFFFFFFA;
            cycles_after_last_inst = 12;
        end
        else if (testname == "shift") begin
            N_INS = 8;
            inst_mem[0] = 32'h01000093; // addi x1, x0, 16
	    inst_mem[1] = 32'h00100113; // addi x2, x0, 1
            inst_mem[2] = 32'h002091B3; // sll x3, x1, x2
            inst_mem[3] = 32'h0020D233; // srl x4, x1, x2
            inst_mem[4] = 32'h4020D2B3; // sra x5, x1, x2
            inst_mem[5] = 32'hFF000393; // addi x7, x0, -16
            inst_mem[6] = 32'h4023D333; // sra x6, x7, x2
            expected_regs[1] = 16; expected_regs[2] = 1;
            expected_regs[3] = 32; expected_regs[4] = 8; expected_regs[5] = 8; expected_regs[6] = 32'hFFFFFFF8;
            cycles_after_last_inst = 18;
        end
        else begin
            // fallback to add if unknown
            $display("Unknown test '%s' - falling back to add", testname);
            N_INS = 6;
            inst_mem[0] = 32'h00500093;
            inst_mem[1] = 32'h00700113;
            inst_mem[2] = 32'h002081B3;
            inst_mem[3] = 32'h00218233;
            inst_mem[4] = 32'h002202B3;
            inst_mem[5] = 32'h00228333;
            expected_regs[1] = 5; expected_regs[2] = 7;
            expected_regs[3] = 12; expected_regs[4] = 19; expected_regs[5] = 26; expected_regs[6] = 33;
            cycles_after_last_inst = 14;
        end
    end

    // main stimulus: safe feed and run
    initial begin
        i_io_sw  = 0;
        i_io_btn = 0;

        // waveform
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);

        // reset
        i_rst_n = 0;
        repeat (5) @(posedge i_clk);
        i_rst_n = 1;
        @(posedge i_clk);

        // Feed instructions safely:
        // force fetch output, wait two cycles for IF->ID transfer, then release
        for (i = 0; i < N_INS; i = i + 1) begin
            force uut.w_instF = inst_mem[i];
            @(posedge i_clk); // IF stage samples
            @(posedge i_clk); // IFID -> ID updated
            release uut.w_instF;
            $display("[%0t] fed inst[%0d] = 0x%08h", $time, i, inst_mem[i]);
        end

        // drain pipeline
        repeat (cycles_after_last_inst) @(posedge i_clk);
        // extra margin
        repeat (2) @(posedge i_clk);

        // check results (x1..x6)
        $display("\n=== Final comparison ===");
        errs = 0;
        for (i = 1; i <= 6; i = i + 1) begin
            $display("x%0d : expected = 0x%08h (%0d), tb_model = 0x%08h (%0d)",
                     i, expected_regs[i], expected_regs[i], tb_regs[i], tb_regs[i]);
            if (tb_regs[i] !== expected_regs[i]) errs = errs + 1;
        end

        if (errs == 0) $display(">>> TEST PASSED: %s <<<", testname);
        else            $display(">>> TEST FAILED: %0d mismatches <<<", errs);

        $finish;
    end

    // monitor write-back stage and update TB regfile model
    initial begin
        wait (i_rst_n == 1);
        @(posedge i_clk);
        forever begin
            @(posedge i_clk);
            if (uut.w_reg_wrW && uut.w_rdW != 0) begin
                tb_regs[uut.w_rdW] = uut.w_resultW;
                $display("[%0t] WB: x%0d <= 0x%08h", $time, uut.w_rdW, uut.w_resultW);
            end
        end
    end

endmodule

