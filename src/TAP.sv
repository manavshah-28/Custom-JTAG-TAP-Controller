module tap(
    input tck,
    input tms,
    input trst,

    output o_shift_ir,
    output o_capture_ir,
    output o_update_ir,

    output o_shift_dr,
    output o_capture_dr,
    output o_update_dr,

    output d_mux_sel
);

// 16 state FSM
typedef enum logic [$clog2(16):0] {
    test_logic_reset,
    run_idle,

    select_dr_scan,
    capture_dr,
    shift_dr,
    exit1_dr,
    pause_dr,
    exit2_dr,
    update_dr,

    select_ir_scan,
    capture_ir,
    shift_ir,
    exit1_ir,
    pause_ir,
    exit2_ir,
    update_ir

} tap_states;

tap_states curr_state, next_state;

always_ff @(posedge tck or negedge trst)begin
    if(!trst) begin 
        curr_state <= test_logic_reset;
    end
    else begin
        curr_state <= next_state;
    end
end

always_comb begin
//curr_state = next_state;
    case (curr_state)
    test_logic_reset : next_state = (tms) ? test_logic_reset : run_idle;
    run_idle : next_state = (tms) ? select_dr_scan : run_idle;
    
    select_dr_scan : next_state = (tms) ? select_ir_scan : capture_dr;
    capture_dr : next_state = (tms) ? exit1_dr : shift_dr;
    shift_dr :  next_state = (tms) ? exit1_dr : shift_dr;
    exit1_dr : next_state = (tms) ? update_dr : pause_dr;
    pause_dr : next_state = (tms) ? exit2_dr : pause_dr;
    exit2_dr : next_state = (tms) ? update_dr : shift_dr;
    update_dr : next_state = (tms) ? select_dr_scan : run_idle;

    select_ir_scan : next_state = (tms) ? test_logic_reset : capture_ir;
    capture_ir : next_state = (tms) ? exit1_ir : shift_ir;
    shift_ir : next_state = (tms) ? exit1_ir : shift_ir;
    exit1_ir : next_state = (tms) ? update_ir : pause_ir;
    pause_ir : next_state = (tms) ? exit2_ir : pause_ir;
    exit2_ir : next_state = (tms) ? update_ir : shift_ir;
    update_ir : next_state = (tms) ? select_dr_scan : run_idle;

    endcase
end

assign o_shift_ir = (curr_state == shift_ir) ? 1 : 0;
assign o_capture_ir = (curr_state == capture_ir) ? 1 : 0;
assign o_update_ir = (curr_state == update_ir) ? 1 : 0;
assign o_shift_dr = (curr_state == shift_dr) ? 1 : 0;
assign o_capture_dr = (curr_state == capture_dr) ? 1 : 0;
assign o_update_dr = (curr_state == update_dr) ? 1 : 0;
assign d_mux_sel = (curr_state == shift_dr) ? 0 : 
                   (curr_state == shift_ir) ? 1 : 
                   0;  
endmodule