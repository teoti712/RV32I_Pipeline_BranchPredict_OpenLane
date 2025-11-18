`timescale 1ns/1ps

module execute_stage(
    input  logic [31:0] i_instE,
    input  logic [31:0] i_rs1_dataE,
    input  logic [31:0] i_rs2_dataE,
    input  logic [31:0] i_alu_resultM,
    input  logic [31:0] i_resultW,
    input  logic [31:0] i_pcE,
    input  logic [31:0] i_immExtE,
    input  logic [1:0]  i_forwardAE,
    input  logic [1:0]  i_forwardBE,
    input  logic        i_alu_srcAE,
    input  logic        i_alu_srcBE,
    input  logic [3:0]  i_alu_ctrlE,

    output logic        o_branch_takenE,
    output logic [31:0] o_wr_dataE,
    output logic [31:0] o_alu_resultE,
    output logic [31:0] o_pc_targetE);

    logic [31:0] w_mux_alu_srcAE;
    logic [31:0] w_mux_alu_srcBE;
    logic [31:0] w_srcAE;
    logic [31:0] w_srcBE;

    mux_forward mux_forwardA(
        .i_sel(i_forwardAE),
        .i_A(i_rs1_dataE),
        .i_B(i_resultW),
        .i_C(i_alu_resultM),
        .o_mux(w_mux_alu_srcAE));
    mux_forward mux_forwardB(
        .i_sel(i_forwardBE),
        .i_A(i_rs2_dataE),
        .i_B(i_resultW),
        .i_C(i_alu_resultM),
        .o_mux(w_mux_alu_srcBE));
    mux_alu_src mux_alu_srcAE(
        .i_sel(i_alu_srcAE),
        .i_A(w_mux_alu_srcAE),
        .i_B(i_pcE),
        .o_mux(w_srcAE));
    mux_alu_src mux_alu_srcBE(
        .i_sel(i_alu_srcBE),
        .i_A(w_mux_alu_srcBE),
        .i_B(i_immExtE),
        .o_mux(w_srcBE));
    add add_inst(
        .i_pcE(i_pcE),
        .i_immExtE(i_immExtE),
        .o_pc_targetE(o_pc_targetE));
    alu alu_inst(
        .i_rs1_data(w_srcAE),
        .i_rs2_data(w_srcBE),
        .i_alu_sel(i_alu_ctrlE),
        .o_alu_resultE(o_alu_resultE));
    branch branch_inst(
        .i_rs1_dataE(w_mux_alu_srcAE),
        .i_rs2_dataE(w_mux_alu_srcBE),
        .i_funct3E(i_instE[14:12]),
        .o_branch_takenE(o_branch_takenE));
    assign o_wr_dataE = w_srcBE;
endmodule

// --------------------------
// Minimal helper modules used by execute_stage (behavioral)
// --------------------------
module mux_forward(
    input  logic [1:0]  i_sel,
    input  logic [31:0] i_A,
    input  logic [31:0] i_B,
    input  logic [31:0] i_C,
    output logic [31:0] o_mux);
    always_comb begin
        case (i_sel)
            2'b00: o_mux = i_A;
            2'b01: o_mux = i_B;
            2'b10: o_mux = i_C;
            default: o_mux = i_A;
        endcase
    end
endmodule

module mux_alu_src(
    input logic i_sel,
    input logic [31:0] i_A,
    input logic [31:0] i_B,
    output logic [31:0] o_mux);
    assign o_mux = i_sel ? i_B : i_A;
endmodule

module add(
    input  logic [31:0] i_pcE,
    input  logic [31:0] i_immExtE,
    output logic [31:0] o_pc_targetE);
    assign o_pc_targetE = i_pcE + i_immExtE;
endmodule

// --------------------------
// ALU (mapping fixed theo bảng bạn đưa)
// --------------------------
module alu(
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic [3:0]  i_alu_sel,
    output logic [31:0] o_alu_resultE);
    logic signed [31:0] s1, s2;
    assign s1 = i_rs1_data;
    assign s2 = i_rs2_data;
    always_comb begin
        case (i_alu_sel)
            4'd0: o_alu_resultE = i_rs1_data + i_rs2_data; // add
            4'd1: o_alu_resultE = i_rs1_data - i_rs2_data; // sub
            4'd2: o_alu_resultE = i_rs1_data << i_rs2_data[4:0]; // sll
            4'd3: o_alu_resultE = i_rs1_data >> i_rs2_data[4:0]; // slr logical
            4'd4: o_alu_resultE = i_rs1_data ^ i_rs2_data; // xor
            4'd5: o_alu_resultE = i_rs1_data & i_rs2_data; // and
            4'd6: o_alu_resultE = i_rs1_data | i_rs2_data; // or
            4'd7: o_alu_resultE = (s1 < s2) ? 32'd1 : 32'd0; // slt signed
            4'd8: o_alu_resultE = ($unsigned(i_rs1_data) < $unsigned(i_rs2_data)) ? 32'd1 : 32'd0; // sltu
            4'd9: o_alu_resultE = $signed(i_rs1_data) >>> i_rs2_data[4:0]; // sra arithmetic
            4'd10: o_alu_resultE = i_rs2_data; // GrabOnlyB (rd = rs2)
            default: o_alu_resultE = 32'hxxxx_xxxx;
        endcase
    end
endmodule

// Branch unit: funct3 mapping (RISC-V BEQ/BNE/BLT/BGE/BLTU/BGEU)
module branch(
    input  logic [31:0] i_rs1_dataE,
    input  logic [31:0] i_rs2_dataE,
    input  logic [2:0]  i_funct3E,
    output logic        o_branch_takenE);
    logic signed [31:0] s1, s2;
    assign s1 = i_rs1_dataE;
    assign s2 = i_rs2_dataE;
    always_comb begin
        case (i_funct3E)
            3'b000: o_branch_takenE = (i_rs1_dataE == i_rs2_dataE); // BEQ
            3'b001: o_branch_takenE = (i_rs1_dataE != i_rs2_dataE); // BNE
            3'b100: o_branch_takenE = (s1 < s2); // BLT (signed)
            3'b101: o_branch_takenE = (s1 >= s2); // BGE (signed)
            3'b110: o_branch_takenE = ($unsigned(i_rs1_dataE) < $unsigned(i_rs2_dataE)); // BLTU
            3'b111: o_branch_takenE = ($unsigned(i_rs1_dataE) >= $unsigned(i_rs2_dataE)); // BGEU
            default: o_branch_takenE = 1'b0;
        endcase
    end
endmodule

// --------------------------
// Testbench
// --------------------------
module execute_stage_tb;
    // DUT inputs
    logic [31:0] i_instE;
    logic [31:0] i_rs1_dataE;
    logic [31:0] i_rs2_dataE;
    logic [31:0] i_alu_resultM;
    logic [31:0] i_resultW;
    logic [31:0] i_pcE;
    logic [31:0] i_immExtE;
    logic [1:0]  i_forwardAE;
    logic [1:0]  i_forwardBE;
    logic        i_alu_srcAE;
    logic        i_alu_srcBE;
    logic [3:0]  i_alu_ctrlE;

    // DUT outputs
    logic o_branch_takenE;
    logic [31:0] o_wr_dataE;
    logic [31:0] o_alu_resultE;
    logic [31:0] o_pc_targetE;

    // ALU opcode symbolic names (the ones from your table)
    localparam logic [3:0] ALU_ADD  = 4'd0;
    localparam logic [3:0] ALU_SUB  = 4'd1;
    localparam logic [3:0] ALU_SLL  = 4'd2;
    localparam logic [3:0] ALU_SLR  = 4'd3;
    localparam logic [3:0] ALU_XOR  = 4'd4;
    localparam logic [3:0] ALU_AND  = 4'd5;
    localparam logic [3:0] ALU_OR   = 4'd6;
    localparam logic [3:0] ALU_SLT  = 4'd7;
    localparam logic [3:0] ALU_SLTU = 4'd8;
    localparam logic [3:0] ALU_SRA  = 4'd9;
    localparam logic [3:0] ALU_GRB  = 4'd10; // GrabOnlyB

    // instantiate DUT
    execute_stage dut (
        .i_instE(i_instE),
        .i_rs1_dataE(i_rs1_dataE),
        .i_rs2_dataE(i_rs2_dataE),
        .i_alu_resultM(i_alu_resultM),
        .i_resultW(i_resultW),
        .i_pcE(i_pcE),
        .i_immExtE(i_immExtE),
        .i_forwardAE(i_forwardAE),
        .i_forwardBE(i_forwardBE),
        .i_alu_srcAE(i_alu_srcAE),
        .i_alu_srcBE(i_alu_srcBE),
        .i_alu_ctrlE(i_alu_ctrlE),

        .o_branch_takenE(o_branch_takenE),
        .o_wr_dataE(o_wr_dataE),
        .o_alu_resultE(o_alu_resultE),
        .o_pc_targetE(o_pc_targetE)
    );

    // VCD dump
    initial begin
        $dumpfile("execute_stage_tb_fixed.vcd");
        $dumpvars(0, execute_stage_tb);
        $dumpvars(0, execute_stage_tb.dut.alu_inst);
        $dumpvars(0, execute_stage_tb.dut.branch_inst);
    end

    // helper task to perform test vector and check expected results
    task automatic run_vector(
        input string testname,
        input logic [31:0] rs1,
        input logic [31:0] rs2,
        input logic [31:0] alu_resultM_in,
        input logic [31:0] resultW_in,
        input logic [31:0] pc_in,
        input logic [31:0] imm_in,
        input logic [1:0]  fwdA,
        input logic [1:0]  fwdB,
        input logic        aluSrcA,
        input logic        aluSrcB,
        input logic [3:0]  alu_ctrl,
        input logic [2:0]  funct3
    );
        logic [31:0] srcA_muxed;
        logic [31:0] srcB_muxed;
        logic [31:0] srcA;
        logic [31:0] srcB;
        logic expected_branch;
        logic [31:0] expected_alu;

        begin
            // apply inputs
            i_rs1_dataE = rs1;
            i_rs2_dataE = rs2;
            i_alu_resultM = alu_resultM_in;
            i_resultW = resultW_in;
            i_pcE = pc_in;
            i_immExtE = imm_in;
            i_forwardAE = fwdA;
            i_forwardBE = fwdB;
            i_alu_srcAE = aluSrcA;
            i_alu_srcBE = aluSrcB;
            i_alu_ctrlE = alu_ctrl;
i_instE = funct3 << 12; // đặt funct3 vào i_instE[14:12]

            // compute what mux_forward would do
            case (fwdA)
                2'b00: srcA_muxed = rs1;
                2'b01: srcA_muxed = resultW_in;
                2'b10: srcA_muxed = alu_resultM_in;
                default: srcA_muxed = rs1;
            endcase
            case (fwdB)
                2'b00: srcB_muxed = rs2;
                2'b01: srcB_muxed = resultW_in;
                2'b10: srcB_muxed = alu_resultM_in;
                default: srcB_muxed = rs2;
            endcase
            // compute srcA/srcB used by ALU (mux_alu_src)
            srcA = aluSrcA ? pc_in : srcA_muxed;
            srcB = aluSrcB ? imm_in : srcB_muxed;

            // expected ALU (mapping theo bảng)
            case (alu_ctrl)
                ALU_ADD: expected_alu = srcA + srcB;
                ALU_SUB: expected_alu = srcA - srcB;
                ALU_SLL: expected_alu = srcA << srcB[4:0];
                ALU_SLR: expected_alu = srcA >> srcB[4:0];
                ALU_XOR: expected_alu = srcA ^ srcB;
                ALU_AND: expected_alu = srcA & srcB;
                ALU_OR : expected_alu = srcA | srcB;
                ALU_SLT: expected_alu = ($signed(srcA) < $signed(srcB)) ? 32'd1 : 32'd0;
                ALU_SLTU: expected_alu = ($unsigned(srcA) < $unsigned(srcB)) ? 32'd1 : 32'd0;
                ALU_SRA: expected_alu = $signed(srcA) >>> srcB[4:0];
                ALU_GRB: expected_alu = srcB; // grab only B
                default: expected_alu = 32'hxxxx_xxxx;
            endcase

            // expected branch decision (branch module uses the pre-alu muxed values)
            case (funct3)
                3'b000: expected_branch = (srcA_muxed == srcB_muxed); // BEQ
                3'b001: expected_branch = (srcA_muxed != srcB_muxed); // BNE
                3'b100: expected_branch = ($signed(srcA_muxed) < $signed(srcB_muxed)); // BLT
                3'b101: expected_branch = ($signed(srcA_muxed) >= $signed(srcB_muxed)); // BGE
                3'b110: expected_branch = ($unsigned(srcA_muxed) < $unsigned(srcB_muxed)); // BLTU
                3'b111: expected_branch = ($unsigned(srcA_muxed) >= $unsigned(srcB_muxed)); // BGEU
                default: expected_branch = 1'b0;
            endcase

            #5; // wait for combinational logic to settle

            // display and compare
            $display("------------------------------------------------------------");
            $display("TEST: %s", testname);
            $display("Inputs: rs1=0x%08h rs2=0x%08h pc=0x%08h imm=0x%08h fwdA=%0d fwdB=%0d aluSrcA=%0b aluSrcB=%0b alu_ctrl=0x%0h funct3=0x%0h",
                     rs1, rs2, pc_in, imm_in, fwdA, fwdB, aluSrcA, aluSrcB, alu_ctrl, funct3);
            $display("Expected: alu=0x%08h branch=%0b", expected_alu, expected_branch);
            $display("Actual  : alu=0x%08h branch=%0b", o_alu_resultE, o_branch_takenE);
            if (o_alu_resultE === expected_alu)
                $display("ALU: PASS");
            else
                $display("ALU: FAIL");

            if (o_branch_takenE === expected_branch)
                $display("BRANCH: PASS");
            else
                $display("BRANCH: FAIL");

            $display("o_wr_dataE (should equal srcB) = 0x%08h   (srcB computed = 0x%08h)", o_wr_dataE, srcB);
            $display("o_pc_targetE = 0x%08h (pc + imm check = 0x%08h)", o_pc_targetE, pc_in + imm_in);
            #5;
        end
    endtask

    initial begin
        // init
        i_instE = 0;
        i_rs1_dataE = 0;
        i_rs2_dataE = 0;
        i_alu_resultM = 0;
        i_resultW = 0;
        i_pcE = 0;
        i_immExtE = 0;
        i_forwardAE = 2'b00;
        i_forwardBE = 2'b00;
        i_alu_srcAE = 1'b0;
        i_alu_srcBE = 1'b0;
        i_alu_ctrlE = 4'h0;

        #10;

        // Vector set 1: ALU add
        run_vector("ALU ADD simple",
            32'h0000_0005, 32'h0000_0003, 0, 0, 32'h0000_1000, 32'h0000_0004,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b000);

        // Vector 2: ALU SUB
        run_vector("ALU SUB simple",
            32'h0000_0005, 32'h0000_0007, 0, 0, 32'h0000_1000, 32'hFFFF_FFFC,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_SUB, 3'b000);

        // Vector 3: AND
        run_vector("ALU AND",
            32'hFFFF_00FF, 32'h00FF_FF00, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_AND, 3'b000);

        // Vector 4: OR
        run_vector("ALU OR",
            32'h0F0F_0F0F, 32'hF0F0_F0F0, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_OR, 3'b000);

        // Vector 5: SLL (shift)
        run_vector("ALU SLL",
            32'h0000_0001, 32'h0000_0004, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_SLL, 3'b000);

        // Vector 6: SLT signed (neg vs pos)
        run_vector("ALU SLT signed",
            32'hFFFF_FFFF, 32'h0000_0001, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_SLT, 3'b000);

        // Vector 7: SLTU unsigned (large unsigned compare)
        run_vector("ALU SLTU unsigned",
            32'hFFFF_FFFF, 32'h7FFF_FFFF, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_SLTU, 3'b000);

        // Branch tests
        // BEQ true
        run_vector("BRANCH BEQ true",
            32'h0000_AAAA, 32'h0000_AAAA, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b000);

        // BNE true
        run_vector("BRANCH BNE true",
            32'h0000_AAAA, 32'h0000_AAAB, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b001);

        // BLT signed true (neg < pos)
        run_vector("BRANCH BLT signed true",
            32'hFFFF_FFFF, 32'h0000_0001, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b100);

        // BGE signed true
        run_vector("BRANCH BGE signed true",
            32'h0000_0005, 32'h0000_0004, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b101);

        // BLTU unsigned: 0xFFFF_FFFE < 0xFFFF_FFFF -> true
        run_vector("BRANCH BLTU true",
            32'hFFFF_FFFE, 32'hFFFF_FFFF, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b110);

        // BGEU unsigned false
        run_vector("BRANCH BGEU false",
            32'h7FFF_FFFF, 32'hFFFF_FFFF, 0, 0, 0, 0,
            2'b00, 2'b00, 1'b0, 1'b0, ALU_ADD, 3'b111);

        // Test forwarding: forward rs1 from resultW and rs2 from alu_resultM
        run_vector("Forwarding test",
            32'h0000_0000, 32'h0000_0000, 32'h0000_0100, 32'h0000_0200, 0, 0,
            2'b10, 2'b01, 1'b0, 1'b0, ALU_ADD, 3'b000);

        // Test alu_src: use pc as srcA and imm as srcB
        run_vector("ALU using PC and IMM (ADD)",
            32'h0, 32'h0, 0, 0, 32'h0000_1000, 32'h0000_0100,
            2'b00, 2'b00, 1'b1, 1'b1, ALU_ADD, 3'b000);

        $display("All tests finished.");
        #10;
        $finish;
    end
endmodule
