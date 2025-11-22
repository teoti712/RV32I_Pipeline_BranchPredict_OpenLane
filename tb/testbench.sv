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
    integer last_reg_check; // <-- NEW: how many registers to compare at end

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
        last_reg_check = 6; // default: check x1..x6

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
            last_reg_check = 6;
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
            last_reg_check = 6;
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
            last_reg_check = 6;
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
            last_reg_check = 6;
        end
        else if (testname == "itype") begin
            // I-type instructions: ADDI, XORI, ANDI, ORI, SLTI, SLLI, SRLI
            N_INS = 8;

            // Machine codes (RV32I)
            inst_mem[0] = 32'h00a00093; // addi  x1, x0, 10
            inst_mem[1] = 32'h00300113; // addi  x2, x0, 3
            inst_mem[2] = 32'h0010c193; // xori  x3, x1, 1
            inst_mem[3] = 32'h0060f213; // andi  x4, x1, 6
            inst_mem[4] = 32'h00816293; // ori   x5, x2, 8
            inst_mem[5] = 32'h0140a313; // slti  x6, x1, 20
            inst_mem[6] = 32'h00109393; // slli  x7, x1, 1
            inst_mem[7] = 32'h0010d413; // srli  x8, x1, 1

            // expected results (kiểm tra cuối testbench)
            expected_regs[1] = 10;  // x1
            expected_regs[2] = 3;   // x2
            expected_regs[3] = 11;  // x3 = 10 ^ 1 = 11
            expected_regs[4] = 2;   // x4 = 10 & 6 = 2
            expected_regs[5] = 11;  // x5 = 3 | 8 = 11
            expected_regs[6] = 1;   // x6 = (10 < 20) ? 1 : 0
            expected_regs[7] = 20;  // x7 = 10 << 1 = 20
            expected_regs[8] = 5;   // x8 = 10 >> 1 = 5

            cycles_after_last_inst = 16; // drain cycles
            last_reg_check = 8; // check x1..x8
        end
	else if (testname == "rtype") begin
            // R-type instructions: add, sub, sll, slt, sltu, xor, srl, sra, or, and
            // Encoding is RV32I 32-bit hex
            N_INS = 12;

            // Setup: two addi to initialise registers x1=5, x2=7
            inst_mem[0]  = 32'h00500093; // addi x1, x0, 5
            inst_mem[1]  = 32'h00700113; // addi x2, x0, 7

            // R-type instructions (using x1 and x2 and chaining results)
            inst_mem[2]  = 32'h002081B3; // add  x3,  x1, x2   -> x3 = 5 + 7 = 12
            inst_mem[3]  = 32'h40118233; // sub  x4,  x3, x1   -> x4 = 12 - 5 = 7
            inst_mem[4]  = 32'h002212B3; // sll  x5,  x4, x2   -> x5 = x4 << (x2 & 0x1F) = 7 << 7 = 896
            inst_mem[5]  = 32'h0020A333; // slt  x6,  x1, x2   -> x6 = (5 < 7) ? 1 : 0 = 1
            inst_mem[6]  = 32'h0020B3B3; // sltu x7,  x1, x2   -> x7 = (5 < 7 unsigned) = 1
            inst_mem[7]  = 32'h0020C433; // xor  x8,  x1, x2   -> x8 = 5 ^ 7 = 2
            inst_mem[8]  = 32'h0020D4B3; // srl  x9,  x1, x2   -> x9 = logical >> by 7 = 0
            inst_mem[9]  = 32'h4020D533; // sra  x10, x1, x2   -> x10 = arithmetic >> by 7 = 0
            inst_mem[10] = 32'h0020E5B3; // or   x11, x1, x2   -> x11 = 5 | 7 = 7
            inst_mem[11] = 32'h0020F633; // and  x12, x1, x2   -> x12 = 5 & 7 = 5

            // expected results (will be compared at end of TB)
            expected_regs[1]  = 5;      // x1
            expected_regs[2]  = 7;      // x2
            expected_regs[3]  = 12;     // x3 = 5 + 7
            expected_regs[4]  = 7;      // x4 = 12 - 5
            expected_regs[5]  = 896;    // x5 = 7 << 7
            expected_regs[6]  = 1;      // x6 = slt
            expected_regs[7]  = 1;      // x7 = sltu
            expected_regs[8]  = 2;      // x8 = xor
            expected_regs[9]  = 0;      // x9 = logical right shift (5 >> 7)
            expected_regs[10] = 0;      // x10 = arithmetic right shift (5 >> 7)
            expected_regs[11] = 7;      // x11 = or
            expected_regs[12] = 5;      // x12 = and

            // pipeline drain cycles (reasonable margin)
            cycles_after_last_inst = 20;
            last_reg_check = 12; // check x1..x12
        end
        else if (testname == "mem") begin
            // Load/Store testcase (data memory base = 0x2000)
            // Program:
            // lui  x1, 0x2      ; x1 = 0x2000 (base address)
            // addi x2, x0, 5
            // addi x3, x0, 7
            // sw   x2, 0(x1)
            // sw   x3, 4(x1)
            // nop               ; give memory one cycle if needed
            // lw   x4, 0(x1)
            // lw   x5, 4(x1)
            // add  x6, x4, x5

            N_INS = 9;
	    inst_mem[0] = 32'h000020B7; // đúng -> lui x1,0x2  => x1 = 0x00002000
            inst_mem[1] = 32'h00500113; // addi  x2, x0, 5
            inst_mem[2] = 32'h00700193; // addi  x3, x0, 7
            inst_mem[3] = 32'h0020a023; // sw    x2, 0(x1)
            inst_mem[4] = 32'h0030a223; // sw    x3, 4(x1)
            inst_mem[5] = 32'h00000013; // nop (allow store to complete / pipeline bubble)
            inst_mem[6] = 32'h0000a203; // lw    x4, 0(x1)
            inst_mem[7] = 32'h0040a283; // lw    x5, 4(x1)
            inst_mem[8] = 32'h00520333; // add   x6, x4, x5

            // expected results
            expected_regs[1] = 32'h00002000; // x1 = base 0x2000
            expected_regs[2] = 5;
            expected_regs[3] = 7;
            expected_regs[4] = 5;   // loaded from mem[0x2000]
            expected_regs[5] = 7;   // loaded from mem[0x2004]
            expected_regs[6] = 12;  // 5 + 7

            cycles_after_last_inst = 22; // safe drain cycles
            last_reg_check = 6; // check x1..x6
        end
        else if (testname == "branch") begin
            // Branch testcase: beq + bne
            // Program (indexes show instruction index, PC = 4*index):
            // 0: addi x1, x0, 5      ; x1 = 5
            // 1: addi x2, x0, 5      ; x2 = 5
            // 2: beq  x1, x2, +8     ; taken -> jump to instr 4 (skip instr 3)
            // 3: addi x3, x0, 1      ; (should be skipped)
            // 4: addi x3, x0, 2      ; executed when branch taken -> x3 = 2
            // 5: bne  x1, x0, +8     ; taken (x1 != 0) -> jump to instr 7 (skip instr 6)
            // 6: addi x4, x0, 1      ; (should be skipped)
            // 7: addi x4, x0, 4      ; executed -> x4 = 4

            N_INS = 8;
            inst_mem[0] = 32'h00500093; // addi x1, x0, 5
            inst_mem[1] = 32'h00500113; // addi x2, x0, 5
            inst_mem[2] = 32'h0208463;  // beq  x1, x2, +8   (encoded = 0x0208463 -> 0x0208463)
            inst_mem[3] = 32'h00100193; // addi x3, x0, 1
            inst_mem[4] = 32'h00200193; // addi x3, x0, 2
            inst_mem[5] = 32'h00009463;  // bne  x1, x0, +8   (encoded = 0x00009463)
            inst_mem[6] = 32'h00100213; // addi x4, x0, 1
            inst_mem[7] = 32'h00400213; // addi x4, x0, 4

            // expected results after run
            expected_regs[1] = 5;
            expected_regs[2] = 5;
            expected_regs[3] = 2; // beq taken -> x3 set by instr 4
            expected_regs[4] = 4; // bne taken -> x4 set by instr 7

            cycles_after_last_inst = 20;
            last_reg_check = 4; // check x1..x4
        end
        else if (testname == "beq") begin
            //
            // x1 = 5
            // x2 = 5
            // beq x1, x2, +1 instruction  → sẽ nhảy qua lệnh addi x3,1
            // addi x3, x0, 1  (bị skip)
            // addi x3, x0, 2  (được thực thi)
            //
            N_INS = 5;
            inst_mem[0] = 32'h00500093; // addi x1, x0, 5
            inst_mem[1] = 32'h00500113; // addi x2, x0, 5
            inst_mem[2] = 32'h00208663; // beq  x1, x2, +4 bytes (1 instruction)
            inst_mem[3] = 32'h00100193; // addi x3, x0, 1 (skip)
            inst_mem[4] = 32'h00200193; // addi x3, x0, 2 (exec)

            expected_regs[1] = 5;
            expected_regs[2] = 5;
            expected_regs[3] = 2;  // branch taken → x3=2

            cycles_after_last_inst = 14;
            last_reg_check = 3;
        end
        else if (testname == "bne") begin
            //
            // x1 = 5
            // x2 = 7
            // bne x1, x2 → taken, skip addi x3,1
            //
            N_INS = 5;
            inst_mem[0] = 32'h00500093; // addi x1, x0, 5
            inst_mem[1] = 32'h00700113; // addi x2, x0, 7
            inst_mem[2] = 32'h00209663; // bne x1, x2, +4 bytes
            inst_mem[3] = 32'h00100193; // addi x3, x0, 1 (skip)
            inst_mem[4] = 32'h00300193; // addi x3, x0, 3 (exec)

            expected_regs[1] = 5;
            expected_regs[2] = 7;
            expected_regs[3] = 3;

            cycles_after_last_inst = 14;
            last_reg_check = 3;
        end
        else if (testname == "blt") begin
            //
            // x1 = -1
            // x2 = 1
            // blt x1, x2 → true, skip addi x3,1
            //
            N_INS = 5;
            inst_mem[0] = 32'hFFF00093; // addi x1, x0, -1
            inst_mem[1] = 32'h00100113; // addi x2, x0, 1
            inst_mem[2] = 32'h0020C663; // blt x1,x2,+4
            inst_mem[3] = 32'h00100193; // addi x3,1 (skip)
            inst_mem[4] = 32'h00400193; // addi x3,4 (exec)

            expected_regs[1] = 32'hFFFFFFFF;
            expected_regs[2] = 1;
            expected_regs[3] = 4;

            cycles_after_last_inst = 14;
            last_reg_check = 3;
        end
        else if (testname == "bge") begin
            //
            // x1 = 5
            // x2 = 5
            // bge x1,x2 → true
            //
            N_INS = 5;
            inst_mem[0] = 32'h00500093; // addi x1,5
            inst_mem[1] = 32'h00500113; // addi x2,5
            inst_mem[2] = 32'h0020E663; // bge x1,x2,+4
            inst_mem[3] = 32'h00100193; // addi x3,1 (skip)
            inst_mem[4] = 32'h00400193; // addi x3,4 (exec)

            expected_regs[1] = 5;
            expected_regs[2] = 5;
            expected_regs[3] = 4;

            cycles_after_last_inst = 14;
            last_reg_check = 3;
        end
        else if (testname == "bltu") begin
            //
            // x1 = 1
            // x2 = 2
            // bltu → taken
            //
            N_INS = 5;
            inst_mem[0] = 32'h00100093; // x1=1
            inst_mem[1] = 32'h00200113; // x2=2
            inst_mem[2] = 32'h0020D663; // bltu x1,x2,+4
            inst_mem[3] = 32'h00100193; // skip
            inst_mem[4] = 32'h00700193; // exec: x3=7

            expected_regs[1] = 1;
            expected_regs[2] = 2;
            expected_regs[3] = 7;

            cycles_after_last_inst = 14;
            last_reg_check = 3;
        end
        else if (testname == "bgeu") begin
            //
            // x1 = 2
            // x2 = 1
            // bgeu → taken
            //
            N_INS = 5;
            inst_mem[0] = 32'h00200093; // x1=2
            inst_mem[1] = 32'h00100113; // x2=1
            inst_mem[2] = 32'h0020F663; // bgeu x1,x2,+4
            inst_mem[3] = 32'h00100193; // skip
            inst_mem[4] = 32'h00900193; // exec: x3=9

            expected_regs[1] = 2;
            expected_regs[2] = 1;
            expected_regs[3] = 9;

            cycles_after_last_inst = 14;
            last_reg_check = 3;
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
            last_reg_check = 6;
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

        // check results (x1..xN)
        $display("\n=== Final comparison ===");
        errs = 0;
        if (last_reg_check <= 0) last_reg_check = 6; // safety fallback
        for (i = 1; i <= last_reg_check; i = i + 1) begin
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
