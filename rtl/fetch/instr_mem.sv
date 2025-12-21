module inst_mem (
    input   logic [31:0] i_pcF,
    output  logic [31:0] o_instF
);

    // Byte-addressed instruction memory
    logic [7:0] imem [0:2**13-1]; // ví dụ 8KB

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

    // Little-endian instruction fetch
    assign o_instF = {
        imem[i_pcF + 3],
        imem[i_pcF + 2],
        imem[i_pcF + 1],
        imem[i_pcF + 0]
    };

endmodule
