module BTB #(parameter ENTRY = 128)(
    input  logic         i_clk,
    input  logic         i_rst_n,
    // Fetch
    input  logic [31:0]  i_pcF,
    output logic         o_hitF,
    output logic [31:0]  o_targetF,
    // Execute
    input  logic         i_update_enE,
    input  logic [31:0]  i_pcE,
    input  logic [31:0]  i_targetE);

    localparam IDX_W = $clog2(ENTRY);

    typedef struct packed {
        logic        valid;
        logic [31:IDX_W+2] tag;
        logic [31:0] target;
    } btb_entry_t;

    btb_entry_t btb_array [ENTRY];

    logic [IDX_W-1:0]  idxF, idxE;
    logic [31:IDX_W+2] tagF, tagE;

    assign idxF = i_pcF[IDX_W+1:2];
    assign tagF = i_pcF[31:IDX_W+2];

    assign idxE = i_pcE[IDX_W+1:2];
    assign tagE = i_pcE[31:IDX_W+2];

    assign o_hitF    = btb_array[idxF].valid && (btb_array[idxF].tag == tagF);
    assign o_targetF = o_hitF ? btb_array[idxF].target : 32'b0;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (int i = 0; i < ENTRY; i++) begin
                btb_array[i].valid  <= 1'b0;
                btb_array[i].tag    <= '0;
                btb_array[i].target <= '0;
            end
        end
        else if (i_update_enE) begin
            btb_array[idxE].valid  <= 1'b1;
            btb_array[idxE].tag    <= tagE;
            btb_array[idxE].target <= i_targetE;
        end
    end

endmodule
