// ---------- Testbench ----------
module tb_fetch_stage;
    // clocks / signals
    logic clk;
    logic rst_n;
    logic stallF;
    logic pc_srcE;
    logic [31:0] pc_targetE;

    logic [31:0] instF;
    logic [31:0] pcF;
    logic [31:0] pc_plus4F;

    // instantiate DUT
    fetch_stage dut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_stallF(stallF),
        .i_pc_srcE(pc_srcE),
        .i_pc_targetE(pc_targetE),
        .o_instF(instF),
        .o_pcF(pcF),
        .o_pc_plus4F(pc_plus4F)
    );

    // clock: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // waveform
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fetch_stage);

        // init
        rst_n = 0;
        stallF = 0;
        pc_srcE = 0;
        pc_targetE = 32'd0;

        #12; // hold reset a little longer than one posedge
        rst_n = 1;
        $display("=== After reset released ===");
        #1;
        $display("%0t pcF=%h pc+4=%h inst=%h", $time, pcF, pc_plus4F, instF);

        // run a few cycles normal (pc should increment by +4 each cycle)
        repeat (4) begin
            #10;
            $display("time=%0t pcF=%h pc+4=%h inst=%h", $time, pcF, pc_plus4F, instF);
        end

        // Test: branch/jump taken -> set pc_srcE=1 and provide target
        $display("\n=== Test branch target (pc_srcE=1) ===");
        pc_targetE = 32'h0000_0008; // target address (word aligned)
        pc_srcE = 1;
        #10; // on next rising edge PC should update to target
        $display("time=%0t after branch pcF=%h pc+4=%h inst=%h (target=%h)", $time, pcF, pc_plus4F, instF, pc_targetE);

        // Clear branch select: next PC should be target + 4 (normal flow)
        pc_srcE = 0;
        #10;
        $display("time=%0t normal flow after branch pcF=%h pc+4=%h inst=%h", $time, pcF, pc_plus4F, instF);

        // Test stall: assert stall and try to change target; PC must hold
        $display("\n=== Test stall (PC should hold) ===");
        stallF = 1;
        pc_targetE = 32'h0000_00B0; // change target while stalling
        pc_srcE = 1; // try to force new target
        #20;
        $display("time=%0t during stall pcF=%h pc+4=%h inst=%h (should be unchanged)", $time, pcF, pc_plus4F, instF);

        // Release stall: PC should take new target (since pc_srcE is still 1)
        stallF = 0;
        #10;
        $display("time=%0t after stall release pcF=%h pc+4=%h inst=%h (target=%h)", $time, pcF, pc_plus4F, instF, pc_targetE);

        $display("\n=== Test finished ===");
        #10;
        $finish;
    end
endmodule