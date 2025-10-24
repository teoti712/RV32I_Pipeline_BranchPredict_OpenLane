module input_buffer (
   // Inputs:
   input logic [15:0] i_addr,
   input logic [31:0] i_io_sw,
   input logic [3:0] i_io_btn,
   // Outputs:
   output logic [31:0] o_ld_data
);

   always_comb begin
      if (i_addr[7:4] == 4'h0) begin
         o_ld_data = i_io_sw;
      end
      else if (i_addr[7:4] == 4'h1) begin
         o_ld_data = {28'h0, i_io_btn};
      end
      else o_ld_data = 32'h0;
   end

endmodule