module PHT #(
    parameter ENTRY = 256
)(
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    // Fetch
    input  logic [$clog2(ENTRY)-1:0] i_idxF,
    output logic                     o_pred_takenF,
    // Execute
    input  logic                     i_update_enE,
    input  logic                     i_takenE,
    input  logic [$clog2(ENTRY)-1:0] i_idxE
);

    logic [1:0] pht_array [ENTRY];

    assign o_pred_takenF = pht_array[i_idxF][1];
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (int i = 0; i < ENTRY; i++)
                pht_array[i] <= 2'b01; 
        end
        else if (i_update_enE) begin
            if (i_takenE) begin
                if (pht_array[i_idxE] != 2'b11)
                    pht_array[i_idxE] <= pht_array[i_idxE] + 2'd1;
            end
            else begin
                if (pht_array[i_idxE] != 2'b00)
                    pht_array[i_idxE] <= pht_array[i_idxE] - 2'd1;
            end
        end
    end

endmodule
