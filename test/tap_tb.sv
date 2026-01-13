class tms_sequencer;
rand bit [9:0] tms_sequence;

constraint c_dist{
    tms_sequence dist {
      10'b0000000000 := 25,
      10'b1111111111 := 25,
      10'b1010101010 := 50
    };
}
endclass


module tap_tb();

logic TCK;
logic TMS;
logic TRST;

// connect DUT
TAP DUT(.*);

initial begin
    TCK = 0;
    forever #5 TCK = ~ TCK;
end

task toggle_rst();
TRST = 0;
repeat(2) @(posedge TCK);
TRST = 1;
endtask

logic [9:0] sequenced;

initial begin
tms_sequencer seq;

toggle_rst();

seq = new();
  repeat (20) begin
    
    // randomize the 10 bit sequence
    assert(seq.randomize());
    $display("%b", seq.tms_sequence);

    // shift out the sequence on TMS wire
    for(int i = 0; i < 10; i ++) begin
        @(negedge TCK) TMS = seq.tms_sequence[i];
        @(posedge TCK) $display("TMS = %0h, current = %0h, next = %0h", seq.tms_sequence[i], DUT.curr_state.name(), DUT.next_state.name());
    end
  end
  $finish();
end
endmodule