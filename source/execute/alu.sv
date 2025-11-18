module alu (
	input logic [31:0] i_rs1_data, i_rs2_data,
	input logic [3:0] i_alu_sel,
	
	output logic [31:0] o_alu_resultE
);
	
	logic [31:0] o_result_slt, o_result_sltu;

	slt SLT (
		.i_rs1_data(i_rs1_data),
		.i_rs2_data(i_rs2_data),
		.o_result_slt(o_result_slt)
	);	
	sltu SLTU (
		.i_rs1_data(i_rs1_data),
		.i_rs2_data(i_rs2_data),
		.o_result_sltu(o_result_sltu)
	);
	always_comb begin
		case(i_alu_sel) 
			4'b0000: o_alu_resultE = i_rs1_data +  i_rs2_data ;	 	// ADD
			4'b0001: o_alu_resultE = i_rs1_data +  (~i_rs2_data) + 32'b1 ;	// SUB
			4'b0010: o_alu_resultE = i_rs1_data << i_rs2_data ;		// SLL
			4'b0011: o_alu_resultE = i_rs1_data >> i_rs2_data ; 		// SRL
			4'b0100: o_alu_resultE = i_rs1_data ^  i_rs2_data  ;		// XOR
			4'b0101: o_alu_resultE = i_rs1_data &  i_rs2_data  ;		// AND
			4'b0110: o_alu_resultE = i_rs1_data |  i_rs2_data  ;		// OR
			4'b0111: o_alu_resultE = o_result_slt		    ;		// SLT
			4'b1000: o_alu_resultE = o_result_sltu		    ;		// SLTU
			4'b1001: o_alu_resultE = $signed(i_rs1_data) >>> i_rs2_data;    // SRA
			4'b1010: o_alu_resultE = i_rs2_data;			
			default: o_alu_resultE = 0;
		endcase
	end
endmodule