`ifndef __decoder_5to32_V__
`define __decoder_5to32_V__

module decoder_5to32
(
    input  logic [4:0]   in, 
    input  logic         val,  
    output logic [31:0]  out
);
    logic [31:0]  out_tmp;
    always_comb begin
        casez (in)
            5'b00000: out_tmp = 32'b10000000000000000000000000000000;
            5'b00001: out_tmp = 32'b01000000000000000000000000000000;
            5'b00010: out_tmp = 32'b00100000000000000000000000000000;
            5'b00011: out_tmp = 32'b00010000000000000000000000000000;
            5'b00100: out_tmp = 32'b00001000000000000000000000000000;
            5'b00101: out_tmp = 32'b00000100000000000000000000000000;
            5'b00110: out_tmp = 32'b00000010000000000000000000000000;
            5'b00111: out_tmp = 32'b00000001000000000000000000000000;
            5'b01000: out_tmp = 32'b00000000100000000000000000000000;
            5'b01001: out_tmp = 32'b00000000010000000000000000000000;
            5'b01010: out_tmp = 32'b00000000001000000000000000000000;
            5'b01011: out_tmp = 32'b00000000000100000000000000000000;
            5'b01100: out_tmp = 32'b00000000000010000000000000000000;
            5'b01101: out_tmp = 32'b00000000000001000000000000000000;
            5'b01110: out_tmp = 32'b00000000000000100000000000000000;
            5'b01111: out_tmp = 32'b00000000000000010000000000000000;
            5'b10000: out_tmp = 32'b00000000000000001000000000000000;
            5'b10001: out_tmp = 32'b00000000000000000100000000000000;
            5'b10010: out_tmp = 32'b00000000000000000010000000000000;
            5'b10011: out_tmp = 32'b00000000000000000001000000000000;
            5'b10100: out_tmp = 32'b00000000000000000000100000000000;
            5'b10101: out_tmp = 32'b00000000000000000000010000000000;
            5'b10110: out_tmp = 32'b00000000000000000000001000000000;
            5'b10111: out_tmp = 32'b00000000000000000000000100000000;
            5'b11000: out_tmp = 32'b00000000000000000000000010000000;
            5'b11001: out_tmp = 32'b00000000000000000000000001000000;
            5'b11010: out_tmp = 32'b00000000000000000000000000100000;
            5'b11011: out_tmp = 32'b00000000000000000000000000010000;
            5'b11100: out_tmp = 32'b00000000000000000000000000001000;
            5'b11101: out_tmp = 32'b00000000000000000000000000000100;
            5'b11110: out_tmp = 32'b00000000000000000000000000000010;
            5'b11111: out_tmp = 32'b00000000000000000000000000000001;

            default:  out_tmp = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        endcase
    end

    always_comb begin
        if (val) begin
            out = out_tmp;
        end else begin
            out = 0;
        end
    end
endmodule

`endif