module sltu(
	input logic [31:0] i_rs1_data, i_rs2_data,
	output logic [31:0] o_result_sltu
);
	always_comb begin
		for ( int i=31; i>=0; i--) begin
			if (i_rs1_data[i] != i_rs2_data[i]) begin
				o_result_sltu = i_rs2_data[i]; break;
			end
			else begin
				o_result_sltu = 0;
			end
		end
	end
endmodule