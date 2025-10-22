module slt (
    input logic [31:0] i_rs1_data, i_rs2_data,
    output logic [31:0] o_result_slt
);

    always_comb begin
        if (i_rs1_data[31] != i_rs2_data[31]) begin
		o_result_slt = i_rs1_data [31];
	end
	else begin
		for (int i=31; i>=0; i--) begin
			if (i_rs1_data[i] != i_rs2_data[i]) begin
				o_result_slt = i_rs2_data[i]; break;
			end
			else begin
				o_result_slt = 0;
			end
			
		end
	end
    end
endmodule
