class signal_rand;
rand bit i_shift_dr;
rand bit i_pin;
rand bit i_last_cell;
rand bit i_mode;
endclass

module bsc_tb();

logic i_pin;
logic i_shift_dr;
logic i_last_cell;
logic clk_dr;
logic update_dr;
logic i_mode;
logic trst;
logic o_logic;
logic o_next_cell;

ibsc dut(.*);

task toggle_rst();
trst = 0;
repeat(2) @(posedge clk_dr);
trst = 1;
endtask

initial begin
clk_dr <= 0;
update_dr <= 0;
forever #5 clk_dr = ~clk_dr;
forever #5 update_dr = ~update_dr;
end

initial begin
signal_rand sig;
toggle_rst();

sig = new();

repeat(20) begin
    assert(sig.randomize());

    @(posedge clk_dr) begin
        i_pin = sig.i_pin;
        i_shift_dr = sig.i_shift_dr;
        i_last_cell = sig.i_last_cell;
        i_mode = sig.i_mode;
    end
    @(posedge clk_dr);
    @(posedge clk_dr);
    @(posedge clk_dr) $display("state = %0h, pin input = %0b, last cell = %0b, shiftdr = %0b, clockdr = %0b, updatedr = %0b, to next cell = %0b, mode = %0b, to logic = %0b", dut.curr_state.name(), i_pin, i_last_cell, i_shift_dr, clk_dr, update_dr, o_next_cell, i_mode, o_logic);
end
$finish;
end

endmodule