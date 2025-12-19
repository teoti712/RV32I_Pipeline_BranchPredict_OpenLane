module inst_mem (
	input   logic [31:0] i_pcF,
	output  logic [31:0] o_instF);
    
	logic [3:0][7:0] imem [2**11-1:0];
	initial begin
		$readmemh("../hex/instmem_lstype.hex",imem);
	end
	
	assign o_instF = imem[i_pcF[12:2]];
endmodule
