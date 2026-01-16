module i_decode(
    input [3:0] instruction,
    output logic i_mode,
    output logic [2:0] mux_sel
);

typedef enum logic [3:0] {
    IR_EXTEST = 4'b0000,
    IR_SAMPLE = 4'b0001,
    IR_UDR1   = 4'b0010,
    IR_UDR2   = 4'b0011,
    IR_UDR3   = 4'b0100,
    IR_UDR4   = 4'b0101,
    IR_BYPASS = 4'b1111
} ir_opcode_t;

always_comb begin
i_mode = 1'b0;
mux_sel = 3'b000; // bypass instruction

 case (instruction)

            IR_BYPASS: begin
                i_mode  = 1'b0;   // pins under BSC control
                mux_sel = 3'b000;     
                // BYPASS only
            end

            IR_EXTEST,
            IR_SAMPLE: begin
                mux_sel = 3'b101; // BOUNDARY SCAN REGISTER
                i_mode  = 1'b1;   // pins under BSC control
            end

            IR_UDR1: begin
                mux_sel = 3'b001;     
            end

            IR_UDR2: begin
                mux_sel = 3'b010;     
            end

            IR_UDR3: begin
                mux_sel = 3'b011;     
            end

            IR_UDR4: begin
                mux_sel = 3'b100;     
            end


            default: begin
                // safe fallback → BYPASS
            end
        endcase
    end
endmodule