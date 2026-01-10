`timescale 1ns/1ps

module testbench;

    // ---------------- Clock / Reset ----------------
    logic clk;
    logic rst_n;
    logic [31:0] o_ld_data;
    logic [1:0]  o_result_srcW;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100 MHz
    end

    initial begin
        rst_n = 0;
        #50 rst_n = 1;
    end

    // ---------------- DUT ----------------
    pipeline dut (
        .i_clk   (clk),
        .i_rst_n (rst_n),
        .o_ld_data(o_ld_data),
        .o_result_srcW(o_result_srcW)
    );

    // ---------------- Branch statistics ----------------
    integer total_branch;
    integer correct_branch;
    integer wrong_branch;

    // ---------------- HALT latch ----------------
    logic halted;

    // ---------------- INIT ----------------
    initial begin
        total_branch   = 0;
        correct_branch = 0;
        wrong_branch   = 0;
        halted         = 0;
    end

    // ---------------- Branch monitor (EX stage) ----------------
    always @(posedge clk) begin
        if (!rst_n) begin
            total_branch   <= 0;
            correct_branch <= 0;
            wrong_branch   <= 0;
        end
        else if (!halted) begin
            // ✅ CHỈ ĐẾM CONDITIONAL BRANCH
            if (dut.w_branchE) begin
                total_branch <= total_branch + 1;

                if (dut.w_pred_takenE == dut.w_actual_takenE)
                    correct_branch <= correct_branch + 1;
                else
                    wrong_branch <= wrong_branch + 1;

                // ====== FULL G-SHARE DEBUG LOG ======

                $display(
                    "[BRANCH] PC=0x%08h | GHR=%b | IDX=%0d | CTR=%0d | pred=%0d actual=%0d %s",
                    dut.w_pcE,
                    dut.u_fetch_stage.u_branch_predict_unit.w_ghr,
                    dut.w_pht_idxE,
                    dut.u_fetch_stage.u_branch_predict_unit.u_pht.pht_array[dut.w_pht_idxE],
                    dut.w_pred_takenE,
                    dut.w_actual_takenE,
                    (dut.w_pred_takenE == dut.w_actual_takenE) ? "CORRECT" : "WRONG"
                );
            end
        end
    end

    // ---------------- HALT detect (x31 == 1) ----------------
    always @(posedge clk) begin
        if (rst_n && dut.u_decode_stage.reg_file_inst.regf[31] == 32'd1)
            halted <= 1'b1;
    end

    // ---------------- FINAL REPORT ----------------
    always @(posedge clk) begin
        if (halted) begin
            $display("\n====================================");
            $display(" G-SHARE EVALUATION ");
            $display("====================================");
            $display("Total branches   : %0d", total_branch);
            $display("Correct predict  : %0d", correct_branch);
            $display("Wrong predict    : %0d", wrong_branch);

            if (total_branch != 0)
                $display("Accuracy         : %0.2f %%", 
                    (correct_branch * 100.0) / total_branch
                );
            else
                $display("Accuracy         : N/A");

            $display("====================================");

            $display("====================================");
            $display(" REGISTER FILE DUMP ");
            $display("====================================");

            for (int i = 0; i < 32; i++) begin
                $display(
                    "x%0d = 0x%08h (%0d)",
                    i,
                    dut.u_decode_stage.reg_file_inst.regf[i],
                    dut.u_decode_stage.reg_file_inst.regf[i]
                );
            end

            $display("====================================");

            #20;
            $finish;
        end
    end

endmodule
