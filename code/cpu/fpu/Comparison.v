// this module is used to compare two floating point numbers 

// results 
// 00 -> equal
// 01 -> a > b
// 10 -> a < b
`timescale 1ns/100ps

module Comparison (
	input [31:0] a_operand,
	input [31:0] b_operand,
	output reg [1:0] result
	);

    always @ (*) 
    begin
      // both negative
      if (a_operand[31] == 1'b1 & b_operand[31] == 1'b1)
      begin
        if (a_operand[30:23] == b_operand[30:23]) 
          begin
          if (a_operand[22:0] == b_operand[22:0]) begin
              result = 2'b00;
          end 
          else begin
            if (a_operand[22:0] > b_operand[22:0]) result = 2'b10;
            else result = 2'b01;
          end
        end
        else begin
          if (a_operand[30:23] > b_operand[30:23]) result = 2'b10;
          else result = 2'b01;
        end
      end 

      if (a_operand[31] == 1'b0 & b_operand[31] == 1'b1)
      begin
        result = 2'b01;
      end 

      if (a_operand[31] == 1'b1 & b_operand[31] == 1'b0)
      begin
        result = 2'b10;
      end 
      
      // both positive
      if (a_operand[31] == 1'b0 & b_operand[31] == 1'b0)
      begin
        if (a_operand[30:23] == b_operand[30:23]) begin
          if (a_operand[22:0] == b_operand[22:0]) begin
              result = 2'b00;
          end 
          else begin
            if (a_operand[22:0] > b_operand[22:0]) result = 2'b01;
            else result = 2'b10;
          end
        end
        else begin
          if (a_operand[30:23] > b_operand[30:23]) result = 2'b01;
          else result = 2'b10;
        end
      end    
    end


endmodule