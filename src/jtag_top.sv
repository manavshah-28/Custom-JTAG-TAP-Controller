module jtag_top #(
    parameter int i_scan_cells = 12, o_scan_cells = 4
)(

input clk,
input rstn,

// tap signals
input tdi,
input tck,
input tms,
output tdo,

// input pins
input logic [i_scan_cells - 1 : 0]  input_pins, 

// output pins
output logic [o_scan_cells - 1 : 0] output_pins

);
 
logic [i_scan_cells - 1 : 0]  input_sampled_pins; 
logic [o_scan_cells - 1 : 0]  output_sampled_pins;

logic clk_dr, update_dr, i_mode, trst;
logic o_shift_ir, o_capture_ir, o_update_ir, o_shift_dr, o_capture_dr, o_update_dr;

// USER DATA REGISTER wires
logic [3:0] dr1_din, dr2_din,dr3_din,dr4_din;
logic [3:0] dr1_dout, dr2_dout, dr3_dout, dr4_dout;
logic [1:0] sel;

logic [i_scan_cells : 0] i_scan_chains;
logic [o_scan_cells : 0] o_scan_chains;

// INSTRUCTION REGISTER
logic [3:0]instruction;

// BSR : BOUNDARY SCAN REGISTERS
genvar i;

generate 

for(i = 0; i < i_scan_cells; i++)begin : gen_ibsc
ibsc p_iubsc(
    .i_pin(input_pins[i]),
    .i_shift_dr(o_shift_dr),
    .i_last_cell(i_scan_chains[i]),
    .clk_dr(clk_dr),
    .update_dr(o_update_dr),
    .i_mode(i_mode),
    .trst(trst),
    .o_logic(input_sampled_pins[i]),
    .o_next_cell(i_scan_chains[i+1])
);
end
endgenerate

generate

for(i = 0; i < o_scan_cells; i++)begin : gen_obsc
obsc p_iubsc(
    .o_pin(output_pins[i]),
    .i_shift_dr(o_shift_dr),
    .i_last_cell(o_scan_chains[i]),
    .clk_dr(clk_dr),
    .update_dr(o_update_dr),
    .i_mode(i_mode),
    .trst(trst),
    .i_logic(output_sampled_pins[i]),
    .o_next_cell(o_scan_chains[i+1])
);
end
endgenerate

// submodule declarations

// ALU CUT
alu cut (
    .clk(clk),
    .rstn(rstn),
    .a(input_sampled_pins[11:8]),
    .b(input_sampled_pins[7:4]),
    .op(input_sampled_pins[3:0]),
    .c(output_sampled_pins[3:0])
);

// TAP controller
tap tap_controller(
    .tck(tck),
    .tms(tms),
    .trst(trst),
    .o_shift_ir(o_shift_ir),
    .o_capture_ir(o_capture_ir),
    .o_update_ir(o_update_ir),
    .o_shift_dr(o_shift_dr),
    .o_capture_dr(o_capture_dr),
    .o_update_dr(o_update_dr)
);

// USER DATA REGISTERS
user_dr data_reg(
    .tck(tck),
    .tdi(tdi),
    .sel(sel), // select one of the 4 data registers to which tdi/tdo will connect
    .capture_dr(o_capture_dr),
    .shift_dr(o_shift_dr),
    .update_dr(o_update_dr),

    .dr1_din(dr1_din),
    .dr2_din(dr2_din),
    .dr3_din(dr3_din),
    .dr4_din(dr4_din),

    .tdo(tdo),
    .dr1_dout(dr1_dout),
    .dr2_dout(dr2_dout),
    .dr3_dout(dr3_dout),
    .dr4_dout(dr4_dout)
);

// INSTRUCTION REGISTER
ir instruction_reg(
    .tck(tck),
    .tdi(tdi),
    .shift_ir(o_shift_ir),
    .capture_ir(o_capture_dr),
    .update_ir(o_update_ir),
    .tdo(tdo),
    .instruction(instruction)
);

bypass_reg byp_reg(
    .tck(tck),
    .tdi(tdi),
    .tdo(tdo)
);

endmodule