module mux(
    input a,b,
    input sel,
    output c
);

assign c = (sel) ? b : a;

endmodule

module ibsc(
    input i_pin,
    input i_shift_dr,
    input i_last_cell,
    input clk_dr,
    input update_dr,
    input i_mode,

    input trst,

    output logic o_logic,
    output logic o_next_cell
);

// tracking states of operation
typedef enum logic [1:0] {
    normal,
    scan,
    update,
    capture
} bsc_states;

bsc_states curr_state;
always_comb begin
if(i_mode == 1'b0) curr_state = normal;
else if (i_shift_dr == 1'b1) curr_state = scan;
else if (i_mode == 1'b1) curr_state = update;
else if (i_shift_dr == 1'b0) curr_state = capture;
end

always @(posedge clk_dr) begin
if (curr_state == normal) begin 
    assert(i_pin == o_logic) 
    else $error("normal state output not equal to input");
end
end

logic capture_ff;
logic output_ff;

logic m1_out;

mux m1(
    .a(i_pin),
    .b(i_last_cell),
    .sel(i_shift_dr),
    .c(m1_out)
);

always @(posedge clk_dr or negedge trst)begin
if(!trst) begin
capture_ff <= 0;
end
else begin
capture_ff <= m1_out;
end
end

always @(posedge update_dr or negedge trst)begin
if(!trst) begin
output_ff <= 0;
end
else begin
output_ff <= capture_ff;
end
end

assign o_next_cell = capture_ff;

mux m2(
    .a(i_pin),
    .b(output_ff),
    .sel(i_mode),
    .c(o_logic)
);

endmodule

module obsc(
    output o_pin,
    input i_shift_dr,
    input i_last_cell,
    input clk_dr,
    input update_dr,
    input i_mode,

    input trst,

    input i_logic,
    output o_next_cell
);

logic capture_ff;
logic output_ff;

logic m1_out;

mux m1(
    .a(i_logic),
    .b(i_last_cell),
    .sel(i_shift_dr),
    .c(m1_out)
);

always @(posedge clk_dr)begin
if(!trst) begin
capture_ff <= 0;
end
else begin
capture_ff <= m1_out;
end
end

always @(posedge update_dr)begin
if(!trst) begin
output_ff <= 0;
end
else begin
output_ff <= capture_ff;
end
end

assign o_next_cell = capture_ff;

mux m2(
    .a(i_logic),
    .b(output_ff),
    .sel(i_mode),
    .c(o_pin)
);

endmodule