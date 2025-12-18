module branch_predict_unit (
    input  logic        i_clk,
    input  logic        i_rst_n,

    // ---------- IF ----------
    input  logic [31:0] i_pcF,
    input  logic [31:0] i_pc_plus4F,
    output logic [31:0] o_next_pcF,
    output logic [7:0]  o_pht_idxF,
    output logic        o_pred_takenF,
    output logic [31:0] o_pred_targetF,

    // ---------- EX (update only) ----------
    input  logic        i_is_branchE,
    input  logic        i_actual_takenE,
    input  logic [7:0]  i_pht_idxE,
    input  logic [31:0] i_pcE,
    input  logic [31:0] i_targetE
);

    // ---------------- GHR ----------------
    logic [7:0] w_ghr;
    GHR u_ghr (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_update_en(i_is_branchE),
        .i_taken(i_actual_takenE),
        .o_ghr(w_ghr)
    );

    // ---------------- PHT index (IF) ----------------
    assign o_pht_idxF = i_pcF[9:2] ^ w_ghr;

    // ---------------- PHT ----------------
    logic w_pred_takenF;
    PHT u_pht (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_idxF(o_pht_idxF),
        .o_pred_takenF(w_pred_takenF),
        .i_update_enE(i_is_branchE),
        .i_takenE(i_actual_takenE),
        .i_idxE(i_pht_idxE)
    );

    // ---------------- BTB ----------------
    logic        w_btb_hitF;
    logic [31:0] w_btb_targetF;

    BTB u_btb (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_pcF(i_pcF),
        .o_hitF(w_btb_hitF),
        .o_targetF(w_btb_targetF),
        .i_update_enE(i_is_branchE && i_actual_takenE),
        .i_pcE(i_pcE),
        .i_targetE(i_targetE)
    );

    // ---------------- Final prediction (IF) ----------------
    assign o_pred_takenF  = w_pred_takenF && w_btb_hitF;
    assign o_pred_targetF = w_btb_targetF;

    always_comb begin
        if (o_pred_takenF)
            o_next_pcF = w_btb_targetF;
        else
            o_next_pcF = i_pc_plus4F;
    end

endmodule
