module lsu (
   // Inputs:
   input logic i_clk,
   input logic i_rst_n,
   input logic [2:0] i_lsu_op,
   input logic [31:0] i_lsu_addr,
   input logic [31:0] i_st_data,
   input logic i_lsu_wren,

   output logic [31:0] o_ld_data
);

//-------------------------------- Internal signals --------------------------------

   // LSU address:
   logic [15:0] internal_addr;
   logic [4:0] offset;

   // DMEM signal:
   logic [31:0] dmem_data;
   logic [3:0] dmem_wren;


//-------------------------- Using 16-bit address for LSU --------------------------

   assign internal_addr = i_lsu_addr[15:0];

//------------------------------- DMEM instantiation -------------------------------
//---------------------------------------------------

logic [31:0] store_data;

always_comb begin
   case (i_lsu_op)
      3'b000: begin // SB
         store_data = {4{i_st_data[7:0]}};
      end
      3'b001: begin // SH
         store_data = {2{i_st_data[15:0]}};
      end
      3'b010: begin // SW
         store_data = i_st_data;
      end
      default: store_data = i_st_data;
   endcase
end
//---------------------------------------------------
   dmem DMEM (
      .i_clk (i_clk),
      .i_rst_n (i_rst_n),
      .i_dmem_addr (internal_addr),
      .i_wr_data (store_data),
      .i_dmem_wren (dmem_wren),
      .o_ld_data (dmem_data)
   );

//-------------------------------- Address decoding --------------------------------



   always_comb begin
      offset = ({3'b0, i_lsu_addr[1:0]} << 3);

      //--- DMEM ---
      if ((internal_addr[15:12] == 4'h2) || (internal_addr[15:12] == 4'h3)) begin

         if (!i_lsu_wren) begin //Load (read data)
            case (i_lsu_op)
               3'b000: o_ld_data = {{24{dmem_data[offset + 7]}}, dmem_data[offset +:8]};    //LB
               3'b001: o_ld_data = {{16{dmem_data[offset + 15]}}, dmem_data[offset +:16]};  //LH
               3'b010: o_ld_data = dmem_data;                                               //LW              
               3'b100: o_ld_data = {24'b0, dmem_data[offset +:8]};                          //LBU
               3'b101: o_ld_data = {16'b0, dmem_data[offset +:16]};                         //LHU   
               default: o_ld_data = 32'b0;
            endcase
            dmem_wren = 4'b0;
         end

         else begin //Store (write data)
            case (i_lsu_op)
               3'b000: dmem_wren = (4'b0001) << i_lsu_addr[1:0];  //SB
               3'b001: dmem_wren = (4'b0011) << i_lsu_addr[1:0];  //SH
               3'b010: dmem_wren = 4'b1111;                       //SW                                              
               default: dmem_wren = 4'b0;
            endcase
            o_ld_data = 32'b0;
         end
      end

      //--- Default ---
      else begin
         dmem_wren = 4'b0;
         o_ld_data = 32'b0;
      end
   end

endmodule
