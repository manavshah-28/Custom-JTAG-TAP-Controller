module alu(
    input rstn,
    input [3:0] a,
    input [3:0] b,
    input [3:0] op,
    output [3:0] c
);

assign c = (op == 4'b0000) ? a + b : // add 
           (op == 4'b0001) ? a - b : // sub
           (op == 4'b0010) ? a * b : // mult 
           (op == 4'b0011) ? a / b : // div
           (op == 4'b0100) ? a << 1 : // logical left shift
           (op == 4'b0101) ? a >> 1 : // logical right shift
           (op == 4'b0110) ? a & b :  // logical and
           (op == 4'b0111) ? a | b :  // logical or   
           (op == 4'b1000) ? a ^ b :  // logical xor
           (op == 4'b1001) ? ~(a ^ b) :  // logical nor
           (op == 4'b1010) ? ~(a & b) :  // logical nand
           (op == 4'b1011) ? ~(a ^ b) :  // logical xnor
           (!rstn) ? 4'b0000 :
           4'b0000;

endmodule