`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/11 19:26:51
// Design Name: 
// Module Name: fp16_add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//float adder adds floating point numbers.
module fp16_add(num1, num2, result, overflow, zero, NaN, precisionLost);
  //Ports
  input [15:0] num1, num2;
  output [15:0] result;
  output overflow; //overflow flag
  output zero; //zero flag
  output NaN; //Not a Number flag
  output reg precisionLost;
  //Reassing numbers as big and small
  reg [15:0] bigNum, smallNum; //to seperate big and small numbers
  //Decode big and small number
  wire [9:0] big_fra, small_fra; //to hold fraction part
  wire [4:0] big_ex_pre, small_ex_pre;
  wire [4:0] big_ex, small_ex; //to hold exponent part
  wire big_sig, small_sig; //to hold signs
  wire [10:0] big_float, small_float; //to hold as float number with integer
  reg [10:0] sign_small_float, shifted_small_float; //preparing small float
  wire [4:0] ex_diff; //difrence between exponentials
  reg [9:0] sum_shifted; //Shift fraction part of sum
  reg [3:0] shift_am;
  wire neg_exp;
  //Extensions for higher precision
  reg [9:0] small_extension;
  wire [9:0] sum_extension;

  wire [10:0] sum; //sum of numbers with integer parts
  wire sum_carry;
  wire sameSign;
  wire zeroSmall;
  wire inf_num; //at least on of the operands is inf.

  wire [4:0] res_exp_same_s, res_exp_diff_s;
  
  //Flags
  assign zero = (num1[14:0] == num2[14:0]) & (~num1[15] == num2[15]);
  assign overflow = ((&big_ex[4:1] & ~big_ex[0]) & sum_carry & sameSign) | inf_num;
  assign NaN = (&num1[14:10] & |num1[9:0]) | (&num2[14:10] & |num2[9:0]);
  assign inf_num = (&num1[14:10] & ~|num1[9:0]) | (&num2[14:10] & ~|num2[9:0]); //check for infinate number
  //Get result
  assign result[15] = big_sig; //result sign same as big sign
  assign res_exp_same_s = big_ex + {4'd0, (~zeroSmall & sum_carry & sameSign)} - {4'd0,({1'b0,result[9:0]} == sum)};
  assign res_exp_diff_s = (neg_exp | (shift_am == 4'd10)) ? 5'd0 : (~shift_am + big_ex + 5'd1);
  assign result[14:10] = ((sameSign) ? res_exp_same_s : res_exp_diff_s) | {5{overflow}}; //result exponent
  assign result[9:0] = ((zeroSmall) ? big_fra : ((sameSign) ? ((sum_carry) ? sum[10:1] : sum[9:0]) : ((neg_exp) ? 10'd0 : sum_shifted))) & {10{~overflow}};

  //decode numbers
  assign {big_sig, big_ex_pre, big_fra} = bigNum;
  assign {small_sig, small_ex_pre, small_fra} = smallNum;
  assign sameSign = (big_sig == small_sig);
  assign zeroSmall = ~(|small_ex | |small_fra);
  assign big_ex = big_ex_pre + {4'd0, ~|big_ex_pre};
  assign small_ex = small_ex_pre + {4'd0, ~|small_ex_pre};

  //add integer parts
  assign big_float = {|big_ex_pre, big_fra};
  assign small_float = {|small_ex_pre, small_fra};
  assign ex_diff = big_ex - small_ex; //diffrence between exponents
  assign {sum_carry, sum} = sign_small_float + big_float; //add numbers
  assign sum_extension = small_extension;

  //Get shift amount for subtraction
  assign neg_exp = (big_ex < shift_am);
  always@*
    begin
      casex(sum)
        11'b1xxxxxxxxxx: shift_am = 4'd0;
        11'b01xxxxxxxxx: shift_am = 4'd1;
        11'b001xxxxxxxx: shift_am = 4'd2;
        11'b0001xxxxxxx: shift_am = 4'd3;
        11'b00001xxxxxx: shift_am = 4'd4;
        11'b000001xxxxx: shift_am = 4'd5;
        11'b0000001xxxx: shift_am = 4'd6;
        11'b00000001xxx: shift_am = 4'd7;
        11'b000000001xx: shift_am = 4'd8;
        11'b0000000001x: shift_am = 4'd9;
        default: shift_am = 4'd10;
      endcase
    end

  //Shift result for sub.
  always@* 
    begin
      case (shift_am)
        4'd0: sum_shifted =  sum[9:0];
        4'd1: sum_shifted = {sum[8:0],sum_extension[9]};
        4'd2: sum_shifted = {sum[7:0],sum_extension[9:8]};
        4'd3: sum_shifted = {sum[6:0],sum_extension[9:7]};
        4'd4: sum_shifted = {sum[5:0],sum_extension[9:6]};
        4'd5: sum_shifted = {sum[4:0],sum_extension[9:5]};
        4'd6: sum_shifted = {sum[3:0],sum_extension[9:4]};
        4'd7: sum_shifted = {sum[2:0],sum_extension[9:3]};
        4'd8: sum_shifted = {sum[1:0],sum_extension[9:2]};
        4'd9: sum_shifted = {sum[0],  sum_extension[9:1]};
        default: sum_shifted = sum_extension;
      endcase
      case (shift_am)
        4'd0: precisionLost = |sum_extension;
        4'd1: precisionLost = |sum_extension[8:0];
        4'd2: precisionLost = |sum_extension[7:0];
        4'd3: precisionLost = |sum_extension[6:0];
        4'd4: precisionLost = |sum_extension[5:0];
        4'd5: precisionLost = |sum_extension[4:0];
        4'd6: precisionLost = |sum_extension[3:0];
        4'd7: precisionLost = |sum_extension[2:0];
        4'd8: precisionLost = |sum_extension[1:0];
        4'd9: precisionLost = |sum_extension[0];
        default: precisionLost = 1'b0;
      endcase
    end

  //take small number to exponent of big number
  always@* 
    begin
      case (ex_diff)
        5'h0: {shifted_small_float,small_extension} = {small_float,10'd0};
        5'h1: {shifted_small_float,small_extension} = {small_float,9'd0};
        5'h2: {shifted_small_float,small_extension} = {small_float,8'd0};
        5'h3: {shifted_small_float,small_extension} = {small_float,7'd0};
        5'h4: {shifted_small_float,small_extension} = {small_float,6'd0};
        5'h5: {shifted_small_float,small_extension} = {small_float,5'd0};
        5'h6: {shifted_small_float,small_extension} = {small_float,4'd0};
        5'h7: {shifted_small_float,small_extension} = {small_float,3'd0};
        5'h8: {shifted_small_float,small_extension} = {small_float,2'd0};
        5'h9: {shifted_small_float,small_extension} = {small_float,1'd0};
        5'ha: {shifted_small_float,small_extension} = small_float;
        5'hb: {shifted_small_float,small_extension} = small_float[10:1];
        5'hc: {shifted_small_float,small_extension} = small_float[10:2];
        5'hd: {shifted_small_float,small_extension} = small_float[10:3];
        5'he: {shifted_small_float,small_extension} = small_float[10:4];
        5'hf: {shifted_small_float,small_extension} = small_float[10:5];
        5'h10: {shifted_small_float,small_extension} = small_float[10:5];
        5'h11: {shifted_small_float,small_extension} = small_float[10:6];
        5'h12: {shifted_small_float,small_extension} = small_float[10:7];
        5'h13: {shifted_small_float,small_extension} = small_float[10:8];
        5'h14: {shifted_small_float,small_extension} = small_float[10:9];
        5'h15: {shifted_small_float,small_extension} = small_float[10];
        5'h16: {shifted_small_float,small_extension} = 0;
      endcase
    end

  always@* //if signs are diffrent take 2s compliment of small number
    begin
      if(sameSign)
        begin
          sign_small_float = shifted_small_float;
        end
      else
        begin
          sign_small_float = ~shifted_small_float + 11'b1;
        end
    end

  always@* //determine big number
    begin
      if(num2[14:10] > num1[14:10])
        begin
          bigNum = num2;
          smallNum = num1;
        end
      else if(num2[14:10] == num1[14:10])
        begin
          if(num2[9:0] > num1[9:0])
            begin
              bigNum = num2;
              smallNum = num1;
            end
          else
            begin
              bigNum = num1;
              smallNum = num2;
            end
        end
      else
        begin
          bigNum = num1;
          smallNum = num2;
        end
    end
endmodule


module fp16_add_clk(clk, reset, num1_t, num2_t, result_t, overflow_t, zero_t, NaN_t, precisionLost_t);
  input clk, reset;
  input [15:0] num1_t, num2_t;

  output reg [15:0] result_t;
  //Flags
  output reg overflow_t;//overflow flag
  output reg zero_t; //zero flag
  output reg NaN_t; //Not a Number flag
  output reg precisionLost_t;

  reg [15:0] num1, num2;
  reg [15:0] result;
  //Flags
  reg overflow;//overflow flag
  reg zero; //zero flag
  reg NaN; //Not a Number flag
  reg precisionLost;

  fp16_add adder (.*);

  always @(posedge clk) begin
    if (reset) begin
      num1 <= 0;
      num2 <= 0;

      result_t <= 0;
      overflow_t <= 0;
      zero_t <= 0;
      NaN_t <= 0;
      precisionLost_t <= 0;
    end else begin
      num1 <= num1_t;
      num2 <= num2_t;

      result_t <= result;
      overflow_t <= overflow;
      zero_t <= zero;
      NaN_t <= NaN;
      precisionLost_t <= precisionLost;
    end
  end
endmodule