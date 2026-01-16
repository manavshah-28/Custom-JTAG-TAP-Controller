// USER DATA REGISTERS
// used to control and observe internal registers/ports inside the core logic
// each of these UDR's have a shift in register and a hold register.
// hold registers store the previous data and the shift registers are used to shift in the next data without affecting the stored data.

module user_dr #(parameter dr1_width = 4, dr2_width = 4, dr3_width = 4, dr4_width = 4)(
    input tck,
    input demux_udr1,
    input demux_udr2,
    input demux_udr3,
    input demux_udr4,

    input capture_dr,
    input shift_dr,
    input update_dr,

    output dr1_dout,
    output dr2_dout,
    output dr3_dout,
    output dr4_dout

);

// data registers
logic [dr1_width-1:0] dr1;
logic [dr2_width-1:0] dr2;
logic [dr3_width-1:0] dr3;
logic [dr4_width-1:0] dr4;

// data registers
logic [dr1_width-1:0] dr1_hold;
logic [dr2_width-1:0] dr2_hold;
logic [dr3_width-1:0] dr3_hold;
logic [dr4_width-1:0] dr4_hold;

always @(posedge tck)begin

if(shift_dr) begin
    dr1 <= {dr1[dr1_width-2:0],demux_udr1};    
    dr2 <= {dr2[dr2_width-2:0],demux_udr2};
    dr3 <= {dr3[dr3_width-2:0],demux_udr3};
    dr4 <= {dr4[dr4_width-2:0],demux_udr4};

end
else if(update_dr) begin
    dr1_hold <= dr1;
    dr2_hold <= dr2;
    dr3_hold <= dr3;
    dr4_hold <= dr4;
end
end


endmodule