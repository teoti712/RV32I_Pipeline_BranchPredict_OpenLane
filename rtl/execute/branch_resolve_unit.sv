module branch_resolve_unit (
    input  logic        i_is_branchE,

    input  logic        i_pred_takenE,
    input  logic [31:0] i_pred_targetE,

    input  logic        i_actual_takenE,
    input  logic [31:0] i_actual_targetE,
    input  logic [31:0] i_pc_plus4E,

    output logic        o_mispredE,
    output logic [31:0] o_correct_pcE
);
    always_comb begin
        // defaults
        o_mispredE   = 1'b0;
        o_correct_pcE = 32'b0;

        if (i_is_branchE) begin
            if (i_pred_takenE != i_actual_takenE) begin
                o_mispredE = 1'b1;
                o_correct_pcE =
                    i_actual_takenE ? i_actual_targetE
                                     : i_pc_plus4E;
            end
            else if (i_pred_takenE && i_actual_takenE &&
                     i_pred_targetE != i_actual_targetE) begin
                o_mispredE   = 1'b1;
                o_correct_pcE = i_actual_targetE;
            end
        end
    end
endmodule
