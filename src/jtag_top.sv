module jtag_top #(
    parameter int i_scan_cells = 12, o_scan_cells = 4
)(

input clk,
input rstn,

// tap signals
input tdi,
input tck,
input tms,
input trst,
output tdo,

// input pins
input logic [i_scan_cells - 1 : 0]  input_pins, 

// output pins
output logic [o_scan_cells - 1 : 0] output_pins

);

// BOUNDARY SCAN 
logic [i_scan_cells - 1 : 0]  input_sampled_pins; 
logic [o_scan_cells - 1 : 0]  output_sampled_pins;
logic [i_scan_cells : 0] i_scan_chains;
logic [o_scan_cells : 0] o_scan_chains;


logic clk_dr, update_dr, i_mode;
logic o_shift_ir, o_capture_ir, o_update_ir, o_shift_dr, o_capture_dr, o_update_dr;

logic boundary_scan_input;
logic boundary_scan_output;

// USER DATA REGISTER wires
logic dr1_dout, dr2_dout, dr3_dout, dr4_dout;

logic [2:0] data_demux_sel;
logic demux_br, demux_udr1, demux_udr2, demux_udr3, demux_udr4;

logic i_mux_sel; // 0 or 1
logic inst_tdi, data_tdi;



logic mux_br, mux_udr1, mux_udr2, mux_udr3, mux_udr4;
logic [2:0] data_mux_sel;
logic data_mux_tdo;

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

assign o_scan_chains[0] = i_scan_chains[12];
assign i_scan_chains[0] = boundary_scan_input;
assign boundary_scan_output = o_scan_chains[4];

// submodule declarations

// ALU CUT
alu cut (
    .rstn(rstn),
    .a(input_sampled_pins[11:8]),
    .b(input_sampled_pins[7:4]),
    .op(input_sampled_pins[3:0]),
    .c(output_sampled_pins[3:0])
);

// TAP controller
tap tap(
    .tck(tck),
    .tms(tms),
    .trst(trst),
    .o_shift_ir(o_shift_ir),
    .o_capture_ir(o_capture_ir),
    .o_update_ir(o_update_ir),
    .o_shift_dr(o_shift_dr),
    .o_capture_dr(o_capture_dr),
    .o_update_dr(o_update_dr),
    .d_mux_sel(i_mux_sel)
);

// USER DATA REGISTERS
user_dr data_reg(
    .tck(tck),
    .demux_udr1(demux_udr1),
    .demux_udr2(demux_udr2),
    .demux_udr3(demux_udr3),
    .demux_udr4(demux_udr4),
    .capture_dr(o_capture_dr),
    .shift_dr(o_shift_dr),
    .update_dr(o_update_dr),

    .dr1_dout(mux_udr1),
    .dr2_dout(mux_udr2),
    .dr3_dout(mux_udr3),
    .dr4_dout(mux_udr4)
);

// INSTRUCTION REGISTER
ir instruction_reg(
    .tck(tck),
    .tdi(tdi),
    .shift_ir(o_shift_ir),
    .capture_ir(o_capture_dr),
    .update_ir(o_update_ir),
    .instr_reg_tdo(instr_reg_tdo), // connects to mux
    .instruction(instruction)
);

bypass_reg byp_reg(
    .tck(tck),
    .tdi(demux_br),
    .tdo(mux_br) // connects to mux
);

// connection Demux and Mux's
tap_i_mux tap_demux(
.tdi(tdi),
.i_mux_sel(i_mux_sel),
.inst_tdi(inst_tdi),
.data_tdi(data_tdi)
);
//

data_demux d_demux(
 .tdi(data_tdi),
 .data_demux_sel(data_demux_sel),
 .boundary_scan_input(boundary_scan_input),
 .demux_br(demux_br),
 .demux_udr1(demux_udr1),
 .demux_udr2(demux_udr2),
 .demux_udr3(demux_udr3),
 .demux_udr4(demux_udr4)
);
//

data_mux d_mux(
 .boundary_scan_output(boundary_scan_output),
 .mux_br(mux_br),
 .mux_udr1(mux_udr1),
 .mux_udr2(mux_udr2),
 .mux_udr3(mux_udr3),
 .mux_udr4(mux_udr4),
 .data_mux_sel(data_demux_sel),
 .data_mux_tdo(data_mux_tdo)
);

tap_o_mux tap_mux(
 .o_mux_sel(i_mux_sel),
 .inst_tdi(instr_reg_tdo),
 .data_tdi(data_mux_tdo),
 .tdo(tdo)
);

i_decode instr_decoder(
    .instruction(instruction),
    .i_mode(i_mode),
    .mux_sel(data_demux_sel)
);

endmodule