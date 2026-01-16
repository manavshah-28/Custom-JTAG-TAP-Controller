module jtag_tb();

parameter int i_scan_cells = 12, o_scan_cells = 4;

logic clk;
logic rstn;
logic tdi;
logic tck;
logic tms;
logic tdo;
logic [i_scan_cells - 1 : 0] input_pins;
logic [o_scan_cells - 1 : 0] output_pins;
logic trst;

// clocking
initial begin
tck = 0;
forever #5 tck = ~tck;
end

initial begin
clk = 0;
forever #5 clk = ~clk;
end

// reset 
task toggle_rstn();
rstn = 0;
trst = 0;
@(posedge tck);
@(posedge tck);
rstn = 1;
trst = 1;
endtask

int i;

// CUT connect
jtag_top jtag_top(.*);

logic [8:0] tdi_seq = 'b101010101;
logic [22:0] tms_seq = 'b11111000000111000000110;
initial begin
toggle_rstn();
tms = 0;
tdi = 1;
i = 0;
repeat(25)begin
@(posedge tck);
tms = tms_seq[i];
tdi = ~tdi;
i++;
$display("state = %0s ", jtag_top.tap.curr_state.name());
end

$display("### EOT ###");
$finish();
end

endmodule