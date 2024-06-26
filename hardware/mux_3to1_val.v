`ifndef __mux_3to1_val_V__
`define __mux_3to1_val_V__

module mux_3to1_val
#(
    parameter DATA_WIDTH = 8
) (
    input  logic [DATA_WIDTH-1:0]  vec [2:0], 
    input  logic [1:0]             sel,   
    input  logic                   val, 
    output logic [DATA_WIDTH-1:0]  out
);

    logic [DATA_WIDTH-1:0]  out_tmp;
    always_comb begin
        case (sel)
            2'b00:   out_tmp = vec[0];
            2'b01:   out_tmp = vec[1];
            2'b10:   out_tmp = vec[2];
            default: out_tmp = {DATA_WIDTH{1'bx}};
        endcase
    end

    always_comb begin
        if ( val ) begin
            out = out_tmp;
        end else begin
            out = 0;
        end
    end



endmodule

`endif