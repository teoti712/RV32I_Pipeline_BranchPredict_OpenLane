module pc(
  input     logic           i_clk, 
  input     logic           i_rst_n, 
  input     logic           i_stallF,
  input     logic   [31:0]  i_pcFi,

  output    logic   [31:0]  o_pcF);

    always_ff @ (posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_pcF <= 32'b0;
          end
        else if (i_stallF) begin
          o_pcF <= o_pcF;
        end
        else begin
          o_pcF <= i_pcFi;
        end 
    end 
endmodule 