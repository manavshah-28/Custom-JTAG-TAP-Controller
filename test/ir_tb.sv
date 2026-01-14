class random_tdi;
rand bit r_tdi;
endclass

module ir_tb();

logic tck;
logic tdi;
logic shift_ir;
logic capture_ir;
logic update_ir;

logic tdo; 
logic [3:0] instruction;

// connect dut
ir dut(.*);

initial begin
tck = 0;
forever #5 tck = ~ tck;
end

initial begin
random_tdi seq;
seq = new();
repeat(10) begin
assert(seq.randomize());
shift_ir = 1;
@(posedge tck);
tdi = seq.r_tdi;
$display("tdi = %0b, shift_ir = %0b, update_ir = %0b, shift reg = %0b, hold_reg = %0b", tdi, shift_ir, update_ir, dut.shift_reg, dut.hold_reg);
end

@(posedge tck);
update_ir = 1;
shift_ir = 0;
@(posedge tck);
$display("tdi = %0b, shift_ir = %0b, update_ir = %0b, shift reg = %0b, hold_reg = %0b", tdi, shift_ir, update_ir, dut.shift_reg, dut.hold_reg);

@(posedge tck);
$display("tdi = %0b, shift_ir = %0b, update_ir = %0b, shift reg = %0b, hold_reg = %0b", tdi, shift_ir, update_ir, dut.shift_reg, dut.hold_reg);

$finish();
end

endmodule