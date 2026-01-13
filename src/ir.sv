module ir(
    input tck,
    input tdi,
    input shift_ir,
    input capture_ir,
    input update_ir,

    output tdo,
    output logic [3:0] instruction
);

logic [3:0] shift_reg;
logic [3:0] hold_reg;

always @(posedge tck) begin
if(shift_ir)begin
shift_reg[0] <= tdi;
shift_reg <= (shift_reg << 1); 
end 
if(capture_ir)begin
hold_reg <= shift_reg;
end
end

assign instruction = (update_ir) ? hold_reg : 4'd0;

endmodule