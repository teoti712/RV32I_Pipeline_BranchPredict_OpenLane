`timescale 1ns/1ps

module tb_decode_stage;

    // Inputs to DUT
    logic         i_clk;
    logic         i_rst_n;
    logic [31:0]  i_instD;
    logic [31:0]  i_resultW;
    logic [4:0]   i_rdW;
    logic         i_reg_wrW;

    // Outputs from DUT
    logic [31:0]  o_immExtD;
    logic [31:0]  o_rs1_dataD;
    logic [31:0]  o_rs2_dataD;
    logic         reg_wrD;
    logic [1:0]   result_srcD;
    logic         mem_wrD;
    logic         jumpD;
    logic         branchD;
    logic [3:0]   alu_ctrlD;
    logic         alu_srcAD;
    logic         alu_srcBD;

    // Instantiate the DUT
    decode_stage dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_instD(i_instD),
        .i_resultW(i_resultW),
        .i_rdW(i_rdW),
        .i_reg_wrW(i_reg_wrW),
        .o_immExtD(o_immExtD),
        .o_rs1_dataD(o_rs1_dataD),
        .o_rs2_dataD(o_rs2_dataD),
        .reg_wrD(reg_wrD),
        .result_srcD(result_srcD),
        .mem_wrD(mem_wrD),
        .jumpD(jumpD),
        .branchD(branchD),
        .alu_ctrlD(alu_ctrlD),
        .alu_srcAD(alu_srcAD),
        .alu_srcBD(alu_srcBD)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 100 MHz (10 ns period)
    end

    // Instruction samples (RISC-V encodings)
    // These are example encodings:
    // add x1, x2, x3   -> R-type
    localparam logic [31:0] INST_ADD  = 32'h00300B33; // add rd=1 rs1=2 rs2=3 opcode=0x33 (example)
    // addi x4, x5, 10 -> I-type
    localparam logic [31:0] INST_ADDI = 32'h00A28213; // addi rd=4 rs1=5 imm=10
    // sw x6, 8(x7)    -> S-type
    localparam logic [31:0] INST_SW   = 32'h0083A423; // sw rs2=6 rs1=7 imm=8
    // beq x1, x2, 16  -> B-type
    localparam logic [31:0] INST_BEQ  = 32'h01010663; // beq rs1=1 rs2=2 imm=16
    // jal x1, 2048    -> J-type
    localparam logic [31:0] INST_JAL  = 32'h0000_0F6F; // jal rd=1 imm=2048 (example; depends on encoding)
    // NOTE: Encodings above are illustrative; adjust if your control_unit/imm_gen expects different immediate layout.

    // Test sequence
    initial begin
        // VCD dump for waveform
        $dumpfile("tb_decode_stage.vcd");
        $dumpvars(0, tb_decode_stage);

        // initialize inputs
        i_rst_n = 0;
        i_instD = 32'h0;
        i_resultW = 32'h0;
        i_rdW = 5'd0;
        i_reg_wrW = 1'b0;

        // Hold reset for a few cycles
        repeat (4) @(posedge i_clk);
        i_rst_n = 1;

        // 1) Feed an R-type (add) instruction
        @(posedge i_clk);
        i_instD = INST_ADD;
        // No writeback yet
        i_reg_wrW = 1'b0;
        @(posedge i_clk);

        // Show outputs
        $display("[%0t] R-type: inst=0x%08h immExt=0x%08h rs1=0x%08h rs2=0x%08h reg_wr=%0b alu_ctrl=%0b",
                 $time, i_instD, o_immExtD, o_rs1_dataD, o_rs2_dataD, reg_wrD, alu_ctrlD);

        // 2) Feed an I-type (addi) instruction
        @(posedge i_clk);
        i_instD = INST_ADDI;
        @(posedge i_clk);
        $display("[%0t] I-type: inst=0x%08h immExt=0x%08h rs1=0x%08h reg_wr=%0b alu_srcBD=%0b result_src=%0b",
                 $time, i_instD, o_immExtD, o_rs1_dataD, reg_wrD, alu_srcBD, result_srcD);

        // 3) Simulate write-back to register file: write value 0xDEADBEEF to x4
        @(posedge i_clk);
        i_resultW = 32'hDEAD_BEEF;
        i_rdW = 5'd4;        // rd = x4 (matches addi rd above)
        i_reg_wrW = 1'b1;
        @(posedge i_clk);
        $display("[%0t] WB: wrote 0x%08h -> x%0d", $time, i_resultW, i_rdW);

        // disable write enable
        @(posedge i_clk); i_reg_wrW = 1'b0;

        // 4) Feed S-type (store) instruction
        @(posedge i_clk);
        i_instD = INST_SW;
        @(posedge i_clk);
        $display("[%0t] S-type: inst=0x%08h immExt=0x%08h rs1=0x%08h rs2=0x%08h mem_wr=%0b",
                 $time, i_instD, o_immExtD, o_rs1_dataD, o_rs2_dataD, mem_wrD);

        // 5) Feed B-type (branch) instruction
        @(posedge i_clk);
        i_instD = INST_BEQ;
        @(posedge i_clk);
        $display("[%0t] B-type: inst=0x%08h immExt=0x%08h branch=%0b alu_ctrl=%0b",
                 $time, i_instD, o_immExtD, branchD, alu_ctrlD);

        // 6) Feed J-type (jump) instruction
        @(posedge i_clk);
        i_instD = INST_JAL;
        @(posedge i_clk);
        $display("[%0t] J-type: inst=0x%08h immExt=0x%08h jump=%0b result_src=%0b",
                 $time, i_instD, o_immExtD, jumpD, result_srcD);

        // Finalization
        repeat (5) @(posedge i_clk);
        $display("Testbench finished at time %0t", $time);
        $finish;
    end

    // Optional: monitor at every clock edge (more verbose)
    always @(posedge i_clk) begin
        // print a short trace
        $strobe("[%0t] inst=0x%08h imm=0x%08h rs1=0x%08h rs2=0x%08h reg_wr=%0b mem_wr=%0b branch=%0b jump=%0b",
                $time, i_instD, o_immExtD, o_rs1_dataD, o_rs2_dataD, reg_wrD, mem_wrD, branchD, jumpD);
    end

endmodule
