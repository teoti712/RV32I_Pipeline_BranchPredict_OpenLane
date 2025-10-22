module imm_gen(
	input logic [31:0] i_instD,
	output logic [31:0] o_immExtD
);
	always_comb begin
		case(i_instD[6:0])
		
				// Immediate-type
        	7'b0010011: begin
			case(i_instD[14:12])
				3'b001: o_immExtD = i_instD[24:20];
				3'b101: o_immExtD = i_instD[24:20];
				default: o_immExtD = {{20{i_instD[31]}}, i_instD[31:20] };
			endcase
    		end

				// Load-type
		7'b0000011: o_immExtD = {{20{i_instD[31]}}, i_instD[31:20] };

				// Store-type
		7'b0100011: o_immExtD = {{20{i_instD[31]}}, i_instD[31:25], i_instD[11:7] };

				// Branch-type
		7'b1100011: o_immExtD = {{19{i_instD[31]}}, i_instD[31], i_instD[7], i_instD[30:25], i_instD[11:8], 1'b0};

				// Jump-type 
		7'b1100111: o_immExtD = {{20{i_instD[31]}}, i_instD[31:20]};	// JALR	- Jump and Link
		7'b1101111: o_immExtD = {{12{i_instD[31]}}, i_instD[19:12], i_instD[20], i_instD[30:21], 1'b0 };	// JAL - Jump and Link Register
	
				// Upper_immediate-type
		7'b0110111: o_immExtD = {i_instD[31:12], {12{1'b0}}};	// LUI - load upper immediate						
   		7'b0010111: o_immExtD = {i_instD[31:12], {12{1'b0}}};	// AUIPC - load upper immediate to PC	
		
		endcase
	end
endmodule	
