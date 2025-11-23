`timescale 1ns/1ps

module testbench;
    logic        i_clk;
    logic        i_rst_n;
    logic [31:0] i_io_sw;
    logic [3:0]  i_io_btn;
    logic [31:0] o_ld_data, o_io_ledr, o_io_ledg, o_io_lcd;
    logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3;
    logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7;
    pipeline dut (.*);

    initial  i_clk = 0;
    always #5 i_clk = ~i_clk;
    
    initial begin
        $display("=== START REAL SIMULATION ===");
        
        i_rst_n = 0; 
        i_io_sw = 0; 
        i_io_btn = 0;
        #20;
        i_rst_n = 1; 
        repeat(30) @(posedge i_clk);
        $display("=== SIMULATION FINISHED ===");
        $finish;
    end

    always @(posedge i_clk) begin
        if (dut.w_reg_wrW && i_rst_n) begin
	    if($test$plusargs("utype")==1) begin
            	case (dut.w_rdW)
                    1: begin
                        if (dut.w_resultW === 32'h12345000) 
                             $display("[LUI]   Pass (Val: %h)", dut.w_resultW);
                        else $display("[LUI]   FAIL (Expected: 12345000, Got: %h)", dut.w_resultW);end
                    2: begin
                        if (dut.w_resultW === 32'h10000004) 
                             $display("[AUIPC] Pass (PC+Imm correct)");
                        else $display("[AUIPC] FAIL (Expected: 10000004, Got: %h)", dut.w_resultW);end
                    3: begin
                        if (dut.w_resultW === 32'h00000008) 
                             $display("[AUIPC] Pass (Captured PC=8)");
                        else $display("[AUIPC] FAIL (Expected: 00000008, Got: %h)", dut.w_resultW);end
                    default: $display("[WB] rd=%d val=%h", dut.w_rdW, dut.w_resultW);endcase 
	    end else if($test$plusargs("rtype")==1) begin
	        case (dut.w_rdW)
                    1:  $display("[SETUP] x1  = %d (Expected: 240)", dut.w_resultW);
                    2:  $display("[SETUP] x2  = %d (Expected: 4)",   dut.w_resultW);
                    3:  $display("[ADD]   x3  = %d (Expected: 244)", dut.w_resultW);
                    4:  $display("[SUB]   x4  = %d (Expected: 236)", dut.w_resultW);
                    5:  $display("[SLL]   x5  = %h (Expected: f00)", dut.w_resultW);
                    6:  $display("[SLT]   x6  = %d (Expected: 0)",   dut.w_resultW);
                    7:  $display("[SLTU]  x7  = %d (Expected: 0)",   dut.w_resultW);
                    8:  $display("[XOR]   x8  = %h (Expected: f4)",  dut.w_resultW);
                    9:  $display("[SRL]   x9  = %h (Expected: 0f)",  dut.w_resultW);
                    10: $display("[SRA]   x10 = %h (Expected: 0f)",  dut.w_resultW);
                    11: $display("[OR]    x11 = %h (Expected: f4)",  dut.w_resultW);
                    12: $display("[AND]   x12 = %h (Expected: 00)",  dut.w_resultW);
                default: $display("[WB] rd=%d val=%h", dut.w_rdW, dut.w_resultW);endcase
	    end else if($test$plusargs("itype")==1) begin
	       case (dut.w_rdW)
                    1:  $display("[SETUP] x1  = %d (Expected: 16)", dut.w_resultW);
                    2:  $display("[ADDI]  x2  = %d (Expected: 26)", dut.w_resultW); // 16 + 10
                    3:  $display("[SLTI]  x3  = %d (Expected: 1)",  dut.w_resultW); // 16 < 20 -> True
                    4:  $display("[SLTI]  x4  = %d (Expected: 0)",  dut.w_resultW); // 16 < 10 -> False
                    5:  $display("[SLTIU] x5  = %d (Expected: 1)",  dut.w_resultW); // Unsigned check
                    6:  $display("[XORI]  x6  = %d (Expected: 31)", dut.w_resultW); // 16 ^ 15
                    7:  $display("[ORI]   x7  = %d (Expected: 48)", dut.w_resultW); // 16 | 32
                    8:  $display("[ANDI]  x8  = %d (Expected: 0)",  dut.w_resultW); // 16 & 7
                    9:  $display("[SLLI]  x9  = %d (Expected: 64)", dut.w_resultW); // 16 << 2
                    10: $display("[SRLI]  x10 = %d (Expected: 4)",  dut.w_resultW); // 16 >> 2
                    11: $display("[SRAI]  x11 = %d (Expected: 4)",  dut.w_resultW); // 16 >>> 2
                    12: begin
                        if (dut.w_resultW == 10) 
                            $display("[ADDI-] x12 = %d (Expected: 10) -> PASSED SIGN EXTENSION", dut.w_resultW);
                        else
                            $display("[ADDI-] x12 = %d (Expected: 10) -> FAILED SIGN EXTENSION", dut.w_resultW);
                    end
                    default: $display("[WB] rd=%d val=%h", dut.w_rdW, dut.w_resultW);endcase
	    end else if($test$plusargs("lstype")==1) begin
		case (dut.w_rdW)
                    1: $display("[SETUP] x1 (Base) = %h (Expected: 00002000)", dut.w_resultW);
                    2: $display("[SETUP] x2 (Data) = %h (Expected: 55aa33cc)", dut.w_resultW);
                    3: begin
                        if (dut.w_resultW === 32'h55AA33CC)
                            $display("[LW]    x3 = %h (PASS)", dut.w_resultW);
                        else
                            $display("[LW]    x3 = %h (FAIL - Expected: 55aa33cc)", dut.w_resultW);
                    end
                    4: begin 
                        if (dut.w_resultW === 32'h000033CC) 
                             $display("[LHU]   x4 = %h (PASS)", dut.w_resultW);
                        else $display("[LHU]   x4 = %h (FAIL - Expected: 000033cc)", dut.w_resultW);
                    end
                    5: ; 
                    6: begin
                        if (dut.w_resultW === 32'hFFFFFFFF)
                             $display("[LH]    x6 = %h (PASS - Signed Ext)", dut.w_resultW);
                        else $display("[LH]    x6 = %h (FAIL - Expected: ffffffff)", dut.w_resultW);
                    end
                    7: begin
                        if (dut.w_resultW === 32'h0000FFFF)
                             $display("[LHU]   x7 = %h (PASS - Zero Ext)", dut.w_resultW);
                        else $display("[LHU]   x7 = %h (FAIL - Expected: 0000ffff)", dut.w_resultW);
                    end
                    8: begin
                        if (dut.w_resultW === 32'hFFFFFFCC)
                             $display("[LB]    x8 = %h (PASS - Signed Byte)", dut.w_resultW);
                        else $display("[LB]    x8 = %h (FAIL - Expected: ffffffcc)", dut.w_resultW);
                    end
                    9: begin
                        if (dut.w_resultW === 32'h000000CC)
                             $display("[LBU]   x9 = %h (PASS - Unsigned Byte)", dut.w_resultW);
                        else $display("[LBU]   x9 = %h (FAIL - Expected: 000000cc)", dut.w_resultW);
                    end
                    default: $display("[WB] rd=%d val=%h", dut.w_rdW, dut.w_resultW); endcase		
	    end else if($test$plusargs("btype")==1) begin
		case (dut.w_rdW)
                    1: ; // Setup x1
                    2: ; // Setup x2
                    10:; // Setup x10
                    3: begin
                        if(dut.w_resultW == 1) $display("[BEQ]  Pass (Jumped Correctly)");
                        else                   $display("[BEQ]  FAIL (Did not jump)");
                    end
                    4: begin
                        if(dut.w_resultW == 1) $display("[BNE]  Pass (Jumped Correctly)");
                        else                   $display("[BNE]  FAIL (Did not jump)");
                    end
                    5: begin
                        if(dut.w_resultW == 1) $display("[BLT]  Pass (Signed Check OK)");
                        else                   $display("[BLT]  FAIL (Signed Check Error)");
                    end
                    6: begin
                        if(dut.w_resultW == 1) $display("[BGE]  Pass (Signed Check OK)");
                        else                   $display("[BGE]  FAIL (Signed Check Error)");
                    end
                    7: begin
                        if(dut.w_resultW == 1) $display("[BLTU] Pass (Unsigned Check OK - Fallthrough)");
                        else                   $display("[BLTU] FAIL (Jumped incorrectly on Unsigned)");
                    end
                    8: begin
                        if(dut.w_resultW == 1) $display("[BGEU] Pass (Unsigned Check OK)");
                        else                   $display("[BGEU] FAIL (Unsigned Check Error)");
                    end
                    default: $display("[WB] rd=%d val=%h", dut.w_rdW, dut.w_resultW);endcase	        
	    end else if($test$plusargs("jtype")==1) begin
		case (dut.w_rdW)
                    10: ; 
                    1: begin
                        // PC của lệnh JAL là 0x04, vậy x1 phải lưu 0x08
                        if (dut.w_resultW === 32'h8) 
                             $display("[JAL-Link] Pass (Saved PC+4 = 8)");
                        else $display("[JAL-Link] FAIL (Expected 8, Got %h)", dut.w_resultW);
                    end
                    2: begin
                        if (dut.w_resultW === 1) 
                             $display("[JAL-Jump] Pass (Skipped FAIL instr)");
                        else $display("[JAL-Jump] FAIL (Executed FAIL instr)");
                    end
                    11: begin
                        // PC của lệnh JALR là 0x10 (16), vậy x11 phải lưu 0x14 (20)
                        if (dut.w_resultW === 32'h14) 
                             $display("[JALR-Link] Pass (Saved PC+4 = 0x14)");
                        else $display("[JALR-Link] FAIL (Expected 0x14, Got %h)", dut.w_resultW);
                    end
                    3: begin
                        if (dut.w_resultW === 1) 
                             $display("[JALR-Jump] Pass (Skipped FAIL instr)");
                        else $display("[JALR-Jump] FAIL (Executed FAIL instr)");
                    end
                    default: $display("[WB] rd=%d val=%h", dut.w_rdW, dut.w_resultW);endcase
	    end
        end
    end
endmodule
