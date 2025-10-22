module reg_file (
	
	input logic [31:0] i_rd_data,
	input logic [4:0] i_rd_addr,
	input logic [4:0] i_rs1_addr, 
	input logic [4:0] i_rs2_addr,	
	input logic i_rd_wren,
	input logic i_rst_n, 
	input logic i_clk, 

	output logic [31:0] o_rs1_data, 
	output logic [31:0] o_rs2_data

);

	logic [31:0] regf [31:0];	
		
	//-------------------------Read-----------------------------------
	assign	o_rs1_data = (i_rs1_addr == 0) ? 0 : regf[i_rs1_addr];
	assign	o_rs2_data = (i_rs2_addr == 0) ? 0 : regf[i_rs2_addr];
	
	//-------------------------Write----------------------------------
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			for (int i=0; i < 32; i++)
				regf[i] <= 0;
			end
		else begin
			if((i_rd_wren == 1) && (i_rd_addr != 0))
				regf[i_rd_addr] <= i_rd_data;
			end
	end
endmodule