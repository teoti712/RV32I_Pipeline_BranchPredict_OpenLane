module output_buffer (
// Inputs:
   input logic i_clk,
   input logic i_rst_n,
   input logic [15:0] i_addr,
   input logic [31:0] i_wr_data,
   input logic [3:0] i_wr_en,
// Outputs:
   output logic [31:0] o_ld_data,
   output logic [31:0] o_io_ledr,
   output logic [31:0] o_io_ledg,
   output logic [6:0] o_io_hex0,
   output logic [6:0] o_io_hex1,
   output logic [6:0] o_io_hex2,
   output logic [6:0] o_io_hex3,
   output logic [6:0] o_io_hex4,
   output logic [6:0] o_io_hex5,
   output logic [6:0] o_io_hex6,
   output logic [6:0] o_io_hex7,
   output logic [31:0] o_io_lcd
);

//------------------------------- Signal declaration -------------------------------

   logic [7:0] data_reg [0:63];
   logic [15:0] addr0, addr1, addr2, addr3;

//-------------------------------- Address decoding --------------------------------

   assign addr0 = (i_addr - 16'h7000) & 16'hFFFC;
   assign addr1 = addr0 + 1;
   assign addr2 = addr0 + 2;
   assign addr3 = addr0 + 3;

//----------------------------------- Read data ------------------------------------

   assign o_ld_data = {data_reg[addr3], data_reg[addr2], data_reg[addr1], data_reg[addr0]};

//----------------------------------- Write data -----------------------------------

   always_ff @(posedge i_clk) begin
      if (!i_rst_n) begin
         for (int i = 0; i <= 63 ; i = i +1) begin
            data_reg[i] <= 8'b0;
         end
      end
      else begin
         if (i_wr_en[0] == 1)
            data_reg[addr0] <= i_wr_data[7:0];
         if (i_wr_en[1] == 1)
            data_reg[addr1] <= i_wr_data[15:8];
         if (i_wr_en[2] == 1)
            data_reg[addr2] <= i_wr_data[23:16];
         if (i_wr_en[3] == 1)
            data_reg[addr3] <= i_wr_data[31:24];
      end
   end

//-------------------------------- Peripheral data ---------------------------------

   always_ff @(posedge i_clk or negedge i_rst_n) begin
      if (!i_rst_n) begin
         o_io_ledr <= 32'b0;
         o_io_ledg <= 32'b0;
         o_io_hex0 <= 7'b0;
         o_io_hex1 <= 7'b0;
         o_io_hex2 <= 7'b0;
         o_io_hex3 <= 7'b0;
         o_io_hex4 <= 7'b0;
         o_io_hex5 <= 7'b0;
         o_io_hex6 <= 7'b0;
         o_io_hex7 <= 7'b0;
         o_io_lcd  <= 32'b0;
      end
      else if (i_wr_en) begin
         case (i_addr[7:4])
            4'h0: // Red LEDs
               o_io_ledr <= i_wr_data;
            4'h1: // Green LEDs
               o_io_ledg <= i_wr_data;
            4'h2: begin // 7-segment LEDs
               if (i_addr[3:0] <= 4'h3) begin
                  o_io_hex3 <= i_wr_data[30:24];
                  o_io_hex2 <= i_wr_data[22:16];
                  o_io_hex1 <= i_wr_data[14:8];
                  o_io_hex0 <= i_wr_data[6:0];
               end
               else begin
                  o_io_hex7 <= i_wr_data[30:24];
                  o_io_hex6 <= i_wr_data[22:16];
                  o_io_hex5 <= i_wr_data[14:8];
                  o_io_hex4 <= i_wr_data[6:0];
               end
            end
            4'h3: // LCD
               o_io_lcd <= i_wr_data;
            default: begin
               o_io_ledr <= o_io_ledr;
               o_io_ledg <= o_io_ledg;
               o_io_hex0 <= o_io_hex0;
               o_io_hex1 <= o_io_hex1;
               o_io_hex2 <= o_io_hex2;
               o_io_hex3 <= o_io_hex3;
               o_io_hex4 <= o_io_hex4;
               o_io_hex5 <= o_io_hex5;
               o_io_hex6 <= o_io_hex6;
               o_io_hex7 <= o_io_hex7;
               o_io_lcd  <= o_io_lcd;
            end
         endcase
      end
   end

endmodule