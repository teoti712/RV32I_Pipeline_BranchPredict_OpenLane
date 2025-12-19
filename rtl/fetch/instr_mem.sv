module inst_mem (
    input   logic [31:0] i_pcF,
    output  logic [31:0] o_instF
);
    logic [3:0][7:0] imem [2**11-1:0];
    
    string hex_filename;

    initial begin
        if ($value$plusargs("HEX_FILE=%s", hex_filename)) begin
            $display("Loading Instruction Memory from: %s", hex_filename);
            $readmemh(hex_filename, imem);
        end 
        else begin
            $display("WARNING: No HEX_FILE specified! Loading default.");
            $readmemh("default.hex", imem); 
        end
    end
    
    assign o_instF = imem[i_pcF[12:2]];
endmodule