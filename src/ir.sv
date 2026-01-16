module ir(
    input tck,
    input tdi,
    input shift_ir,
    input capture_ir,
    input update_ir,

    output instr_reg_tdo,
    output logic [3:0] instruction
);

logic [3:0] shift_reg;
logic [3:0] hold_reg;

initial begin 
shift_reg <= 4'b0;
hold_reg <= 4'b0;
end

always @(posedge tck) begin
if(shift_ir)begin
shift_reg <= {shift_reg[2:0], tdi};
end 
else if(update_ir)begin
hold_reg <= shift_reg;
end
end

assign instr_reg_tdo = shift_reg[3];
assign instruction =  hold_reg;

endmodule