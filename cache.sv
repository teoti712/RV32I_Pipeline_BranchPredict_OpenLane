`timescale 1ns/1ps

module testbench;

    // ---------------- Clock / Reset ----------------
    logic clk;
    logic rst_n;
    logic [31:0] o_ld_data;
    logic [1:0]o_result_srcW;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz
    end

    initial begin
        rst_n = 0;
        #50;
        rst_n = 1;
    end

    // ---------------- DUT ----------------
    pipeline dut (
        .i_clk   (clk),
        .i_rst_n (rst_n),
        .o_ld_data(o_ld_data),
        .o_result_srcW(o_result_srcW)
        // các port IO khác nếu có thì nối hoặc bỏ trống
    );

    // ---------------- Monitor regfile ----------------
    integer i;

    initial begin
        // chờ reset xong
        @(posedge rst_n);

        // chờ pipeline chạy một lúc
        #500;

        $display("====================================");
        $display(" REGISTER FILE DUMP ");
        $display("====================================");

        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d = 0x%08h (%0d)",
                i,
                dut.u_decode_stage.reg_file_inst.regf[i],dut.u_decode_stage.reg_file_inst.regf[i]
            );
        end

        $display("====================================");

        // chạy thêm để xem sóng
        #5000;
        $finish;
    end

endmodule

