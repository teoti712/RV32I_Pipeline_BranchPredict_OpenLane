module dmem(
   // Inputs:
   input logic i_clk,
   input logic i_rst_n,
   input logic [15:0] i_dmem_addr,
   input logic [31:0] i_wr_data,
   input logic [3:0] i_dmem_wren,
   // Output:
   output logic [31:0] o_ld_data
);

//------------------------------- Signal declaration -------------------------------

   logic [7:0] dmem [0:(2**13)-1];
   logic [15:0] addr0, addr1, addr2, addr3;

//-------------------------------- Address decoding --------------------------------

   assign addr0 = (i_dmem_addr - 16'h2000) & 16'hFFFC;
   assign addr1 = addr0 + 1;
   assign addr2 = addr0 + 2;
   assign addr3 = addr0 + 3;

//----------------------------------- Read data ------------------------------------

   assign o_ld_data = {dmem[addr3], dmem[addr2], dmem[addr1], dmem[addr0]};

//----------------------------------- Write data -----------------------------------

   always @(posedge i_clk) 
   if(!i_rst_n) begin
      for (int i = 0; i <= 8191 ; i = i +1) begin
            dmem[i] <= 8'b0;
         end
   end
   
   else begin
      if (i_dmem_wren[0] == 1)
         dmem[addr0] <= i_wr_data[7:0];
      if (i_dmem_wren[1] == 1)
         dmem[addr1] <= i_wr_data[15:8];
      if (i_dmem_wren[2] == 1)
         dmem[addr2] <= i_wr_data[23:16];
      if (i_dmem_wren[3] == 1)
         dmem[addr3] <= i_wr_data[31:24];
   end

endmodule