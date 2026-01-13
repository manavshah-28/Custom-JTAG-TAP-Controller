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

logic tck;
logic tms;
logic trst;

// connect DUT
tap DUT(.*);

initial begin
    tck = 0;
    forever #5 tck = ~ tck;
end

task toggle_rst();
trst = 0;
repeat(2) @(posedge tck);
trst = 1;
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

    // shift out the sequence on tms wire
    for(int i = 0; i < 10; i ++) begin
        @(negedge tck) tms = seq.tms_sequence[i];
        @(posedge tck) $display("tms = %0h, current = %0h, next = %0h", seq.tms_sequence[i], DUT.curr_state.name(), DUT.next_state.name());
    end
  end
  $finish();
end
endmodule