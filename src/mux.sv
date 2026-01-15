module data_demux(
input tdi,
input [2:0] data_demux_sel,
output demux_br,
output demux_udr1,
output demux_udr2,
output demux_udr3,
output demux_udr4
);

assign demux_br   = (data_demux_sel == 3'b000) ? tdi : 0;
assign demux_udr1 = (data_demux_sel == 3'b001) ? tdi : 0;
assign demux_udr2 = (data_demux_sel == 3'b010) ? tdi : 0;
assign demux_udr3 = (data_demux_sel == 3'b011) ? tdi : 0;
assign demux_udr4 = (data_demux_sel == 3'b100) ? tdi : 0;

endmodule

module data_mux(

input mux_br,
input mux_udr1,
input mux_udr2,
input mux_udr3,
input mux_udr4,
input [2:0] data_mux_sel,

output data_mux_tdo
);

assign data_mux_tdo = (data_mux_sel == 3'b000) ? mux_br   :
                      (data_mux_sel == 3'b001) ? mux_udr1 :
                      (data_mux_sel == 3'b010) ? mux_udr2 :
                      (data_mux_sel == 3'b011) ? mux_udr3 :
                      (data_mux_sel == 3'b100) ? mux_udr4 :
                      0;

endmodule

module tap_i_mux(
input tdi,
input i_mux_sel,
output inst_tdi,
output data_tdi
);

assign inst_tdi = (i_mux_sel) ? tdi : 0;
assign data_tdi = (!i_mux_sel) ? tdi : 0;

endmodule

module tap_o_mux(
input o_mux_sel,
input inst_tdi,
input data_tdi,
output tdo
);

assign tdo = (o_mux_sel) ? inst_tdi : data_tdi;

endmodule