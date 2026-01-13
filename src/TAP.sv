module TAP(
    input TCK,
    input TMS,
    input TRST
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

always_ff @(posedge TCK or negedge TRST)begin
    if(!TRST) begin 
        curr_state <= test_logic_reset;
    end
    else begin
        curr_state <= next_state;
    end
end

always_comb begin
//curr_state = next_state;
    case (curr_state)
    test_logic_reset : next_state = (TMS) ? test_logic_reset : run_idle;
    run_idle : next_state = (TMS) ? select_dr_scan : run_idle;
    
    select_dr_scan : next_state = (TMS) ? select_ir_scan : capture_dr;
    capture_dr : next_state = (TMS) ? exit1_dr : shift_dr;
    shift_dr :  next_state = (TMS) ? exit1_dr : shift_dr;
    exit1_dr : next_state = (TMS) ? update_dr : pause_dr;
    pause_dr : next_state = (TMS) ? exit2_dr : pause_dr;
    exit2_dr : next_state = (TMS) ? update_dr : shift_dr;
    update_dr : next_state = (TMS) ? select_dr_scan : run_idle;

    select_ir_scan : next_state = (TMS) ? test_logic_reset : capture_ir;
    capture_ir : next_state = (TMS) ? exit1_ir : shift_ir;
    shift_ir : next_state = (TMS) ? exit1_ir : shift_ir;
    exit1_ir : next_state = (TMS) ? update_ir : pause_ir;
    pause_ir : next_state = (TMS) ? exit2_ir : pause_ir;
    exit2_ir : next_state = (TMS) ? update_ir : shift_ir;
    update_ir : next_state = (TMS) ? select_dr_scan : run_idle;

    endcase
end
endmodule