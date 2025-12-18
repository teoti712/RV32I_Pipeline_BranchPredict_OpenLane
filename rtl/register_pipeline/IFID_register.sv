module IFID_register(
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_flushD,
    input  logic        i_stallD,
    input  logic [31:0] i_instF,
    input  logic [31:0] i_pcF,
    input  logic [31:0] i_pc_plus4F,

    output logic [31:0] o_instD,
    output logic [31:0] o_pcD,
    output logic [31:0] o_pc_plus4D,
    //branch_predictor_unit_signal
    input  logic [7:0]  i_pht_idxF,
    input  logic        i_pred_takenF,
    input  logic [31:0] i_pred_targetF,

    output logic [7:0]  o_pht_idxD,
    output logic        o_pred_takenD,
    output logic [31:0] o_pred_targetD
);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_instD        <= 32'b0;
            o_pcD          <= 32'b0;
            o_pc_plus4D    <= 32'b0;
            //
            o_pht_idxD     <= 8'b0;
            o_pred_takenD  <= 1'b0;
            o_pred_targetD <= 32'b0;
        end
        else if (i_flushD) begin
            o_instD        <= 32'b0;
            o_pcD          <= 32'b0;
            o_pc_plus4D    <= 32'b0;
            //
            o_pht_idxD     <= 8'b0;
            o_pred_takenD  <= 1'b0;
            o_pred_targetD <= 32'b0;            
        end
        else if (i_stallD) begin
            o_instD        <= o_instD;
            o_pcD          <= o_pcD;
            o_pc_plus4D    <= o_pc_plus4D;
            //
            o_pht_idxD     <= o_pht_idxD;
            o_pred_takenD  <= o_pred_takenD;
            o_pred_targetD <= o_pred_targetD;
        end
        else begin
            o_instD        <= i_instF;
            o_pcD          <= i_pcF;
            o_pc_plus4D    <= i_pc_plus4F;  
            //  
            o_pht_idxD     <= i_pht_idxF;
            o_pred_takenD  <= i_pred_takenF;
            o_pred_targetD <= i_pred_targetF;        
        end

    end

endmodule
