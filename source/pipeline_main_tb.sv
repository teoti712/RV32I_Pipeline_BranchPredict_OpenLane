`timescale 1ns/1ps

module tb_pipeline;

    // DUT ports
    logic i_clk;
    logic i_rst_n;
    logic [31:0] i_io_sw;
    logic [3:0]  i_io_btn;
    logic [31:0] o_ld_data;
    logic [31:0] o_io_ledr;
    logic [31:0] o_io_ledg;
    logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3;
    logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7;
    logic [31:0] o_io_lcd;

    // instantiate DUT
    pipeline uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_io_sw(i_io_sw),
        .i_io_btn(i_io_btn),
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
        .o_io_lcd(o_io_lcd)
    );

    // clock
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns period
    end

    // create instr.mem (readable by fetch_stage via $readmemh)
    initial begin
        integer f;
        f = $fopen("instr.mem", "w");
        $fdisplay(f, "00500093"); // addi x1,x0,5
        $fdisplay(f, "00300113"); // addi x2,x0,3
        $fdisplay(f, "002081b3"); // add x3,x1,x2
        $fdisplay(f, "40208233"); // sub x4,x1,x2
        $fdisplay(f, "0020f2b3"); // and x5,x1,x2
        $fdisplay(f, "0020e333"); // or  x6,x1,x2
        $fdisplay(f, "002093b3"); // sll x7,x1,x2
        $fdisplay(f, "0020d433"); // srl x8,x1,x2
        $fdisplay(f, "0020a4b3"); // slt x9,x1,x2
        $fdisplay(f, "00000013");
        $fdisplay(f, "00000013");
        $fdisplay(f, "00000013");
        $fdisplay(f, "00000013");
        $fclose(f);
        $display("instr.mem created.");
    end

    // reset + inputs
    initial begin
        i_io_sw = 32'h0;
        i_io_btn = 4'h0;
        i_rst_n = 0;
        repeat (10) @(posedge i_clk);
        i_rst_n = 1;
    end

    // expected list (rd, value) - declared at module scope
    typedef struct packed { logic [4:0] rd; logic [31:0] val; } exp_t;
    localparam int EXPECTED_N = 9;
    exp_t expected[0:EXPECTED_N-1];

    // procedural variables declared at module scope (avoid declaring inside initial)
    integer idx;
    integer total_checks;
    integer nfail;
    integer cycle_count;
    logic [4:0] actual_rd;
    logic [31:0] actual_val;
    logic [4:0] exp_rd;
    logic [31:0] exp_val;
// chèn vào tb_pipeline (đã có uut)
always @(posedge i_clk) begin
    // print khi EX stage đang xử lý (kiểm lệnh sub/and)
    if (uut.w_instE == 32'h40208233) begin // nếu mã sub x4,x1,x2 (nếu đúng)
        $display("CYCLE %0t: EX=sub: rs1E=%0d rs2E=%0d rs1_dataE=%0h rs2_dataE=%0h forwardA=%0b forwardB=%0b",
                 $time, uut.w_rs1E, uut.w_rs2E, uut.w_rs1_dataE, uut.w_rs2_dataE, uut.w_forwardAE, uut.w_forwardBE);
        $display("  alu_ctrl=%0h alu_inA=%0h alu_inB=%0h", uut.w_alu_ctrlE, /*print ALU inputs if available*/ uut.w_alu_resultE /*temp*/);
    end
    if (uut.w_instE == 32'h0020f2b3) begin // and x5,x1,x2
        $display("CYCLE %0t: EX=and: rs1E=%0d rs2E=%0d rs1_dataE=%0h rs2_dataE=%0h forwardA=%0b forwardB=%0b",
                 $time, uut.w_rs1E, uut.w_rs2E, uut.w_rs1_dataE, uut.w_rs2_dataE, uut.w_forwardAE, uut.w_forwardBE);
    end
end

    initial begin
        // fill expected array
        expected[0] = '{5'd1, 32'd5};   // addi x1 = 5
        expected[1] = '{5'd2, 32'd3};   // addi x2 = 3
        expected[2] = '{5'd3, 32'd8};   // add x3 = 8
        expected[3] = '{5'd4, 32'd2};   // sub x4 = 2
        expected[4] = '{5'd5, 32'd1};   // and x5 = 1
        expected[5] = '{5'd6, 32'd7};   // or  x6 = 7
        expected[6] = '{5'd7, 32'd40};  // sll x7 = 40
        expected[7] = '{5'd8, 32'd0};   // srl x8 = 0
        expected[8] = '{5'd9, 32'd0};   // slt x9 = 0

        // init counters
        idx = 0;
        total_checks = 0;
        nfail = 0;
        cycle_count = 0;

        // wait for reset release
        @(posedge i_clk);
        while (i_rst_n == 0) @(posedge i_clk);

        // run until we see all expected writebacks or timeout
        while (idx < EXPECTED_N) begin
            @(posedge i_clk);
            cycle_count = cycle_count + 1;

            // Check DUT internal write-back signals (hierarchical access)
            // Note: adjust names if your pipeline instance uses different internal signal names.
            if (uut.w_reg_wrW && (uut.w_rdW != 5'b0)) begin
                total_checks = total_checks + 1;

                // capture actual values
                actual_rd  = uut.w_rdW;
                actual_val = uut.w_resultW;

                exp_rd  = expected[idx].rd;
                exp_val = expected[idx].val;

                $display("WB #%0d: time=%0t rd=%00d val=0x%08h  (expected rd=%0d val=0x%08h)",
                         idx+1, $time, actual_rd, actual_val, exp_rd, exp_val);

                if ((actual_rd !== exp_rd) || (actual_val !== exp_val)) begin
                    $display("  >>> MISMATCH at WB #%0d: got (rd=%0d, 0x%08h) expected (rd=%0d, 0x%08h)",
                             idx+1, actual_rd, actual_val, exp_rd, exp_val);
                    nfail = nfail + 1;
                end else begin
                    $display("  PASS");
                end
                idx = idx + 1;
            end

            if (cycle_count > 2000) begin
                $display("Timeout waiting for writebacks");
                break;
            end
        end // while

        // summary
        #1;
        $display("=== TEST SUMMARY ===");
        $display("Total checks : %0d", total_checks);
        $display("Failures     : %0d", nfail);
        if (nfail == 0 && idx == EXPECTED_N) $display("ALL PASSED");
        else $display("SOME CHECKS FAILED or MISSING");
        $finish;
    end

endmodule
