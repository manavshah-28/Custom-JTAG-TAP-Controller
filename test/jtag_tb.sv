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
@(posedge clk);
@(posedge clk);
rstn = 1;
endtask

// CUT connect
jtag_top CUT(.*);

initial begin
toggle_rstn();

repeat(25)begin
@(posedge clk);
end

$display("### EOT ###");
$finish();
end

endmodule