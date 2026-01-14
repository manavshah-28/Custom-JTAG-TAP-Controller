module bypass_reg(
    input tck,
    input tdi,
    output tdo
);

logic bypass;

always @(posedge tck)begin
bypass <= tdi;
end

assign tdo = bypass;

endmodule